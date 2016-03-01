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

class Organization implements storage.Organization {
  final Logger _log = new Logger('$libraryName.Organization');
  final String path;
  final Contact _contactFileStore;
  final Reception _receptionFileStore;
  GitEngine _git;
  Sequencer _sequencer;

  Future get initialized => _git.initialized;
  Future get ready => _git.whenReady;

  int get _nextId => _sequencer.nextInt();

  /**
   *
   */
  Organization(this._contactFileStore, this._receptionFileStore,
      {String this.path: 'json-data/organization'}) {
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
  Future<Iterable<model.ContactReference>> contacts(int id) async {
    List<model.ContactReference> cRefs = [];
    List<model.ReceptionReference> rRefs = await receptions(id);

    await Future.forEach(rRefs, (rRef) async {
      cRefs.addAll(await _contactFileStore._contactsOfReception(rRef.id));
    });

    return cRefs;
  }

  /**
   *
   */
  Future<model.OrganizationReference> create(
      model.Organization org, model.User user) async {
    if (org.id == null) {
      throw new storage.ClientError(
          new ArgumentError.notNull(org.id.toString()).toString());
    }

    if (org.id == model.Organization.noId) {
      org.id = _nextId;
    }
    final File file = new File('$path/${org.id}.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    /// Set the user
    if (user == null) {
      user = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(org));

    await _git.add(file, 'Added ${org.name}', _authorString(user));

    return org.reference;
  }

  /**
   *
   */
  Future<model.Organization> get(int id) async {
    final File file = new File('$path/${id}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound('No file with name ${id}');
    }

    try {
      final model.Organization org =
          model.Organization.decode(JSON.decode(file.readAsStringSync()));
      return org;
    } catch (e) {
      throw e;
    }
  }

  /**
   *
   */
  Future<Iterable<model.OrganizationReference>> list() async =>
      new Directory(path)
          .listSync()
          .where((fse) => fse is File && fse.path.endsWith('.json'))
          .map((File fse) => model.Organization
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

    await _git.remove(file, 'Removed $id', _authorString(modifier));
  }

  /**
   *
   */
  Future<model.OrganizationReference> update(
      model.Organization org, model.User user) async {
    final File file = new File('$path/${org.id}.json');

    if (org.id == model.Organization.noId) {
      throw new storage.ClientError('uuid may not be "noId"');
    }

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (user == null) {
      user = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(org));

    await _git._commit('Updated ${org.name}', _authorString(user));

    return org.reference;
  }

  /**
   *
   */
  Future<Iterable<model.ReceptionReference>> receptions(int uuid) =>
      _receptionFileStore._receptionsOfOrg(uuid);
}
