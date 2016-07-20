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

class ReceptionDialplan implements storage.ReceptionDialplan {
  final Logger _log = new Logger('$libraryName.ReceptionDialplan');
  final String path;
  GitEngine _git;
  final bool logChanges;
  final Directory trashDir;

  Bus<event.DialplanChange> _changeBus = new Bus<event.DialplanChange>();
  Stream<event.DialplanChange> get onChange => _changeBus.stream;

  Future get initialized =>
      _git != null ? _git.initialized : new Future.value(true);
  Future get ready => _git != null ? _git.whenReady : new Future.value(true);

  /**
   * TODO: Add sequencer.
   */
  factory ReceptionDialplan(String path,
      [GitEngine gitEngine, bool enableChangelog]) {
    if (!new Directory(path).existsSync()) {
      new Directory(path).createSync();
    }
    if (gitEngine != null) {
      gitEngine.init().catchError((error, stackTrace) => Logger.root
          .shout('Failed to initialize git engine', error, stackTrace));
    }

    final Directory trashDir = new Directory(path + '/.trash');
    if (!trashDir.existsSync()) {
      trashDir.createSync();
    }

    return new ReceptionDialplan._internal(path, gitEngine,
        (enableChangelog != null) ? enableChangelog : true, trashDir);
  }

  /**
   *
   */
  ReceptionDialplan._internal(String this.path,
      [GitEngine this._git, bool this.logChanges, this.trashDir]);

  /**
   *
   */
  @override
  Future<model.ReceptionDialplan> create(
      model.ReceptionDialplan rdp, model.User modifier) async {
    final Directory dialplanDir = new Directory('$path/${rdp.extension}')
      ..createSync();
    final File file = new File('$path/${rdp.extension}/dialplan.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    file.writeAsStringSync(_jsonpp.convert(rdp));

    if (this._git != null) {
      await _git.add(
          file,
          'uid:${modifier.id} - ${modifier.name} '
          'added ${rdp.extension}',
          _authorString(modifier));
    }

    if (logChanges) {
      new ChangeLogger(dialplanDir.path).add(
          new model.DialplanChangelogEntry.create(modifier.reference, rdp));
    }

    _changeBus
        .fire(new event.DialplanChange.create(rdp.extension, modifier.id));

    return rdp;
  }

  /**
   *
   */
  @override
  Future<model.ReceptionDialplan> get(String extension) async {
    final File file = new File('$path/${extension}/dialplan.json');

    if (!file.existsSync()) {
      throw new storage.NotFound('No file with name ${file.path}');
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
  @override
  Future<Iterable<model.ReceptionDialplan>> list() async {
    final Iterable dirs = new Directory(path).listSync().where((fse) =>
        isDirectory(fse) && new File(fse.path + '/dialplan.json').existsSync());

    return dirs.map((Directory fse) {
      final String fileContents =
          new File(fse.path + '/dialplan.json').readAsStringSync();

      return model.ReceptionDialplan.decode(JSON.decode(fileContents));
    });
  }

  /**
   *
   */
  @override
  Future<model.ReceptionDialplan> update(
      model.ReceptionDialplan rdp, model.User modifier) async {
    final Directory dialplanDir = new Directory('$path/${rdp.extension}');

    final File file = new File('$path/${rdp.extension}/dialplan.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    file.writeAsStringSync(_jsonpp.convert(rdp));

    if (this._git != null) {
      await _git.commit(
          file,
          'uid:${modifier.id} - ${modifier.name} '
          'updated ${rdp.extension}',
          _authorString(modifier));
    }

    if (logChanges) {
      new ChangeLogger(dialplanDir.path).add(
          new model.DialplanChangelogEntry.update(modifier.reference, rdp));
    }

    _changeBus
        .fire(new event.DialplanChange.update(rdp.extension, modifier.id));

    return rdp;
  }

  /**
   *
   */
  @override
  Future remove(String extension, model.User modifier) async {
    final Directory dialplanDir = new Directory('$path/${extension}');

    final File file = new File('$path/${extension}/dialplan.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    if (this._git != null) {
      await _git.remove(
          file,
          'uid:${modifier.id} - ${modifier.name} '
          'removed $extension',
          _authorString(modifier));
    } else {
      if (logChanges) {
        new ChangeLogger(dialplanDir.path).add(
            new model.DialplanChangelogEntry.delete(
                modifier.reference, extension));
      }

      await dialplanDir.rename(trashDir.path +
          '/${extension}-${new DateTime.now().millisecondsSinceEpoch}');
    }

    _changeBus.fire(new event.DialplanChange.delete(extension, modifier.id));
  }

  /**
   *
   */
  @override
  Future<Iterable<model.Commit>> changes([String extension]) async {
    if (this._git == null) {
      throw new UnsupportedError(
          'Filestore is instantiated without git support');
    }

    FileSystemEntity fse;

    if (extension == null) {
      fse = new Directory('.');
    } else {
      fse = new File('$extension/dialplan.json');
    }

    Iterable<Change> gitChanges = await _git.changes(fse);

    int extractUid(String message) => message.startsWith('uid:')
        ? int.parse(message.split(' ').first.replaceFirst('uid:', ''))
        : model.User.noId;

    model.ObjectChange convertFilechange(FileChange fc) {
      final List<String> parts = fc.filename.split('/');
      final String name = parts[0];

      return new model.ReceptionDialplanChange(fc.changeType, name);
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
  Future<String> changeLog(String extension) async =>
      logChanges ? new ChangeLogger('$path/$extension').contents() : '';
}
