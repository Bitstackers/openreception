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

class Calendar implements storage.Calendar {
  final Logger _log = new Logger('$libraryName.Calendar');
  final String path;
  GitEngine _git;

  Future get initialized => _git.initialized;
  Future get ready => _git.whenReady;

  /**
   *
   */
  Ivr({String this.path: 'json-data/ivr'}) {
    _git = new GitEngine(path);
    _git.init();
  }

  /**
   *
   */
  Future<model.IvrMenu> create(model.IvrMenu menu, [model.User user]) async {
    final File file = new File('$path/${menu.name}.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    /// Set the user
    if (user == null) {
      user = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(menu));

    await _git.add(file, 'Added ${menu.name}', _authorString(user));

    return menu;
  }

  /**
   *
   */
  Future<model.IvrMenu> get(String menuName) async {
    final File file = new File('$path/${menuName}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound('No file with name ${menuName}');
    }

    try {
      final model.IvrMenu menu =
          model.IvrMenu.decode(JSON.decode(file.readAsStringSync()));
      return menu;
    } catch (e) {
      throw e;
    }
  }

  /**
   *
   */
  Future<Iterable<model.IvrMenu>> list() async => new Directory(path)
      .listSync()
      .where((fse) => fse is File && fse.path.endsWith('.json'))
      .map((File fse) =>
          model.IvrMenu.decode(JSON.decode(fse.readAsStringSync())));

  /**
   *
   */
  Future<model.IvrMenu> update(model.IvrMenu menu, [model.User user]) async {
    final File file = new File('$path/${menu.name}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (user == null) {
      user = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(menu));

    await _git._commit('Updated ${menu.name}', _authorString(user));

    return menu;
  }

  /**
   *
   */
  Future remove(String menuName, [model.User user]) async {
    final File file = new File('$path/${menuName}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (user == null) {
      user = _systemUser;
    }

    await _git.remove(file, 'Removed $menuName', _authorString(user));
  }
}
