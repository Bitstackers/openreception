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

class ReceptionDialplan implements storage.ReceptionDialplan {
  final Logger _log = new Logger('$libraryName.ReceptionDialplan');
  final String path;
  GitEngine _git;

  Future get initialized => _git.initialized;
  Future get ready => _git.whenReady;

  /**
   *
   */
  ReceptionDialplan({String this.path: 'json-data/dialplan'}) {
    _git = new GitEngine(path);
    _git.init();
  }

  /**
   *
   */
  Future<model.ReceptionDialplan> create(model.ReceptionDialplan rdp,
      [model.User user]) async {
    final File file = new File('$path/${rdp.extension}.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    /// Set the user
    if (user == null) {
      user = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(rdp));

    await _git.add(file, 'Added ${rdp.extension}', _authorString(user));

    return rdp;
  }

  /**
   *
   */
  Future<model.ReceptionDialplan> get(String extension) async {
    final File file = new File('$path/${extension}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound('No file with name ${extension}');
    }

    try {
      final model.ReceptionDialplan rdp =
          model.ReceptionDialplan.decode(JSON.decode(file.readAsStringSync()));
      return rdp;
    } catch (e) {
      throw e;
    }
  }

  /**
   *
   */
  Future<Iterable<model.ReceptionDialplan>> list() async => new Directory(path)
      .listSync()
      .where((fse) => fse is File && fse.path.endsWith('.json'))
      .map((File fse) =>
          model.ReceptionDialplan.decode(JSON.decode(fse.readAsStringSync())));

  /**
   *
   */
  Future<model.ReceptionDialplan> update(model.ReceptionDialplan rdp,
      [model.User user]) async {
    final File file = new File('$path/${rdp.extension}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (user == null) {
      user = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(rdp));

    await _git._commit('Updated ${rdp.extension}', _authorString(user));

    return rdp;
  }

  /**
   *
   */
  Future remove(String extension, [model.User user]) async {
    final File file = new File('$path/${extension}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (user == null) {
      user = _systemUser;
    }

    await _git.remove(file, 'Removed $extension', _authorString(user));
  }
}
