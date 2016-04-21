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

part of openreception.filestore;

class Calendar implements storage.Calendar {
  final Logger _log = new Logger('$libraryName.Calendar');
  final String path;
  Sequencer _sequencer;
  GitEngine _git;

  Future get initialized => _git.initialized;
  Future get ready => _git.whenReady;

  int get _nextId => _sequencer.nextInt();

  /**
   *
   */
  Calendar({String this.path: 'json-data/calendar'}) {
    final List<String> pathsToCreate = [
      path
    ];

    pathsToCreate.forEach((String newPath) {
      final Directory dir = new Directory(newPath);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
    });

    _git = new GitEngine(path);
    _git.init();
    _sequencer = new Sequencer(path);
  }

  /**
   *
   */
  Future<Iterable<model.Commit>> changes(model.Owner owner, [int eid]) async {
    String ownerPath;
    if (owner is model.OwningContact) {
      ownerPath = 'contact/${owner.id}';
    } else if (owner is model.OwningReception) {
      ownerPath = 'reception/${owner.id}';
    } else {
      throw new ArgumentError.value(owner, 'owner', 'Not of known type');
    }

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
      model.Owner owner;

      if (parts[0] == 'contact') {
        owner = new model.OwningContact(int.parse(parts[1]));
      } else if (parts[0] == 'reception') {
        owner = new model.OwningReception(int.parse(parts[1]));
      }

      final int eid = int.parse(parts[2].split('.').first);

      return new model.CalendarChange(fc.changeType, eid, owner);
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
      model.CalendarEntry entry, model.User modifier) async {
    /// Validate the user
    if (modifier == null) {
      throw new ArgumentError.notNull('modifier');
    }

    entry.id = _nextId;
    String ownerPath;
    if (entry.owner is model.OwningContact) {
      ownerPath = '$path/contact/${entry.owner.id}';
    } else if (entry.owner is model.OwningReception) {
      ownerPath = '$path/reception/${entry.owner.id}';
    }

    final Directory ownerDir = new Directory(ownerPath);
    if (!ownerDir.existsSync()) {
      _log.finest('Creating new directory ${ownerDir.path}');
      ownerDir.createSync(recursive: true);
    }

    final File file = new File('${ownerDir.path}/${entry.id}.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    _log.finest('Creating new file ${file.path}');
    file.writeAsStringSync(_jsonpp.convert(entry));

    await _git.add(
        file,
        'uid:${modifier.id} - ${modifier.name}'
        'added ${entry.id} to ${entry.owner}',
        _authorString(modifier));

    return entry;
  }

  /**
   *
   */
  Future<model.CalendarEntry> get(int eid) async {
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
    String ownerPath;
    if (owner is model.OwningContact) {
      ownerPath = '$path/contact/${owner.id}';
    } else if (owner is model.OwningReception) {
      ownerPath = '$path/reception/${owner.id}';
    }

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
          .map((File fse) =>
              model.CalendarEntry.decode(JSON.decode(fse.readAsStringSync())));

  /**
   * Deletes the [Model.CalendarEntry] associated with [eid] in the
   * filestore.
   * The action is logged as being performed by user [modifier].
   */
  Future remove(int eid, model.User modifier) async {
    /// Validate the user
    if (modifier == null) {
      throw new ArgumentError.notNull('modifier');
    }

    final model.CalendarEntry entry = await get(eid);

    String ownerPath;
    if (entry.owner is model.OwningContact) {
      ownerPath = '$path/contact/${entry.owner.id}';
    } else if (entry.owner is model.OwningReception) {
      ownerPath = '$path/reception/${entry.owner.id}';
    }

    final Directory ownerDir = new Directory(ownerPath);

    final File file = new File('${ownerDir.path}/${entry.id}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    _log.finest('Deleting file ${file.path}');
    await _git.remove(
        file,
        'uid:${modifier.id} - ${modifier.name}'
        ' removed $eid',
        _authorString(modifier));
  }

  /**
   *
   */
  Future<model.CalendarEntry> update(
      model.CalendarEntry entry, model.User modifier) async {
    /// Validate the user
    if (modifier == null) {
      throw new ArgumentError.notNull('modifier');
    }

    String ownerPath;
    if (entry.owner is model.OwningContact) {
      ownerPath = '$path/contact/${entry.owner.id}';
    } else if (entry.owner is model.OwningReception) {
      ownerPath = '$path/reception/${entry.owner.id}';
    }

    final Directory ownerDir = new Directory(ownerPath);

    final File file = new File('${ownerDir.path}/${entry.id}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    _log.finest('Updating file ${file.path}');
    file.writeAsStringSync(_jsonpp.convert(entry));

    await _git._commit(
        'uid:${modifier.id} - ${modifier.name}'
        ' updated ${entry.id}',
        _authorString(modifier));

    return entry;
  }
}
