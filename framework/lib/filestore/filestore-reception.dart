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

class Reception implements storage.Reception {
  final Logger _log = new Logger('$libraryName.Reception');
  final String path;
  Sequencer _sequencer;
  GitEngine _git;

  Future get initialized => _git.initialized;
  Future get ready => _git.whenReady;

  int get _nextId => _sequencer.nextInt();

  /**
   *
   */
  Reception({String this.path: 'json-data/reception'}) {
    if (!new Directory(path).existsSync()) {
      new Directory(path).createSync(recursive: true);
    }
    _git = new GitEngine(path);
    _git.init();
    _sequencer = new Sequencer(path);
  }

  /**
   *
   */
  Future<Iterable<model.ReceptionReference>> _receptionsOfOrg(int id) async {
    Iterable files = new Directory('$path')
        .listSync()
        .where((fse) => fse is File && fse.path.endsWith('.json'));

    Iterable<model.Reception> receptions = await Future.wait((files.map(
        (File file) async => await file
            .readAsString()
            .then(JSON.decode)
            .then(model.Reception.decode))));

    return receptions
        .where((r) => r.organizationId == id)
        .map((r) => r.reference);
  }

  /**
   *
   */
  Future<model.ReceptionReference> create(
      model.Reception reception, model.User modifier) async {
    if (reception.id == model.Reception.noId) {
      reception.id = _nextId;
    }
    final File file = new File('$path/${reception.id}.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File ${file.path} already exists, please update instead');
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    _log.finest('Creating new file ${file.path}');
    file.writeAsStringSync(_jsonpp.convert(reception));

    await _git.add(
        file,
        'uid:${modifier.id} - ${modifier.name} '
        'added ${reception.id}',
        _authorString(modifier));

    return reception.reference;
  }

  /**
   *
   */
  Future<model.Reception> get(int id) async {
    final File file = new File('$path/${id}.json');

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
  Future<model.Reception> getByExtension(String extension) async =>
      new Directory(path)
          .listSync()
          .where((fse) => fse is File && fse.path.endsWith('.json'))
          .map((File fse) =>
              model.Reception.decode(JSON.decode(fse.readAsStringSync())))
          .firstWhere((rec) => rec.dialplan == extension,
              orElse: () => throw new storage.NotFound(
                  'No reception with dialplan $extension'));

  /**
   *
   */
  Future<Iterable<Map<String, model.ReceptionReference>>> extensionMap() {
    throw new UnimplementedError();
  }

  /**
   *
   */
  Future<String> extensionOf(int id) async => (await get(id)).dialplan;

  /**
   *
   */
  Future<Iterable<model.ReceptionReference>> list() async => new Directory(path)
      .listSync()
      .where((fse) => fse is File && fse.path.endsWith('.json'))
      .map((File fse) => model.Reception
          .decode(JSON.decode(fse.readAsStringSync()))
          .reference);

  /**
   *
   */
  Future remove(int id, model.User modifier) async {
    final File file = new File('$path/${id}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    await _git.remove(
        file,
        'uid:${modifier.id} - ${modifier.name} '
        'removed $id',
        _authorString(modifier));
  }

  /**
   *
   */
  Future<model.ReceptionReference> update(
      model.Reception rec, model.User modifier) async {
    if (rec.id == model.Reception.noId) {
      throw new storage.ClientError('id may not be "noId"');
    }
    final File file = new File('$path/${rec.id}.json');
    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(rec));

    await _git.commit(file,
        'uid:${modifier.id} - ${modifier.name} '
        'updated ${rec.name}',
        _authorString(modifier));

    return rec.reference;
  }

  /**
   *
   */
  Future<Iterable<model.Commit>> changes([int rid]) async {
    FileSystemEntity fse;

    if (rid == null) {
      fse = new Directory('.');
    } else {
      fse = new File('$rid.json');
    }

    Iterable<Change> gitChanges = await _git.changes(fse);

    int extractUid(String message) => message.startsWith('uid:')
        ? int.parse(message.split(' ').first.replaceFirst('uid:', ''))
        : model.User.noId;

    model.ReceptionChange convertFilechange(FileChange fc) {
      final int id = int.parse(fc.filename.split('.').first);

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
}
