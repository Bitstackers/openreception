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

class Message implements storage.Message {
  final Logger _log = new Logger('$libraryName.Message');
  final String path;
  GitEngine _git;
  Sequencer _sequencer;
  final Map<int, String> _index = {};
  final Map<int, Set<int>> _cidIndex = {};
  final Map<int, Set<int>> _uidIndex = {};
  final Map<int, Set<int>> _ridIndex = {};
  final Set<int> _draftsIndex = new Set<int>();

  Future get initialized =>
      _git != null ? _git.initialized : new Future.value(true);
  Future get ready => _git != null ? _git.whenReady : new Future.value(true);

  final Bus<event.MessageChange> _changeBus = new Bus<event.MessageChange>();
  Stream<event.MessageChange> get changeStream => _changeBus.stream;

  int get _nextId => _sequencer.nextInt();
  /**
   * 
   */
  Message(String this.path, [GitEngine this._git]) {
    if (!new Directory(path).existsSync()) {
      new Directory(path).createSync();
    }

    if (this._git != null) {
      _git.init().catchError((error, stackTrace) => Logger.root
          .shout('Failed to initialize git engine', error, stackTrace));
    }

    _buildIndex();
  }

  /**
   *
   */
  Directory _dateDir(DateTime day) =>
      new Directory('$path/${day.toIso8601String().split('T').first}');

  /**
   * Rebuilds the entire index.
   */
  void _buildIndex() {
    int highestId = 0;
    Stopwatch timer = new Stopwatch()..start();
    _log.info('Building primary index');
    Iterable<Directory> dateDirs =
        new Directory(path).listSync().where(isDirectory);

    dateDirs.forEach((fse) {
      Iterable<File> files = fse.listSync().where(isJsonFile);
      files.forEach((file) {
        try {
          final id = int.parse(basenameWithoutExtension(file.path));
          _index[id] = file.path;

          if (id > highestId) {
            highestId = id;
          }
        } catch (e) {
          _log.shout('Failed load index from file ${file.path}');
        }
      });
    });

    _log.info('Built primary index of ${_index.keys.length} elements in'
        ' ${timer.elapsedMilliseconds}ms');
    _sequencer = new Sequencer(path, explicitId: highestId);

    if (_git != null) {
      _git.addIgnoredPath(_sequencer.sequencerFilePath);
    }
  }

  /**
   *
   */
  Future rebuildSecondaryIndexes() async {
    Stopwatch timer = new Stopwatch()..start();
    _log.info('Building secondary indexes');
    await Future.forEach(_index.keys, (int id) async {
      final model.Message msg = await get(id);
      final cidList = _cidIndex.containsKey(msg.context.cid)
          ? _cidIndex[msg.context.cid]
          : _cidIndex[msg.context.cid] = new Set<int>();

      final uidList = _uidIndex.containsKey(msg.sender.id)
          ? _uidIndex[msg.sender.id]
          : _uidIndex[msg.sender.id] = new Set<int>();

      final ridList = _ridIndex.containsKey(msg.context.rid)
          ? _ridIndex[msg.context.rid]
          : _ridIndex[msg.context.rid] = new Set<int>();

      cidList.add(msg.id);
      uidList.add(msg.id);
      ridList.add(msg.id);

      if (msg.isDraft) {
        _draftsIndex.add(msg.id);
      }
    });

    _log.info('Built secondary indexes of '
        '${_cidIndex.keys.length} contact id\'s, '
        '${_uidIndex.keys.length} user id\'s and '
        '${_ridIndex.keys.length} reception id\'s in '
        '${timer.elapsedMilliseconds}ms. '
        'Found ${_draftsIndex.length} saved messages');
  }

  /**
   *
   */
  @override
  Future<model.Message> get(int mid) async {
    if (!_index.containsKey(mid)) {
      throw new storage.NotFound('No index key with mid $mid');
    }

    final File file = new File(_index[mid]);

    if (!file.existsSync()) {
      throw new storage.NotFound('No file with mid $mid');
    }

    try {
      final String fileContents = await file.readAsString();
      final model.Message msg = model.Message.decode(JSON.decode(fileContents));
      return msg;
    } catch (e, s) {
      _log.shout('Failed to load file ${file.path}', e, s);
      throw e;
    }
  }

  @override
  Future<Iterable<model.Message>> getByIds(Iterable<int> ids) async {
    List<model.Message> list = new List<model.Message>();

    await Future.forEach(ids, (id) async {
      try {
        list.add(await get(id));
      } on storage.NotFound {
        // Ignore the non-found element.
      } catch (e, s) {
        _log.shout('Failed to retrieve element with id $id', e, s);
      }
    });

    return list;
  }

  /**
   *
   */
  Iterable<int> _idsOfDir(Directory dir) {
    Iterable<File> files = dir.listSync().where(isFile);
    List<int> list = [];
    files.forEach((file) {
      try {
        list.add(int.parse(basenameWithoutExtension(file.path)));
      } catch (e) {
        _log.shout('Failed load index from file ${file.path}');
      }
    });
    return list;
  }

  /**
   *
   */
  @override
  Future<Iterable<model.Message>> listDay(DateTime day) async {
    final Directory dateDir = _dateDir(day);

    if (!await dateDir.exists()) {
      return [];
    }

    Set<int> ids = _idsOfDir(dateDir).toSet();

    return getByIds(ids);
  }

  /**
   *
   */
  @override
  Future<Iterable<model.Message>> listDrafts() async {
    Set<int> ids = new Set()..addAll(_draftsIndex);

    return getByIds(ids);
  }

  /**
   *
   */
  Future<Iterable<int>> midsOfUid(int uid) async {
    if (_uidIndex.containsKey(uid)) {
      return _uidIndex[uid];
    } else {
      return [];
    }
  }

  /**
   *
   */
  Future<Iterable<int>> midsOfCid(int cid) async {
    if (_cidIndex.containsKey(cid)) {
      return _cidIndex[cid];
    } else {
      return [];
    }
  }

  /**
   *
   */
  Future<Iterable<int>> midsOfRid(int rid) async {
    if (_ridIndex.containsKey(rid)) {
      return _ridIndex[rid];
    } else {
      return [];
    }
  }

  /**
   *
   */
  @override
  Future<model.Message> create(model.Message msg, model.User modifier,
      {bool enforceId: false}) async {
    Directory dateDir = _dateDir(msg.createdAt)..createSync();

    if (!(msg.id != model.Message.noId && enforceId)) {
      msg
        ..id = _nextId
        ..createdAt = new DateTime.now();
    }

    final File file = new File('${dateDir.path}/${msg.id}.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    file.writeAsStringSync(_jsonpp.convert(msg));

    /// Update indexes.
    _index[msg.id] = file.path;
    final cidList = _cidIndex.containsKey(msg.context.cid)
        ? _cidIndex[msg.context.cid]
        : _cidIndex[msg.context.cid] = new Set<int>();

    final uidList = _uidIndex.containsKey(msg.sender.id)
        ? _uidIndex[msg.sender.id]
        : _uidIndex[msg.sender.id] = new Set<int>();

    final ridList = _ridIndex.containsKey(msg.context.rid)
        ? _ridIndex[msg.context.rid]
        : _ridIndex[msg.context.rid] = new Set<int>();

    cidList.add(msg.id);
    uidList.add(msg.id);
    ridList.add(msg.id);

    if (msg.isDraft) {
      _draftsIndex.add(msg.id);
    }

    if (this._git != null) {
      await _git.add(
          file,
          'uid:${modifier.id} - ${modifier.name} '
          'added ${msg.id}',
          _authorString(modifier));
    }

    _changeBus.fire(new event.MessageChange.create(
        msg.id, modifier.id, msg.state, msg.createdAt));

    return msg;
  }

  /**
   *
   */
  @override
  Future<model.Message> update(model.Message msg, model.User modifier) async {
    final File file = new File(_index[msg.id]);

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    file.writeAsStringSync(_jsonpp.convert(msg));

    if (this._git != null) {
      await _git.commit(
          file,
          'uid:${modifier.id} - ${modifier.name} '
          'updated ${msg.id}',
          _authorString(modifier));
    }

    if (msg.isDraft) {
      _draftsIndex.add(msg.id);
    } else {
      _draftsIndex.remove(msg.id);
    }

    _changeBus.fire(new event.MessageChange.update(
        msg.id, modifier.id, msg.state, msg.createdAt));
    return msg;
  }

  /**
   *
   */
  @override
  Future remove(int mid, model.User modifier) async {
    if (!_index.containsKey(mid)) {
      throw new storage.NotFound('No index key with mid $mid');
    }

    final File file = new File(_index[mid]);

    final model.Message msg = await get(mid);

    if (this._git != null) {
      await _git.remove(
          file,
          'uid:${modifier.id} - ${modifier.name} '
          'removed $mid',
          _authorString(modifier));
    } else {
      file.deleteSync();
    }

    _index.remove(mid);
    _draftsIndex.remove(mid);

    _changeBus.fire(new event.MessageChange.delete(
        mid, modifier.id, msg.state, msg.createdAt));
  }

  /**
   *
   */
  @override
  Future<Iterable<model.Commit>> changes([int mid]) async {
    if (this._git == null) {
      throw new UnsupportedError(
          'Filestore is instantiated without git support');
    }

    FileSystemEntity fse;

    if (mid == null) {
      fse = new Directory('.');
    } else {
      fse = new File(_index[mid]);
    }

    Iterable<Change> gitChanges = await _git.changes(fse);

    int extractUid(String message) => message.startsWith('uid:')
        ? int.parse(message.split(' ').first.replaceFirst('uid:', ''))
        : model.User.noId;

    model.MessageChange convertFilechange(FileChange fc) {
      final int id = int.parse(fc.filename.split('/').last.split('.').first);

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

  /**
   *
   */
  Future<Iterable<model.Commit>> changesByDay(DateTime day, [int mid]) async {
    if (this._git == null) {
      throw new UnsupportedError(
          'Filestore is instantiated without git support');
    }

    FileSystemEntity fse;

    if (mid == null) {
      fse = _dateDir(day);
    } else {
      fse = new File(_index[mid]);
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
