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
  Future addData(model.ReceptionAttributes attr, model.User modifier) async {
    if (attr.receptionId == model.Reception.noId) {
      throw new ArgumentError('attr.receptionId must be valid');
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
    if (modifier == null) {
      modifier = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(attr));
    _log.finest('Created new file ${file.path}');

    await _git.add(
        file,
        'uid:${modifier.id} - ${modifier.name} '
        'added ${attr.contactId} to ${attr.receptionId}',
        _authorString(modifier));
  }

  /**
   *
   */
  Future<model.ContactReference> create(
      model.BaseContact contact, model.User modifier) async {
    if (contact.id == model.BaseContact.noId) {
      contact.id = _nextId;
    }
    final Directory dir = new Directory('$path/${contact.id}');

    if (dir.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    dir.createSync();
    final File file = new File('${dir.path}/contact.json');

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    _log.finest('Creating new file ${file.path}');
    file.writeAsStringSync(_jsonpp.convert(contact));

    await _git.add(
        file,
        'uid:${modifier.id} - ${modifier.name} '
        'added ${contact.id}',
        _authorString(modifier));

    return contact.reference;
  }

  /**
   *
   */
  Future<model.BaseContact> get(int id) async {
    final File file = new File('$path/${id}/contact.json');

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
  Future<model.ReceptionAttributes> data(int id, int receptionId) async {
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
        .where((fse) => fse is Directory && !basename(fse.path).startsWith('.'))
        .map((FileSystemEntity fse) => model.BaseContact
            .decode(JSON.decode(
                new File(fse.path + '/contact.json').readAsStringSync()))
            .reference);
  }

  /**
   *
   */
  Future<Iterable<model.ReceptionReference>> receptions(int cid) async {
    final rDir = new Directory(path + '/$cid/receptions');
    if (!rDir.existsSync()) {
      return [];
    }

    final rFiles = rDir
        .listSync()
        .where((fse) => fse is File && fse.path.endsWith('.json'));

    return await Future.wait(rFiles.map((FileSystemEntity f) async {
      final int rid = int.parse(basenameWithoutExtension(f.path));

      return (await _receptionStore.get(rid)).reference;
    }));
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
  Future<Iterable<model.OrganizationReference>> organizations(int cid) async {
    Iterable<model.ReceptionReference> rRefs = await receptions(cid);

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
  Future<Iterable<model.ContactReference>> receptionContacts(int rid) async {
    final subDirs =
        new Directory(path).listSync().where((fse) => fse is Directory);

    List<model.ContactReference> refs = [];
    await Future.forEach((subDirs), (dir) async {
      if (new File(dir.path + '/receptions/$rid.json').existsSync()) {
        final String bn = basename(dir.path);
        if (!bn.startsWith('.')) {
          refs.add((await get(int.parse(bn))).reference);
        }
      }
    });

    return refs;
  }

  /**
   *
   */
  Future remove(int id, model.User modifier) async {
    final Directory dir = new Directory('$path/${id}');

    if (!dir.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    await _git.remove(
        dir,
        'uid:${modifier.id} - ${modifier.name} '
        'removed $id',
        _authorString(modifier));
  }

  /**
   *
   */
  Future removeData(int id, int receptionId, model.User modifier) async {
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
        file,
        'uid:${modifier.id} - ${modifier.name} '
        'removed ${id} from ${receptionId}',
        _authorString(modifier));
  }

  /**
   *
   */
  Future<model.ContactReference> update(
      model.BaseContact contact, model.User modifier) async {
    final File file = new File('$path/${contact.id}/contact.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(contact));

    await _git.add(
        file,
        'uid:${modifier.id} - ${modifier.name} '
        'updated ${contact.name}',
        _authorString(modifier));

    return contact.reference;
  }

  /**
   *
   */
  Future updateData(model.ReceptionAttributes attr, model.User modifier) async {
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

    await _git.add(
        file,
        'uid:${modifier.id} - ${modifier.name} '
        'updated ${attr.contactId} in ${attr.receptionId}',
        _authorString(modifier));
  }

  /**
   *
   */
  Future<Iterable<model.Commit>> changes([int cid, int rid]) async {
    FileSystemEntity fse;

    if (cid == null) {
      fse = new Directory('.');
    } else {
      if (rid == null) {
        fse = new Directory('$cid');
      } else {
        fse = new Directory('$cid/receptions/$rid.json');
      }
    }

    Iterable<Change> gitChanges = await _git.changes(fse);

    int extractUid(String message) => message.startsWith('uid:')
        ? int.parse(message.split(' ').first.replaceFirst('uid:', ''))
        : model.User.noId;

    model.ObjectChange convertFilechange(FileChange fc) {
      final List<String> parts = fc.filename.split('/');
      final int id = int.parse(parts[0]);

      if (parts.last == 'contact.json') {
        return new model.ContactChange(fc.changeType, id);
      } else if (parts.length > 2 && parts[1] == 'receptions') {
        final int rid = int.parse(parts[2].split('.').first);
        return new model.ReceptionAttributeChange(fc.changeType, id, rid);
      } else {
        throw new StateError('Could not parse filechange ${fc.toJson()}');
      }
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
