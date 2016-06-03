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

class Organization implements storage.Organization {
  final Logger _log = new Logger('$libraryName.Organization');
  final String path;
  final Contact _contactFileStore;
  final Reception _receptionFileStore;
  GitEngine _git;
  Sequencer _sequencer;

  Future get initialized =>
      _git != null ? _git.initialized : new Future.value(true);
  Future get ready => _git != null ? _git.whenReady : new Future.value(true);

  int get _nextId => _sequencer.nextInt();

  /**
   *
   */
  Organization(
      this._contactFileStore, this._receptionFileStore, String this.path,
      [GitEngine this._git]) {
    if (!new Directory(path).existsSync()) {
      new Directory(path).createSync();
    }

    _sequencer = new Sequencer(path);
    if (this._git != null) {
      _git.init().catchError((error, stackTrace) => Logger.root
          .shout('Failed to initialize git engine', error, stackTrace));
      _git.addIgnoredPath(_sequencer._sequencerFile.path);
    }
  }

  /**
   *
   */
  Future<Map<String, Map<String, String>>> receptionMap() =>
      throw new UnimplementedError();

  /**
   *
   */
  Future<Iterable<model.BaseContact>> contacts(int id) async {
    List<model.BaseContact> cRefs = [];
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
      model.Organization org, model.User modifier,
      {bool enforceId: false}) async {
    if (org.id == null) {
      throw new storage.ClientError(
          new ArgumentError.notNull(org.id.toString()).toString());
    }
    org.id = org.id != model.Organization.noId && enforceId ? org.id : _nextId;

    final File file = new File('$path/${org.id}.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    file.writeAsStringSync(_jsonpp.convert(org));

    if (this._git != null) {
      await _git.add(
          file,
          'uid:${modifier.id} - ${modifier.name} '
          'added ${org.name}',
          _authorString(modifier));
    }

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
          .map((FileSystemEntity fse) => model.Organization
              .decode(JSON.decode((fse as File).readAsStringSync()))
              .reference);

  /**
   *
   */
  Future remove(int id, model.User modifier) async {
    final File file = new File('$path/${id}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    if (this._git != null) {
      await _git.remove(
          file,
          'uid:${modifier.id} - ${modifier.name} '
          'removed $id',
          _authorString(modifier));
    } else {
      file.deleteSync();
    }
  }

  /**
   *
   */
  Future<model.OrganizationReference> update(
      model.Organization org, model.User modifier) async {
    final File file = new File('$path/${org.id}.json');

    if (org.id == model.Organization.noId) {
      throw new storage.ClientError('uuid may not be "noId"');
    }

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    file.writeAsStringSync(_jsonpp.convert(org));

    if (this._git != null) {
      await _git.commit(
          file,
          'uid:${modifier.id} - ${modifier.name} '
          'updated ${org.name}',
          _authorString(modifier));
    }

    return org.reference;
  }

  /**
   *
   */
  Future<Iterable<model.ReceptionReference>> receptions(int uuid) =>
      _receptionFileStore._receptionsOfOrg(uuid);

  /**
       *
       */
  Future<Iterable<model.Commit>> changes([int oid]) async {
    if (this._git == null) {
      throw new UnsupportedError(
          'Filestore is instantiated without git support');
    }

    FileSystemEntity fse;

    if (oid == null) {
      fse = new Directory('.');
    } else {
      fse = new File('$oid.json');
    }

    Iterable<Change> gitChanges = await _git.changes(fse);

    int extractUid(String message) => message.startsWith('uid:')
        ? int.parse(message.split(' ').first.replaceFirst('uid:', ''))
        : model.User.noId;

    model.OrganizationChange convertFilechange(FileChange fc) {
      final int id = int.parse(fc.filename.split('.').first);

      return new model.OrganizationChange(fc.changeType, id);
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
