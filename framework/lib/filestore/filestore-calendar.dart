/*                  This file is part of OpenReception
                   Copyright (C) 2016-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.framework.filestore;

/// Filestore for persistent storage of [model.CalendarEntry] objects.
class Calendar implements storage.Calendar {
  /// Internal log stream
  final Logger _log = new Logger('$libraryName.Calendar');

  /// Root path to where the object files are stored
  final String path;

  /// Determines whether or not to write object changes to a changelog
  final bool logChanges;

  /// Internal sequencer. Keeps track of which id's has been used.
  Sequencer _sequencer;

  /// Revision engine. Keeps track of object changes and who performs them.
  GitEngine _git;

  /// Internal change bus. Exposed externally by [changeStream]
  final Bus<event.CalendarChange> _changeBus = new Bus<event.CalendarChange>();

  /**
   *
   */
  Calendar(String this.path, [GitEngine this._git, bool enableChangelog])
      : this.logChanges = (enableChangelog != null) ? enableChangelog : true {
    final List<String> pathsToCreate = [path];

    pathsToCreate.forEach((String newPath) {
      final Directory dir = new Directory(newPath);
      if (!dir.existsSync()) {
        dir.createSync();
      }
    });

    _sequencer = new Sequencer(path);
    if (this._git != null) {
      _git.init().catchError((error, stackTrace) => Logger.root
          .shout('Failed to initialize git engine', error, stackTrace));
      _git.addIgnoredPath(_sequencer.sequencerFilePath);
    }
  }

  /// Returns the next available ID from the sequencer. Notice that every
  /// call to this function will increase the counter in the
  /// sequencer object.
  int get _nextId => _sequencer.nextInt();

  /// Spawns events on every object change. May be used by external classes
  /// to, for instance, maintain caches./
  Stream<event.CalendarChange> get changeStream => _changeBus.stream;

  /// Returns when the filestore is initialized
  Future get initialized =>
      _git != null ? _git.initialized : new Future.value(true);

  /// Returns when the filestore is initialized and ready - not busy
  /// performing object changes.
  Future get ready => _git != null ? _git.whenReady : new Future.value(true);

  @override
  Future<Iterable<model.Commit>> changes(model.Owner owner, [int eid]) async {
    if (this._git == null) {
      throw new UnsupportedError(
          'Filestore is instantiated without git support');
    }

    final String ownerPath = '${owner.id}/calendar';

    FileSystemEntity fse;

    if (eid == null) {
      fse = new Directory(ownerPath);
    } else {
      fse = new File(ownerPath + '/$eid.json');
    }

    Iterable<Change> gitChanges = await _git.changes(fse);

    int extractUid(String message) => message.startsWith('uid:')
        ? int.parse(message.split(' ').first.replaceFirst('uid:', ''))
        : model.User.noId;

    model.CalendarChange convertFilechange(FileChange fc) {
      final parts = fc.filename.split('/');
      final int eid = int.parse(parts[2].split('.').first);

      return new model.CalendarChange(fc.changeType, eid);
    }

    Iterable<model.Commit> changes = gitChanges.map((change) =>
        new model.Commit()
          ..uid = extractUid(change.message)
          ..changedAt = change.changeTime
          ..commitHash = change.commitHash
          ..authorIdentity = change.author
          ..changes = new List<model.ObjectChange>.from(
              change.fileChanges.map(convertFilechange)));

    _log.info(changes.map((c) => c.toJson()));

    return changes;
  }

  /**
   *
   */
  @override
  Future<model.CalendarEntry> create(
      model.CalendarEntry entry, model.Owner owner, model.User modifier,
      {bool enforceId: false}) async {
    entry.id =
        entry.id != model.CalendarEntry.noId && enforceId ? entry.id : _nextId;

    entry.lastAuthorId = modifier.id;
    entry.touched = new DateTime.now();

    final Directory ownerDir = _ownerDir(owner.id);
    try {
      ownerDir.createSync();
    } catch (e) {
      _log.warning('Creating new directory ${ownerDir.path}');
      throw new NotFound('Owner not found: ${owner.id}');
    }

    final File file = new File('${ownerDir.path}/${entry.id}.json');

    if (file.existsSync()) {
      throw new ClientError('File already exists, please update instead');
    }

    _log.finest('Creating new file ${file.path}');
    file.writeAsStringSync(_jsonpp.convert(entry));

    if (this._git != null) {
      await _git.add(
          file,
          'uid:${modifier.id} - ${modifier.name}'
          'added ${entry.id} to $owner',
          _authorString(modifier));
    }

    if (logChanges) {
      new ChangeLogger(ownerDir.path).add(
          new model.CalendarChangelogEntry.create(modifier.reference, entry));
    }

    _changeBus
        .fire(new event.CalendarChange.create(entry.id, owner, modifier.id));

    return entry;
  }

  /**
   *
   */
  @override
  Future<model.CalendarEntry> get(int eid, model.Owner owner) async {
    final subdirs = new Directory(path).listSync().where(isDirectory);

    for (Directory subdir in subdirs) {
      final ownerDirs = subdir.listSync().where(isDirectory);

      for (Directory dir in ownerDirs) {
        File file = new File('${dir.path}/$eid.json');

        if (file.existsSync()) {
          return model.CalendarEntry
              .decode(JSON.decode(file.readAsStringSync()));
        }
      }
    }

    throw new NotFound('No file with eid $eid');
  }

  /**
   *
   */
  @override
  Future<Iterable<model.CalendarEntry>> list(model.Owner owner) async {
    String ownerPath = '$path/${owner.id}/calendar';

    if (!new Directory(ownerPath).existsSync()) {
      return const [];
    }

    return _list(ownerPath);
  }

  /**
   *
   */
  Future<Iterable<model.CalendarEntry>> _list(String basePath) async =>
      new Directory(basePath)
          .listSync()
          .where((fse) => isFile(fse) && fse.path.endsWith('.json'))
          .map((FileSystemEntity fse) => model.CalendarEntry
              .decode(JSON.decode((fse as File).readAsStringSync())));

  /**
   * Deletes the [model.CalendarEntry] associated with [eid] in the
   * filestore.
   * The action is logged as being performed by user [modifier].
   */
  @override
  Future remove(int eid, model.Owner owner, model.User modifier) async {
    final Directory ownerDir = new Directory('$path/${owner.id}/calendar');
    final File file = new File('${ownerDir.path}/$eid.json');

    if (!file.existsSync()) {
      throw new NotFound();
    }

    _log.finest('Deleting file ${file.path}');

    if (this._git != null) {
      await _git.remove(
          file,
          'uid:${modifier.id} - ${modifier.name}'
          ' removed $eid',
          _authorString(modifier));
    } else {
      file.deleteSync();
    }
    if (logChanges) {
      new ChangeLogger(ownerDir.path).add(
          new model.CalendarChangelogEntry.delete(modifier.reference, eid));
    }

    _deleteNotify(eid, owner, modifier);
  }

  /**
   * Notifies listeners of the [changeStream] that an item has been deleted.
   */
  void _deleteNotify(int eid, model.Owner owner, model.User modifier) =>
      _changeBus.fire(new event.CalendarChange.delete(eid, owner, modifier.id));

  /**
   *
   */
  @override
  Future<model.CalendarEntry> update(
      model.CalendarEntry entry, model.Owner owner, model.User modifier) async {
    final Directory ownerDir = new Directory('$path/${owner.id}/calendar');
    final File file = new File('${ownerDir.path}/${entry.id}.json');

    entry.lastAuthorId = modifier.id;
    entry.touched = new DateTime.now();

    if (!file.existsSync()) {
      throw new NotFound();
    }

    _log.finest('Updating file ${file.path}');
    file.writeAsStringSync(_jsonpp.convert(entry));

    if (this._git != null) {
      await _git.commit(
          file,
          'uid:${modifier.id} - ${modifier.name}'
          ' updated ${entry.id}',
          _authorString(modifier));
    }

    if (logChanges) {
      new ChangeLogger(ownerDir.path).add(
          new model.CalendarChangelogEntry.update(modifier.reference, entry));
    }

    _changeBus
        .fire(new event.CalendarChange.update(entry.id, owner, modifier.id));

    return entry;
  }

  /**
   *
   */
  Future<String> changeLog(int ownerId) async =>
      logChanges ? new ChangeLogger(_ownerDir(ownerId).path).contents() : '';

  /**
   *
   */
  Directory _ownerDir(int ownerId) => new Directory('$path/$ownerId/calendar');
}
