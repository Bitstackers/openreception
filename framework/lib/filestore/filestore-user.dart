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

  Future get initialized => _git.initialized;
  Future get ready => _git.whenReady;

  String get _newUuid => _uuid.v4();

  /**
   *
   */
  User({String this.path: 'json-data/user'}) {
    _git = new GitEngine(path);
    _git.init();
  }

  /**
   *
   */
  Future<model.User> get(String uuid) async {
    final File file = new File('$path/${uuid}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound('No file with name ${uuid}');
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
  Future<model.User> getByIdentity(String identity) => get(identity);

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
    user.uuid = _newUuid;
    final File file = new File('$path/${user.uuid}.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(user));

    await _git.add(file, 'Added ${user.uuid}', _authorString(modifier));

    return user;
  }

  /**
   *
   */
  Future<model.User> update(model.User user, model.User modifier) async {
    final File file = new File('$path/${user.uuid}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(user));

    await _git._commit('Updated ${user.uuid}', _authorString(modifier));

    return user;
  }

  /**
   *
   */
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
}
