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

class Message implements storage.Message {
  final Logger _log = new Logger('$libraryName.Message');
  final String path;
  GitEngine _git;
  Sequencer _sequencer;

  Future get initialized => _git.initialized;
  Future get ready => _git.whenReady;

  int get _nextId => _sequencer.nextInt();
  /**
   *
   */
  Message({String this.path: 'json-data/message'}) {
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
  Future<model.Message> get(int mid) async {
    final File file = new File('$path/${mid}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound('No file with name ${mid}');
    }

    try {
      final String fileContents = file.readAsStringSync();
      final model.Message msg = model.Message.decode(JSON.decode(fileContents));
      return msg;
    } catch (e, s) {
      _log.shout('Failed to load file', e, s);
      throw e;
    }
  }

  /**
   *
   */
  Future<Iterable<model.Message>> list({model.MessageFilter filter}) async =>
      new Directory(path)
          .listSync()
          .where((fse) => fse is File && fse.path.endsWith('.json'))
          .map((FileSystemEntity fse) => model.Message
              .decode(JSON.decode((fse as File).readAsStringSync())))
          .where((model.Message msg) =>
              filter == null ? true : filter.appliesTo(msg));

  /**
   *
   */
  Future<model.Message> create(
      model.Message message, model.User modifier) async {
    message.id = _nextId;
    final File file = new File('$path/${message.id}.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(message));

    await _git.add(
        file,
        'uid:${modifier.id} - ${modifier.name} '
        'added ${message.id}',
        _authorString(modifier));

    return message;
  }

  /**
   *
   */
  Future<model.Message> update(
      model.Message message, model.User modifier) async {
    final File file = new File('$path/${message.id}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (modifier == null) {
      modifier = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(message));

    await _git.commit(
        file,
        'uid:${modifier.id} - ${modifier.name} '
        'updated ${message.id}',
        _authorString(modifier));

    return message;
  }

  /**
   *
   */
  Future remove(int mid, model.User modifier) async {
    final File file = new File('$path/${mid}.json');

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
        'removed $mid',
        _authorString(modifier));
  }

  /**
   *
   */
  Future<Iterable<model.Commit>> changes([int mid]) async {
    FileSystemEntity fse;

    if (mid == null) {
      fse = new Directory('.');
    } else {
      fse = new File('$mid.json');
    }

    Iterable<Change> gitChanges = await _git.changes(fse);

    int extractUid(String message) => message.startsWith('uid:')
        ? int.parse(message.split(' ').first.replaceFirst('uid:', ''))
        : model.User.noId;

    model.MessageChange convertFilechange(FileChange fc) {
      final int id = int.parse(fc.filename.split('.').first);

      return new model.MessageChange(fc.changeType, id);
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
