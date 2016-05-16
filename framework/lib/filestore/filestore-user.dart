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

class User implements storage.User {
  final Logger _log = new Logger('$libraryName.User');
  final String path;
  GitEngine _git;
  Sequencer _sequencer;

  Future get initialized => _git.initialized;
  Future get ready => _git.whenReady;

  int get _nextId => _sequencer.nextInt();

  /**
   *
   */
  User(String this.path, [GitEngine this._git]) {
    if (!new Directory(path).existsSync()) {
      new Directory(path).createSync();
    }

    if (this._git == null) {
      _git = new GitEngine(path);
    }
    _git.init();
    _sequencer = new Sequencer(path);
  }

  /**
   *
   */
  Future<Iterable<String>> groups() async => [
        model.UserGroups.administrator,
        model.UserGroups.receptionist,
        model.UserGroups.serviceAgent
      ];

  /**
   *
   */
  Future<model.User> get(int uid) async {
    final File file = new File('$path/${uid}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound('No file with name ${uid}');
    }

    try {
      final model.User user =
          model.User.decode(JSON.decode(file.readAsStringSync()));
      return user;
    } catch (e) {
      throw e;
    }
  }

  /**
   *
   */
  Future<model.User> getByIdentity(String identity) async {
    model.User user;
    await Future.wait((await list()).map((userRef) async {
      final u = await get(userRef.id);
      if (u.identities.contains(identity)) {
        user = u;
      }
    }));

    if (user == null) {
      throw new storage.NotFound('No user found with identity : $identity');
    }
    return user;
  }

  /**
   *
   */
  Future<Iterable<model.UserReference>> list() async => new Directory(path)
      .listSync()
      .where((fse) => fse is File && fse.path.endsWith('.json'))
      .map((FileSystemEntity fse) => model.User
          .decode(JSON.decode((fse as File).readAsStringSync()))
          .reference);

  /**
   *
   */
  Future<model.UserReference> create(
      model.User user, model.User modifier) async {
    user.id = _nextId;
    final File file = new File('$path/${user.id}.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(user));

    await _git.add(
        file,
        'uid:${modifier.id} - ${modifier.name} '
        'added ${user.id}',
        _authorString(modifier));

    return user.reference;
  }

  /**
   *
   */
  Future<Iterable<model.Commit>> changes([int uid]) async {
    FileSystemEntity fse;

    if (uid == null) {
      fse = new Directory('.');
    } else {
      fse = new File('$uid.json');
    }

    Iterable<Change> gitChanges = await _git.changes(fse);

    int extractUid(String message) => message.startsWith('uid:')
        ? int.parse(message.split(' ').first.replaceFirst('uid:', ''))
        : model.User.noId;

    model.UserChange convertFilechange(FileChange fc) {
      final int id = int.parse(fc.filename.split('.').first);

      return new model.UserChange(fc.changeType, id);
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
  Future<model.UserReference> update(
      model.User user, model.User modifier) async {
    final File file = new File('$path/${user.id}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(user));

    await _git.commit(
        file,
        'uid:${modifier.id} - ${modifier.name} '
        'updated ${user.id}',
        _authorString(modifier));

    return user.reference;
  }

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
}
