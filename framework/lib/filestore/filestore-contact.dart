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
  Sequencer _sequencer;

  Future get initialized => _git.initialized;
  Future get ready => _git.whenReady;

  int get _nextId => _sequencer.nextInt();

  /**
   *
   */
  Contact(this._receptionStore, {String this.path: 'json-data/contact'}) {
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
  Future<Iterable<model.ContactReference>> _contactsOfReception(int id) async =>
      (await list()).where((model.ContactReference cRef) =>
          new File('$path/${cRef.id}/receptions/${id}.json').existsSync());

  /**
   *
   */
  Future<model.ReceptionContactReference> addToReception(
      model.ReceptionAttributes attr, model.User user) async {
    if (attr.receptionId == model.Reception.noId) {
      throw new ArgumentError('attr.receptionUuid must be valid');
    }
    final recDir = new Directory('$path/${attr.contactId}/receptions');
    if (!recDir.existsSync()) {
      recDir.createSync(recursive: true);
    }

    final File file = new File('${recDir.path}/${attr.receptionId}.json');

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

    await _git.add(file, 'Added ${attr.contactId} to ${attr.receptionId}',
        _authorString(user));

    return attr.reference;
  }

  /**
   *
   */
  Future<model.ContactReference> create(
      model.BaseContact contact, model.User modifier) async {
    if (contact.id == model.BaseContact.noId) {
      contact.id = _nextId;
    }
    final File file = new File('$path/${contact.id}.json');

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

    await _git.add(file, 'Added ${contact.id}', _authorString(modifier));

    return contact.reference;
  }

  /**
   *
   */
  Future<model.BaseContact> get(int id) async {
    final File file = new File('$path/${id}.json');

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
      int id, int receptionId) async {
    final file = new File('$path/$id/receptions/$receptionId.json');
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
      int receptionId) async {
    final subdirs =
        new Directory(path).listSync().where((fse) => fse is Directory);

    List<model.ReceptionAttributes> attrs = [];
    subdirs.forEach((Directory dir) {
      final attrFile = new File(dir.path + '/receptions/$receptionId.json');
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
      int organizationId) async {
    Iterable rRefs = await _receptionStore._receptionsOfOrg(organizationId);

    Set<model.ContactReference> contacts = new Set();

    await Future.wait(rRefs.map((rRef) async {
      contacts.addAll(await _contactsOfReception(rRef.id));
    }));

    return contacts;
  }

  /**
   *
   */
  Future<Iterable<model.OrganizationReference>> organizations(int id) async {
    Iterable<model.ReceptionReference> rRefs = await receptions(id);

    Set<model.OrganizationReference> orgs = new Set();
    await Future.wait(rRefs.map((rid) async {
      orgs.add(new model.OrganizationReference(
          (await _receptionStore.get(rid.id)).organizationId, ''));
    }));

    return orgs;
  }

  /**
   *
   */
  Future<Iterable<model.ReceptionReference>> receptions(int id) async {
    final File contactFile = new File('$path/${id}.json');
    if (!contactFile.existsSync()) {
      throw new storage.NotFound('No file: ${contactFile.path}');
    }

    final rDir = new Directory('$path/$id/receptions');
    if (!rDir.existsSync()) {
      return [];
    }

    Set<model.ReceptionReference> refs = new Set<model.ReceptionReference>();

    await Future.wait(rDir
        .listSync()
        .where((fse) => fse is File && fse.path.endsWith('.json'))
        .map((File file) async {
      int fileId = int.parse(basenameWithoutExtension(file.path));

      refs.add(new model.ReceptionReference(
          fileId, (await _receptionStore.get(fileId)).name));
    }));

    return refs;
  }

  /**
   *
   */
  Future remove(int id, model.User user) async {
    final File file = new File('$path/${id}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (user == null) {
      user = _systemUser;
    }

    await _git.remove(file, 'Removed $id', _authorString(user));
  }

  /**
   *
   */
  Future removeFromReception(
      int id, int receptionId, model.User modifier) async {
    if (id == model.BaseContact.noId || receptionId == model.Reception.noId) {
      throw new storage.ClientError('Empty id');
    }

    final recDir = new Directory('$path/${id}/receptions');
    final File file = new File('${recDir.path}/${receptionId}.json');
    if (!file.existsSync()) {
      throw new storage.NotFound('No file ${file}');
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    _log.finest('Removing file ${file.path}');

    await _git.remove(
        file, 'Removed ${id} from ${receptionId}', _authorString(modifier));
  }

  /**
   *
   */
  Future<model.BaseContact> update(
      model.BaseContact contact, model.User user) async {
    final File file = new File('$path/${contact.id}.json');

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
  Future<model.ReceptionContactReference> updateInReception(
      model.ReceptionAttributes attr, model.User modifier) async {
    if (attr.contactId == model.BaseContact.noId) {
      throw new storage.ClientError('Empty id');
    }
    final recDir = new Directory('$path/${attr.contactId}/receptions');
    final File file = new File('${recDir.path}/${attr.receptionId}.json');
    if (!file.existsSync()) {
      throw new storage.NotFound('No file ${file}');
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    _log.finest('Creating new file ${file.path}');
    file.writeAsStringSync(_jsonpp.convert(attr));

    await _git.add(file, 'Updated ${attr.contactId} in ${attr.receptionId}',
        _authorString(modifier));

    return attr.reference;
  }
}
