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
  User({String this.path: 'json-data/user'}) {
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
  Future<model.User> get(int id) async {
    final File file = new File('$path/${id}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound('No file with name ${id}');
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
  Future<model.User> getByIdentity(String identity) =>
      throw new UnimplementedError();

  /**
   *
   */
  Future<Iterable<model.User>> list() async => new Directory(path)
      .listSync()
      .where((fse) => fse is File && fse.path.endsWith('.json'))
      .map(
          (File fse) => model.User.decode(JSON.decode(fse.readAsStringSync())));

  /**
   *
   */
  Future<model.User> create(model.User user, model.User modifier) async {
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

    await _git.add(file, 'Added ${user.id}', _authorString(modifier));

    return user;
  }

  /**
   *
   */
  Future<model.User> update(model.User user, model.User modifier) async {
    final File file = new File('$path/${user.id}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(user));

    await _git._commit('Updated ${user.id}', _authorString(modifier));

    return user;
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

    await _git.remove(file, 'Removed $id', _authorString(modifier));
  }
}
