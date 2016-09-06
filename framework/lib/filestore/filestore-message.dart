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

/// File-based storage backed for [model.Message] objects.
class Message implements storage.Message {
  /// Internal logger
  final Logger _log = new Logger('$_libraryName.Message');

  /// Directory path to where the serialized [model.Message] objects are
  /// stored.
  final String path;

  /// Revision engine.
  GitEngine _git;

  /// Internal sequencer.
  Sequencer _sequencer;

  /// Index of message ID to message file path.
  final Map<int, String> _index = <int, String>{};

  /// Index of contact ID to message ID's.
  final Map<int, Set<int>> _cidIndex = <int, Set<int>>{};

  /// Index of user ID to message ID's.
  final Map<int, Set<int>> _uidIndex = <int, Set<int>>{};

  /// Index of reception ID to message ID's.
  final Map<int, Set<int>> _ridIndex = <int, Set<int>>{};

  /// Index of all messages currently stored as drafts.
  final Set<int> _draftsIndex = new Set<int>();

  /// Internal bus for injecting changes into.
  final Bus<event.MessageChange> _changeBus = new Bus<event.MessageChange>();

  /// Default Constructor.
  Message(String this.path, [GitEngine this._git]) {
    if (!new Directory(path).existsSync()) {
      new Directory(path).createSync();
    }

    if (this._git != null) {
      _git.init().catchError((dynamic error, StackTrace stackTrace) => Logger
          .root
          .shout('Failed to initialize git engine', error, stackTrace));
    }

    _buildIndex();
  }

  /// Returns the next available ID from the sequencer. Notice that every
  /// call to this function will increase the counter in the
  /// sequencer object.
  int get _nextId => _sequencer.nextInt();

  /// Emits [event.MessageChange] upon every object change.
  Stream<event.MessageChange> get changeStream => _changeBus.stream;

  /// Returns once the filestore is initializes.
  Future<Null> get initialized async {
    if (_git != null) {
      return _git.initialized;
    } else {
      return null;
    }
  }

  /// Awaits if there is already an operation in progress and returns
  /// whenever the filestore is ready to process the next request.
  Future<Null> get ready async {
    if (_git != null) {
      return _git.whenReady;
    } else {
      return null;
    }
  }

  /// Turns [DateTime] into a date-dir path and casts it into a [Directory].
  Directory _dateDir(DateTime day) =>
      new Directory('$path/${day.toIso8601String().split('T').first}');

  /// Rebuilds the entire index.
  void _buildIndex() {
    int highestId = 0;
    Stopwatch timer = new Stopwatch()..start();
    _log.info('Building primary index');

    List<FileSystemEntity> dateDirs = new Directory(path).listSync();

    for (FileSystemEntity fse in dateDirs) {
      // Only process directories.
      if (fse is Directory) {
        List<FileSystemEntity> files = fse.listSync();

        for (FileSystemEntity file in files) {
          if (_isJsonFile(file)) {
            try {
              final int id = int.parse(basenameWithoutExtension(file.path));
              _index[id] = file.path;

              if (id > highestId) {
                highestId = id;
              }
            } catch (e) {
              _log.shout('Failed load index from file ${file.path}');
            }
          }
        }
      }
    }

    _log.info('Built primary index of ${_index.keys.length} elements in'
        ' ${timer.elapsedMilliseconds}ms');
    _sequencer = new Sequencer(path, explicitId: highestId);

    if (_git != null) {
      _git.addIgnoredPath(_sequencer.sequencerFilePath);
    }
  }

  /// Rebuilds the secondary indexes of the filestore.
  Future<Null> rebuildSecondaryIndexes() async {
    Stopwatch timer = new Stopwatch()..start();
    _log.info('Building secondary indexes');
    await Future.forEach(_index.keys, (int id) async {
      final model.Message msg = await get(id);
      final Set<int> cidList = _cidIndex.containsKey(msg.context.cid)
          ? _cidIndex[msg.context.cid]
          : _cidIndex[msg.context.cid] = new Set<int>();

      final Set<int> uidList = _uidIndex.containsKey(msg.sender.id)
          ? _uidIndex[msg.sender.id]
          : _uidIndex[msg.sender.id] = new Set<int>();

      final Set<int> ridList = _ridIndex.containsKey(msg.context.rid)
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

  @override
  Future<model.Message> get(int mid) async {
    if (!_index.containsKey(mid)) {
      throw new NotFound('No index key with mid $mid');
    }

    final File file = new File(_index[mid]);

    if (!file.existsSync()) {
      throw new NotFound('No file with mid $mid');
    }

    try {
      final String fileContents = await file.readAsString();
      final model.Message msg = model.Message
          .decode(JSON.decode(fileContents) as Map<String, dynamic>);
      return msg;
    } catch (e, s) {
      _log.shout('Failed to load file ${file.path}', e, s);
      throw e;
    }
  }

  @override
  Future<Iterable<model.Message>> getByIds(Iterable<int> ids) async {
    List<model.Message> list = new List<model.Message>();

    await Future.forEach(ids, (int id) async {
      try {
        list.add(await get(id));
      } on NotFound {
        // Ignore the non-found element.
      } catch (e, s) {
        _log.shout('Failed to retrieve element with id $id', e, s);
      }
    });

    return list;
  }

  /// Loads all message ID's of the [Directory] [dir].
  Iterable<int> _idsOfDir(Directory dir) {
    List<FileSystemEntity> fses = dir.listSync();

    List<int> list = <int>[];

    for (FileSystemEntity fse in fses) {
      // Only process directories.
      if (_isJsonFile(fse)) {
        try {
          list.add(int.parse(basenameWithoutExtension(fse.path)));
        } catch (e) {
          _log.shout('Failed load index from file ${fse.path}');
        }
      }
    }
    return list;
  }

  @override
  Future<Iterable<model.Message>> listDay(DateTime day) async {
    final Directory dateDir = _dateDir(day);

    if (!await dateDir.exists()) {
      return const <model.Message>[];
    }

    Set<int> ids = _idsOfDir(dateDir).toSet();

    return getByIds(ids);
  }

  @override
  Future<Iterable<model.Message>> listDrafts() async {
    Set<int> ids = new Set<int>()..addAll(_draftsIndex);

    return getByIds(ids);
  }

  /// Get all the message ID's associated with [uid].
  Future<Iterable<int>> midsOfUid(int uid) async {
    if (_uidIndex.containsKey(uid)) {
      return _uidIndex[uid];
    } else {
      return const <int>[];
    }
  }

  /// Get all the message ID's associated with [cid].
  Future<Iterable<int>> midsOfCid(int cid) async {
    if (_cidIndex.containsKey(cid)) {
      return _cidIndex[cid];
    } else {
      return <int>[];
    }
  }

  /// Get all the message ID's associated with [rid].
  Future<Iterable<int>> midsOfRid(int rid) async {
    if (_ridIndex.containsKey(rid)) {
      return _ridIndex[rid];
    } else {
      return const <int>[];
    }
  }

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
      throw new ClientError('File already exists, please update instead');
    }

    file.writeAsStringSync(_jsonpp.convert(msg));

    /// Update indexes.
    _index[msg.id] = file.path;
    final Set<int> cidList = _cidIndex.containsKey(msg.context.cid)
        ? _cidIndex[msg.context.cid]
        : _cidIndex[msg.context.cid] = new Set<int>();

    final Set<int> uidList = _uidIndex.containsKey(msg.sender.id)
        ? _uidIndex[msg.sender.id]
        : _uidIndex[msg.sender.id] = new Set<int>();

    final Set<int> ridList = _ridIndex.containsKey(msg.context.rid)
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

  @override
  Future<model.Message> update(model.Message msg, model.User modifier) async {
    final File file = new File(_index[msg.id]);

    if (!file.existsSync()) {
      throw new NotFound();
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

  @override
  Future<Null> remove(int mid, model.User modifier) async {
    if (!_index.containsKey(mid)) {
      throw new NotFound('No index key with mid $mid');
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

    Iterable<model.Commit> changes = gitChanges.map((Change change) =>
        new model.Commit()
          ..uid = extractUid(change.message)
          ..changedAt = change.changeTime
          ..commitHash = change.commitHash
          ..authorIdentity = change.author
          ..changes = new List<model.ObjectChange>.from(
              change.fileChanges.map(convertFilechange)));

    _log.info(changes.map((model.Commit c) => c.toJson()));

    return changes;
  }

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

    Iterable<model.Commit> changes = gitChanges.map((Change change) =>
        new model.Commit()
          ..uid = extractUid(change.message)
          ..changedAt = change.changeTime
          ..commitHash = change.commitHash
          ..authorIdentity = change.author
          ..changes = new List<model.ObjectChange>.from(
              change.fileChanges.map(convertFilechange)));

    _log.info(changes.map((model.Commit c) => c.toJson()));

    return changes;
  }
}
