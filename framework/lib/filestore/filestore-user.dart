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
  final GitEngine _git;
  final Sequencer _sequencer;
  final bool logChanges;
  final Directory trashDir;

  Bus<event.UserChange> _changeBus = new Bus<event.UserChange>();
  Stream<event.UserChange> get onUserChange => _changeBus.stream;

  Future get initialized =>
      _git != null ? _git.initialized : new Future.value(true);
  Future get ready => _git != null ? _git.whenReady : new Future.value(true);

  int get _nextId => _sequencer.nextInt();

  /**
   *
   */
  factory User(String path, [GitEngine gitEngine, bool enableChangelog]) {
    if (!new Directory(path).existsSync()) {
      new Directory(path).createSync();
    }

    final sequencer = new Sequencer(path);

    if (gitEngine != null) {
      gitEngine.init().catchError((error, stackTrace) => Logger.root
          .shout('Failed to initialize git engine', error, stackTrace));
      gitEngine.addIgnoredPath(sequencer.sequencerFilePath);
    }

    final Directory trashDir = new Directory(path + '/.trash');
    if (!trashDir.existsSync()) {
      trashDir.createSync();
    }

    return new User._internal(path, sequencer, gitEngine,
        (enableChangelog != null) ? enableChangelog : true, trashDir);
  }

  /**
   *
   */
  User._internal(
      this.path, this._sequencer, this._git, this.logChanges, this.trashDir);

  /**
   *
   */
  @override
  Future<Iterable<String>> groups() async => [
        model.UserGroups.administrator,
        model.UserGroups.receptionist,
        model.UserGroups.serviceAgent
      ];

  /**
   *
   */
  @override
  Future<model.User> get(int uid) async {
    final File file = new File('$path/${uid}/user.json');

    if (!file.existsSync()) {
      throw new storage.NotFound('No file with name ${file.path}');
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
  @override
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
  @override
  Future<Iterable<model.UserReference>> list() async => new Directory(path)
      .listSync()
      .where((fse) =>
          isDirectory(fse) && new File(fse.path + '/user.json').existsSync())
      .map((FileSystemEntity fse) => model.User
          .decode(
              JSON.decode(new File(fse.path + '/user.json').readAsStringSync()))
          .reference);

  /**
   *
   */
  @override
  Future<model.UserReference> create(model.User user, model.User modifier,
      {bool enforceId: false}) async {
    user.id = user.id != model.User.noId && enforceId ? user.id : _nextId;

    final Directory userdir = new Directory('$path/${user.id}')..createSync();
    final File file = new File('${userdir.path}/user.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    file.writeAsStringSync(_jsonpp.convert(user));

    if (this._git != null) {
      await _git.add(
          file,
          'uid:${modifier.id} - ${modifier.name} '
          'added ${user.id}',
          _authorString(modifier));
    }

    if (logChanges) {
      new ChangeLogger(userdir.path)
          .add(new model.UserChangelogEntry.create(modifier.reference, user));
    }

    _changeBus.fire(new event.UserChange.create(user.id, modifier.id));

    return user.reference;
  }

  /**
   *
   */
  @override
  Future<Iterable<model.Commit>> changes([int uid]) async {
    if (this._git == null) {
      throw new UnsupportedError(
          'Filestore is instantiated without git support');
    }

    FileSystemEntity fse;

    if (uid == null) {
      fse = new Directory('.');
    } else {
      fse = new File('$uid/user.json');
    }

    Iterable<Change> gitChanges = await _git.changes(fse);

    int extractUid(String message) => message.startsWith('uid:')
        ? int.parse(message.split(' ').first.replaceFirst('uid:', ''))
        : model.User.noId;

    model.UserChange convertFilechange(FileChange fc) {
      final int id = int.parse(fc.filename.split('/').first);

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
  @override
  Future<model.UserReference> update(
      model.User user, model.User modifier) async {
    final Directory userdir = new Directory('$path/${user.id}');
    final File file = new File('${userdir.path}/user.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    file.writeAsStringSync(_jsonpp.convert(user));

    if (this._git != null) {
      await _git.commit(
          file,
          'uid:${modifier.id} - ${modifier.name} '
          'updated ${user.id}',
          _authorString(modifier));
    }

    if (logChanges) {
      new ChangeLogger(userdir.path)
          .add(new model.UserChangelogEntry.update(modifier.reference, user));
    }

    _changeBus.fire(new event.UserChange.update(user.id, modifier.id));

    return user.reference;
  }

  /**
   *
   */
  @override
  Future remove(int uid, model.User modifier) async {
    final Directory userdir = new Directory('$path/${uid}');

    if (!userdir.existsSync()) {
      throw new storage.NotFound();
    }

    if (this._git != null) {
      await _git.remove(
          userdir,
          'uid:${modifier.id} - ${modifier.name} '
          'removed $uid',
          _authorString(modifier));
    }

    if (logChanges) {
      new ChangeLogger(userdir.path)
          .add(new model.UserChangelogEntry.delete(modifier.reference, uid));
    }
    await userdir.rename(trashDir.path + '/${uid}');

    _changeBus.fire(new event.UserChange.delete(uid, modifier.id));
  }

  /**
   *
   */
  Future<String> changeLog(int uid) async =>
      logChanges ? new ChangeLogger('$path/$uid').contents() : '';
}
