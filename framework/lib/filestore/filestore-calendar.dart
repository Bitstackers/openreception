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

class Calendar implements storage.Calendar {
  final Logger _log = new Logger('$libraryName.Calendar');
  final String path;
  Sequencer _sequencer;
  GitEngine _git;

  Future get initialized =>
      _git != null ? _git.initialized : new Future.value(true);
  Future get ready => _git != null ? _git.whenReady : new Future.value(true);

  Bus<event.CalendarChange> _changeBus = new Bus<event.CalendarChange>();
  Stream<event.CalendarChange> get changeStream => _changeBus.stream;

  int get _nextId => _sequencer.nextInt();

  /**
   *
   */
  Calendar(String this.path, [GitEngine this._git]) {
    final List<String> pathsToCreate = [path];

    pathsToCreate.forEach((String newPath) {
      final Directory dir = new Directory(newPath);
      if (!dir.existsSync()) {
        dir.createSync();
      }
    });

    if (this._git != null) {
      _git.init().catchError((error, stackTrace) => Logger.root
          .shout('Failed to initialize git engine', error, stackTrace));
    }

    _sequencer = new Sequencer(path);
  }

  /**
   *
   */
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
  Future<model.CalendarEntry> create(
      model.CalendarEntry entry, model.Owner owner, model.User modifier,
      {bool enforceId: false}) async {
    /// Validate the user
    if (modifier == null) {
      throw new ArgumentError.notNull('modifier');
    }

    entry.id =
        entry.id != model.CalendarEntry.noId && enforceId ? entry.id : _nextId;

    entry.id = _nextId;
    final String ownerPath = '$path/${owner.id}/calendar';

    final Directory ownerDir = new Directory(ownerPath);
    try {
      ownerDir.createSync();
    } catch (e) {
      _log.warning('Creating new directory ${ownerDir.path}');
      throw new storage.NotFound('Owner not found: ${owner.id}');
    }

    final File file = new File('${ownerDir.path}/${entry.id}.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    _log.finest('Creating new file ${file.path}');
    file.writeAsStringSync(_jsonpp.convert(entry));

    if (this._git != null) {
      await _git.add(
          file,
          'uid:${modifier.id} - ${modifier.name}'
          'added ${entry.id} to ${owner}',
          _authorString(modifier));
    }

    _changeBus
        .fire(new event.CalendarChange.create(entry.id, owner, modifier.id));

    return entry;
  }

  /**
   *
   */
  Future<model.CalendarEntry> get(int eid, model.Owner owner) async {
    final Iterable<Directory> subdirs =
        new Directory(path).listSync().where(isDirectory);

    for (Directory subdir in subdirs) {
      Iterable<Directory> ownerDirs = subdir.listSync().where(isDirectory);

      for (Directory dir in ownerDirs) {
        File file = new File('${dir.path}/${eid}.json');

        if (file.existsSync()) {
          return model.CalendarEntry
              .decode(JSON.decode(file.readAsStringSync()));
        }
      }
    }

    throw new storage.NotFound('No file with eid ${eid}');
  }

  /**
   *
   */
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
   * Deletes the [Model.CalendarEntry] associated with [eid] in the
   * filestore.
   * The action is logged as being performed by user [modifier].
   */
  Future remove(int eid, model.Owner owner, model.User modifier) async {
    /// Validate the user
    if (modifier == null) {
      throw new ArgumentError.notNull('modifier');
    }

    final Directory ownerDir = new Directory('$path/${owner.id}/calendar');
    final File file = new File('${ownerDir.path}/${eid}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
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

    _changeBus.fire(new event.CalendarChange.delete(eid, owner, modifier.id));
  }

  /**
   *
   */
  Future<model.CalendarEntry> update(
      model.CalendarEntry entry, model.Owner owner, model.User modifier) async {
    /// Validate the user
    if (modifier == null) {
      throw new ArgumentError.notNull('modifier');
    }

    final Directory ownerDir = new Directory('$path/${owner.id}/calendar');

    final File file = new File('${ownerDir.path}/${entry.id}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
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

    _changeBus
        .fire(new event.CalendarChange.update(entry.id, owner, modifier.id));

    return entry;
  }
}
