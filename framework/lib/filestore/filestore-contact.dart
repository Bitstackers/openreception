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

class Contact implements storage.Contact {
  final Logger _log = new Logger('$libraryName.Contact');
  final String path;
  final Reception _receptionStore;
  GitEngine _git;

  Future get initialized => _git.initialized;
  Future get ready => _git.whenReady;

  String get _newUuid => _uuid.v4();

  /**
   *
   */
  Contact(this._receptionStore, {String this.path: 'json-data/contact'}) {
    _git = new GitEngine(path);
    _git.init();
  }

  /**
   *
   */
  Future<Iterable<model.ContactReference>> _contactsOfReception(
          String rUuid) async =>
      (await list()).where((model.ContactReference cRef) =>
          new File('$path/${cRef.uuid}/receptions/${rUuid}.json').existsSync());

  /**
   *
   */
  Future<model.ReceptionAttributes> addContactToReception(
      model.ReceptionAttributes attr, model.User user) async {
    if (attr.receptionUuid == model.Reception.noId) {
      throw new ArgumentError('attr.receptionUuid must be valid');
    }
    final recDir = new Directory('$path/${attr.contactUuid}/receptions');
    if (!recDir.existsSync()) {
      recDir.createSync(recursive: true);
    }

    final File file = new File('${recDir.path}/${attr.receptionUuid}.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    /// Set the user
    if (user == null) {
      user = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(attr));
    _log.finest('Created new file ${file.path}');

    await _git.add(file, 'Added ${attr.contactUuid} to ${attr.receptionUuid}',
        _authorString(user));

    return attr;
  }

  /**
   *
   */
  Future<model.ContactReference> create(
      model.BaseContact contact, model.User modifier) async {
    if (contact.uuid == model.BaseContact.noId) {
      contact.uuid = _newUuid;
    }
    final File file = new File('$path/${contact.uuid}.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    _log.finest('Creating new file ${file.path}');
    file.writeAsStringSync(_jsonpp.convert(contact));

    await _git.add(file, 'Added ${contact.uuid}', _authorString(modifier));

    return contact.reference;
  }

  /**
   *
   */
  Future<model.BaseContact> get(String uuid) async {
    final File file = new File('$path/${uuid}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound('No file ${file.path}');
    }

    try {
      final model.BaseContact bc =
          model.BaseContact.decode(JSON.decode(file.readAsStringSync()));
      return bc;
    } catch (e) {
      throw e;
    }
  }

  /**
   *
   */
  Future<model.ReceptionAttributes> getByReception(
      String uuid, String receptionUuid) async {
    final file = new File('$path/$uuid/receptions/$receptionUuid.json');
    if (!file.existsSync()) {
      throw new storage.NotFound('No file: ${file.path}');
    }

    return model.ReceptionAttributes
        .decode(JSON.decode(await file.readAsString()));
  }

  /**
   *
   */
  Future<Iterable<model.ContactReference>> list() async {
    if (!new Directory(path).existsSync()) {
      return [];
    }

    return new Directory(path)
        .listSync()
        .where((fse) => fse is File && fse.path.endsWith('.json'))
        .map((File fse) => model.BaseContact
            .decode(JSON.decode(fse.readAsStringSync()))
            .reference);
  }

  /**
   *
   */
  Future<Iterable<model.ReceptionAttributes>> listByReception(
      String receptionUuid) async {
    final subdirs =
        new Directory(path).listSync().where((fse) => fse is Directory);

    List<model.ReceptionAttributes> attrs = [];
    subdirs.forEach((Directory dir) {
      final attrFile = new File(dir.path + '/receptions/$receptionUuid.json');
      if (attrFile.existsSync()) {
        attrs.add(model.ReceptionAttributes
            .decode(JSON.decode(attrFile.readAsStringSync())));
      }
    });

    return attrs;
  }

  /**
   *
   */
  Future<Iterable<model.ContactReference>> organizationContacts(
      String organizationUuid) async {
    Iterable recIds = await _receptionStore._receptionsOfOrg(organizationUuid);

    Set<model.ContactReference> contacts = new Set();

    await Future.wait(recIds.map((rid) async {
      contacts.addAll(await _contactsOfReception(rid.uuid));
    }));

    return contacts;
  }

  /**
   *
   */
  Future<Iterable<model.OrganizationReference>> organizations(
      String uuid) async {
    Iterable<model.ReceptionReference> recIds = await receptions(uuid);

    print(recIds);

    Set<model.OrganizationReference> orgs = new Set();
    await Future.wait(recIds.map((rid) async {
      orgs.add(new model.OrganizationReference(
          (await _receptionStore.get(rid.uuid)).organizationUuid, ''));
    }));

    return orgs;
  }

  /**
   *
   */
  Future<Iterable<model.ReceptionReference>> receptions(String uuid) async {
    final File contactFile = new File('$path/${uuid}.json');
    if (!contactFile.existsSync()) {
      throw new storage.NotFound('No file: ${contactFile.path}');
    }

    final rDir = new Directory('$path/$uuid/receptions');
    if (!rDir.existsSync()) {
      return [];
    }

    Set<model.ReceptionReference> refs = new Set<model.ReceptionReference>();

    await Future.wait(rDir
        .listSync()
        .where((fse) => fse is File && fse.path.endsWith('.json'))
        .map((File file) async {
      String id = basenameWithoutExtension(file.path);

      refs.add(new model.ReceptionReference(
          id, (await _receptionStore.get(id)).name));
    }));

    return refs;
  }

  /**
   *
   */
  Future remove(String uuid, model.User user) async {
    final File file = new File('$path/${uuid}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (user == null) {
      user = _systemUser;
    }

    await _git.remove(file, 'Removed $uuid', _authorString(user));
  }

  /**
   *
   */
  Future removeFromReception(
      String uuid, String receptionUuid, model.User modifier) async {
    if (uuid == model.BaseContact.noId ||
        receptionUuid == model.Reception.noId) {
      throw new storage.ClientError('Empty id');
    }

    final recDir = new Directory('$path/${uuid}/receptions');
    final File file = new File('${recDir.path}/${receptionUuid}.json');
    if (!file.existsSync()) {
      throw new storage.NotFound('No file ${file}');
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    _log.finest('Removing file ${file.path}');

    await _git.remove(
        file, 'Removed ${uuid} from ${receptionUuid}', _authorString(modifier));
  }

  /**
   *
   */
  Future<model.BaseContact> update(
      model.BaseContact contact, model.User user) async {
    final File file = new File('$path/${contact.uuid}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (user == null) {
      user = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(contact));

    await _git.add(file, 'Updated ${contact.name}', _authorString(user));

    return contact;
  }

  /**
   *
   */
  Future<model.ReceptionAttributes> updateInReception(
      model.ReceptionAttributes attr, model.User modifier) async {
    if (attr.contactUuid == model.BaseContact.noId) {
      throw new storage.ClientError('Empty id');
    }
    final recDir = new Directory('$path/${attr.contactUuid}/receptions');
    final File file = new File('${recDir.path}/${attr.receptionUuid}.json');
    if (!file.existsSync()) {
      throw new storage.NotFound('No file ${file}');
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    _log.finest('Creating new file ${file.path}');
    file.writeAsStringSync(_jsonpp.convert(attr));

    await _git.add(file, 'Updated ${attr.contactUuid} in ${attr.receptionUuid}',
        _authorString(modifier));

    return attr;
  }
}
