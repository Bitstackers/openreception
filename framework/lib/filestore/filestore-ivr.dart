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

class Ivr implements storage.Ivr {
  final Logger _log = new Logger('$libraryName.Ivr');
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
  Future<model.IvrMenu> create(model.IvrMenu menu, model.User modifier) async {
    final File file = new File('$path/${menu.name}.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(menu));

    await _git.add(
        file,
        'uid:${modifier.id} - ${modifier.name} '
        'added ${menu.name}',
        _authorString(modifier));

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
      .map((FileSystemEntity fse) =>
          model.IvrMenu.decode(JSON.decode((fse as File).readAsStringSync())));

  /**
   *
   */
  Future<model.IvrMenu> update(model.IvrMenu menu, model.User modifier) async {
    final File file = new File('$path/${menu.name}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(menu));

    await _git.commit(
        file,
        'uid:${modifier.id} - ${modifier.name} '
        'updated ${menu.name}',
        _authorString(modifier));

    return menu;
  }

  /**
   *
   */
  Future remove(String menuName, model.User modifier) async {
    final File file = new File('$path/${menuName}.json');

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
        'removed $menuName',
        _authorString(modifier));
  }

  /**
   *
   */
  Future<Iterable<model.Commit>> changes([String menuName]) async {
    FileSystemEntity fse;

    if (menuName == null) {
      fse = new Directory('.');
    } else {
      fse = new File('$menuName.json');
    }

    Iterable<Change> gitChanges = await _git.changes(fse);

    int extractUid(String message) => message.startsWith('uid:')
        ? int.parse(message.split(' ').first.replaceFirst('uid:', ''))
        : model.User.noId;

    model.ObjectChange convertFilechange(FileChange fc) {
      final List<String> parts = fc.filename.split('.');
      final String name = parts[0];

      return new model.IvrChange(fc.changeType, name);
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
