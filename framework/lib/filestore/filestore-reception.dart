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

class Reception implements storage.Reception {
  final Logger _log = new Logger('$libraryName.Reception');
  final String path;
  final Sequencer _sequencer;
  final GitEngine _git;
  final Calendar calendarStore;
  final bool logChanges;
  final Directory trashDir;

  Bus<event.ReceptionChange> _changeBus = new Bus<event.ReceptionChange>();
  Stream<event.ReceptionChange> get onReceptionChange => _changeBus.stream;

  Future get initialized =>
      _git != null ? _git.initialized : new Future.value(true);
  Future get ready => _git != null ? _git.whenReady : new Future.value(true);

  int get _nextId => _sequencer.nextInt();

  /**
   *
   */
  factory Reception(String path, [GitEngine _git, bool enableChangelog]) {
    if (!new Directory(path).existsSync()) {
      new Directory(path).createSync();
    }

    if (_git != null) {
      _git.init().catchError((error, stackTrace) => Logger.root
          .shout('Failed to initialize git engine', error, stackTrace));
    }

    if (enableChangelog == null) {
      enableChangelog = true;
    }

    final Directory trashDir = new Directory(path + '/.trash');
    if (!trashDir.existsSync()) {
      trashDir.createSync();
    }

    return new Reception._internal(path, new Calendar(path, _git),
        new Sequencer(path), _git, enableChangelog, trashDir);
  }

  /**
   *
   */
  Reception._internal(String this.path, this.calendarStore, this._sequencer,
      GitEngine this._git, bool this.logChanges, this.trashDir) {
    if (_git != null) {
      _git.addIgnoredPath(_sequencer.sequencerFilePath);
    }
  }

  /**
   *
   */
  Future<Iterable<model.ReceptionReference>> _receptionsOfOrg(int oid) async {
    List<FileSystemEntity> dirs = new Directory(path).listSync().where((fse) =>
        isDirectory(fse) &&
        new File(fse.path + '/reception.json').existsSync());

    return dirs
        .map((FileSystemEntity fse) {
          final reception = model.Reception.decode(JSON.decode(
              (new File(fse.path + '/reception.json')).readAsStringSync()));
          return reception;
        })
        .where((r) => r.oid == oid)
        .map((r) => r.reference);
  }

  /**
   *
   */
  Future<model.ReceptionReference> create(
      model.Reception reception, model.User modifier,
      {bool enforceId: false}) async {
    reception.id = reception.id != model.Reception.noId && enforceId
        ? reception.id
        : _nextId;

    final Directory dir = new Directory('$path/${reception.id}');
    final File file = new File('${dir.path}/reception.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File ${file.path} already exists, please update instead');
    }

    _log.finest('Creating new reception file ${file.path}');
    dir.createSync();
    file.writeAsStringSync(_jsonpp.convert(reception));

    if (this._git != null) {
      await _git.add(
          file,
          'uid:${modifier.id} - ${modifier.name} '
          'added ${reception.id}',
          _authorString(modifier));
    }

    if (logChanges) {
      new ChangeLogger('$path/${reception.id}').add(
          new model.ReceptionChangelogEntry.create(
              modifier.reference, reception));
    }

    _changeBus
        .fire(new event.ReceptionChange.create(reception.id, modifier.id));

    return reception.reference;
  }

  /**
   *
   */
  Future<model.Reception> get(int id) async {
    final File file = new File('$path/${id}/reception.json');

    if (!file.existsSync()) {
      throw new storage.NotFound('No file with name ${id}');
    }

    try {
      final model.Reception bc =
          model.Reception.decode(JSON.decode(file.readAsStringSync()));
      return bc;
    } catch (e) {
      throw e;
    }
  }

  /**
   *
   */
  Future<model.Reception> getByExtension(String extension) async {
    List<FileSystemEntity> dirs = new Directory(path).listSync().where((fse) =>
        isDirectory(fse) &&
        new File(fse.path + '/reception.json').existsSync());

    return dirs.map((FileSystemEntity fse) {
      final reception = model.Reception.decode(JSON
          .decode((new File(fse.path + '/reception.json')).readAsStringSync()));
      return reception;
    }).firstWhere((rec) => rec.dialplan == extension,
        orElse: () => throw new storage.NotFound(
            'No reception with dialplan $extension'));
  }

  /**
   *
   */
  Future<String> extensionOf(int id) async => (await get(id)).dialplan;

  /**
   *
   */
  Future<Iterable<model.ReceptionReference>> list() async {
    List<FileSystemEntity> dirs = new Directory(path).listSync().where((fse) =>
        isDirectory(fse) &&
        new File(fse.path + '/reception.json').existsSync());

    return dirs.map((FileSystemEntity fse) {
      final reception = model.Reception.decode(JSON
          .decode((new File(fse.path + '/reception.json')).readAsStringSync()));
      return reception.reference;
    });
  }

  /**
   *
   */
  Future remove(int rid, model.User modifier) async {
    final Directory receptionDir = new Directory('$path/${rid}');

    if (!receptionDir.existsSync()) {
      throw new storage.NotFound();
    }

    _log.finest('Deleting file ${receptionDir.path}');
    if (this._git != null) {
      await _git.remove(
          receptionDir,
          'uid:${modifier.id} - ${modifier.name} '
          'removed $rid',
          _authorString(modifier));
    }

    if (logChanges) {
      new ChangeLogger('$path/${rid}').add(
          new model.ReceptionChangelogEntry.delete(modifier.reference, rid));
    }

    await receptionDir.rename(trashDir.path + '/${rid}');

    _changeBus.fire(new event.ReceptionChange.delete(rid, modifier.id));
  }

  /**
   *
   */
  Future<model.ReceptionReference> update(
      model.Reception rec, model.User modifier) async {
    if (rec.id == model.Reception.noId) {
      throw new storage.ClientError('id may not be "noId"');
    }
    final File file = new File('$path/${rec.id}/reception.json');
    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    file.writeAsStringSync(_jsonpp.convert(rec));

    if (this._git != null) {
      await _git.commit(
          file,
          'uid:${modifier.id} - ${modifier.name} '
          'updated ${rec.name}',
          _authorString(modifier));
    }

    if (logChanges) {
      new ChangeLogger('$path/${rec.id}').add(
          new model.ReceptionChangelogEntry.update(modifier.reference, rec));
    }

    _changeBus.fire(new event.ReceptionChange.update(rec.id, modifier.id));

    return rec.reference;
  }

  /**
   *
   */
  Future<Iterable<model.Commit>> changes([int rid]) async {
    if (this._git == null) {
      throw new UnsupportedError(
          'Filestore is instantiated without git support');
    }

    FileSystemEntity fse;

    if (rid == null) {
      fse = new Directory('.');
    } else {
      fse = new File('$rid/reception.json');
    }

    Iterable<Change> gitChanges = await _git.changes(fse);

    int extractUid(String message) => message.startsWith('uid:')
        ? int.parse(message.split(' ').first.replaceFirst('uid:', ''))
        : model.User.noId;

    model.ReceptionChange convertFilechange(FileChange fc) {
      final int id = int.parse(fc.filename.split('/').first);

      return new model.ReceptionChange(fc.changeType, id);
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
  Future<String> changeLog(int rid) async =>
      logChanges ? new ChangeLogger('$path/$rid').contents() : '';
}
