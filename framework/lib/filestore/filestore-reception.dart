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
  GitEngine _git;

  Future get initialized => _git.initialized;
  Future get ready => _git.whenReady;

  String get _newUuid => _uuid.v4();

  /**
   *
   */
  Reception({String this.path: 'json-data/reception'}) {
    _git = new GitEngine(path);
    _git.init();
  }

  Future<Iterable<model.ReceptionReference>> _receptionsOfOrg(
      String uuid) async {
    Iterable files = new Directory('$path')
        .listSync()
        .where((fse) => fse is File && fse.path.endsWith('.json'));

    Iterable<model.Reception> receptions = await Future.wait((files.map(
        (File file) async => await file
            .readAsString()
            .then(JSON.decode)
            .then(model.Reception.decode))));

    return receptions
        .where((r) => r.organizationUuid == uuid)
        .map((r) => r.reference);
  }

  /**
   *
   */
  Future<model.ReceptionReference> create(
      model.Reception reception, model.User modifier) async {
    _log.info(_newUuid);
    _log.info(_newUuid);
    _log.info(_newUuid);
    _log.info(_newUuid);

    if (reception.uuid == model.Reception.noId) {
      reception.uuid = _newUuid;
    }
    final File file = new File('$path/${reception.uuid}.json');

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

    await _git.add(file, 'Added ${reception.uuid}', _authorString(modifier));

    return reception.reference;
  }

  /**
   *
   */
  Future<model.Reception> get(String uuid) async {
    final File file = new File('$path/${uuid}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound('No file with name ${uuid}');
    }

    try {
      final model.Reception bc =
          model.Reception.decode(JSON.decode(file.readAsStringSync()));
      return bc;
    } catch (e) {
      throw e;
    }
  }

  Future<model.Reception> getByExtension(String extension) async {
    new Directory(path).listSync().where((fse) => fse is File && fse.path.endsWith('.json')).map((fse) {
      fse.
    });
  }

  Future<Iterable<Map<String,model.ReceptionReference>>> extensionMap() {

  }

  Future<String> extensionOf(String uuid) async => (await get(uuid)).dialplan;

  Future<Iterable<model.ReceptionReference>> list() {
    throw new UnimplementedError();
  }

  Future remove(String uuid, model.User modifier) async {
    final File file = new File('$path/${uuid}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    await _git.remove(file, 'Removed $uuid', _authorString(modifier));
  }

  /**
   *
   */
  Future<model.ReceptionReference> update(
      model.Reception rec, model.User modifier) async {
    final File file = new File('$path/${rec.uuid}.json');

    if (rec.uuid == model.Reception.noId) {
      throw new storage.ClientError('uuid may not be "noId"');
    }

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(rec));

    await _git._commit('Updated ${rec.name}', _authorString(modifier));

    return rec.reference;
  }
}
