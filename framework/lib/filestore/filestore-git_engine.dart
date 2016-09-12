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

part of orf.filestore;

/// A change that has occured in a file.
class FileChange {
  /// The type of change that has occurred in the file.
  final model.ChangeType changeType;

  /// The path of the file
  final String filename;

  /// Create new [FileChange] object with [changeType] and [filename].
  const FileChange(this.changeType, this.filename);

  /// Serialization function.
  String toJson() => '$changeType $filename';
}

class Change {
  final DateTime changeTime;
  final String author;
  final String message;
  final String commitHash;
  List<FileChange> fileChanges = <FileChange>[];

  Change(this.changeTime, this.author, this.commitHash, {this.message: ''});

  Map<String, dynamic> toJson() => <String, dynamic>{
        'changed': changeTime.millisecondsSinceEpoch,
        'author': author,
        'message': message,
        'changes': new List<String>.from(
            fileChanges.map((FileChange fc) => fc.toJson()))
      };
}

class _Job {
  final Completer<Null> completionTicket = new Completer<Null>();
  final Function work;

  _Job(this.work);
}

class GitEngine {
  /// Internal logger
  final Logger _log = new Logger('$_libraryName.GitEngine');

  /// Root path to keep under revisioning.
  final String path;

  /// Determines whether or not to inject `STDOUT` of the git process into
  /// the log stream.
  final bool logStdout;

  /// Work queue of [_Job]s that are enqueued because the git process is
  /// not currently [ready].
  final Queue<_Job> _workQueue = new Queue<_Job>();

  /// Determines if the [GitEngine] is initialized.
  Completer<Null> _initialized;

  /// Determines if the [GitEngine] is currently busy.
  Completer<Null> _busy = new Completer<Null>();

  /// Place [path] under git revisioning.
  GitEngine(String this.path, {bool this.logStdout: false}) {
    if (path.isEmpty) {
      throw new ArgumentError.value('', 'path', 'Path must not be empty');
    }
  }

  /// Indicates whether or not this [GitEngine] is ready to process the
  /// next request.
  bool get ready => _busy.isCompleted;

  /// Awaits if there is already an operation in progress and returns
  /// whenever the [GitEngine] is ready to process the next request.
  Future<Null> get whenReady => _busy.future;

  /// Returns when the [GitEngine] is initialized.
  Future<Null> get initialized => _initialized.future;

  List<String> ignoredPaths(String path) =>
      new File('$path/.gitignore').readAsStringSync().split('\n');

  void addIgnoredPath(String ignorePath) {
    final File ignoreFile = new File('$path/.gitignore');
    Set<String> paths = ignoreFile.existsSync()
        ? ignoreFile.readAsStringSync().split('\n').toSet()
        : new Set<String>();

    paths.add(path);

    ignoreFile.writeAsStringSync(paths.join('\n'));
  }

  Future<Null> init() async {
    final Directory _storeDir = new Directory(path);

    if (_initialized != null) {
      return whenReady;
    }
    _initialized = new Completer<Null>();

    if (!_storeDir.existsSync()) {
      final List<String> args = <String>['init', path];
      _log.info('Directory "$path" not found - creating it');
      _storeDir.createSync();

      final ProcessResult result =
          await Process.run('/usr/bin/git', args, workingDirectory: path);

      if (result.stdout.isNotEmpty && logStdout) {
        _log.finest(result.stdout);
      }

      if (result.stderr.isNotEmpty) {
        _log.severe(result.stderr);
      }

      if (result.exitCode != 0) {
        _log.shout('Failed to init git repository. Args: $args!');
        _initialized.completeError('Failed to init git repository!');
      } else {
        _initialized.complete();
      }
    }

    /// Check write permissions
    else {
      _log.fine('Directory "$path" found - checking permissions');

      final Directory tmpDir = _storeDir.createTempSync();
      await tmpDir.delete();

      final ProcessResult status = await Process
          .run('/usr/bin/git', <String>['status'], workingDirectory: path);

      if (!(_containsDotGit(path)) && status.exitCode == 0) {
        throw new StateError(
            'Path ${_storeDir.absolute} is already under Git revisioning. Consider relocating store');
      }

      if (status.exitCode != 0) {
        _log.info('Git repos not found in "$path" not found - creating it');
        ProcessResult result = await Process.run(
            '/usr/bin/git', <String>['init', path],
            workingDirectory: path);

        if (result.stdout.isNotEmpty && logStdout) {
          _log.finest(result.stdout);
        }

        if (result.stderr.isNotEmpty) {
          _log.severe(result.stderr);
        }

        if (result.exitCode != 0) {
          _log.shout('Failed to init git repository!');
          _initialized.completeError('Failed to init git repository!');
        } else {
          _initialized.complete();
        }
      } else {
        _log.info('Git repos found  in "$path"');
        ProcessResult result =
            await Process.run('/bin/pwd', <String>[], workingDirectory: path);
        if (result.stdout.isNotEmpty && logStdout) {
          _log.finest(result.stdout.split('\n').first);
        }

        if (result.stderr.isNotEmpty) {
          _log.severe(result.stderr);
        }

        _initialized.complete();
      }
    }
    _busy.complete();
  }

  _Job _enqueue(Function f) {
    _Job job = new _Job(f);
    _workQueue.add(job);
    return job;
  }

  Future<Null> add(File file, String commitMsg, String author) async {
    await init();
    final bool locked = _lock();
    if (!locked) {
      return _enqueue(() => add(file, commitMsg, author))
          .completionTicket
          .future;
    }

    try {
      await _add(file);
      await _commit(file.path, commitMsg, author);
    } finally {
      await _unlock();
    }
  }

  Future<Null> commit(File file, String commitMsg, String author) async {
    await init();
    if (!await _hasChanges(file)) {
      throw new Unchanged('No new content');
    }

    final bool locked = _lock();
    if (!locked) {
      return _enqueue(() => commit(file, commitMsg, author))
          .completionTicket
          .future;
    }

    try {
      await _commit(file.path, commitMsg, author);
    } finally {
      await _unlock();
    }
  }

  Future<bool> _hasChanges(File file) async {
    String filePath = file.path.replaceFirst(path, '');
    while (filePath.startsWith('/')) {
      filePath = filePath.replaceFirst('/', '');
    }

    final ProcessResult result = await Process.run(
        '/usr/bin/git', <String>['status', '--porcelain', filePath],
        workingDirectory: path);

    String stderr = result.stderr;
    if (stderr.isNotEmpty) {
      _log.severe(stderr);
    }

    if (result.exitCode != 0) {
      _log.shout('Failed to get status of $filePath');
      throw new ServerError();
    }

    final List<String> lines = (result.stdout as String).split('\n');

    if (!lines.any((String line) => line.contains(filePath))) {
      return false;
    }

    return true;
  }

  Future<Null> remove(
      FileSystemEntity fse, String commitMsg, String author) async {
    await init();
    final bool locked = _lock();
    if (!locked) {
      return _enqueue(() => remove(fse, commitMsg, author))
          .completionTicket
          .future;
    }
    try {
      await _remove(fse);
      await _commit(fse.path, commitMsg, author);
    } finally {
      await _unlock();
    }
  }

  Future<Iterable<Change>> changes(FileSystemEntity fse) async {
    final String gitBin = '/usr/bin/git';
    final List<String> arguments = <String>[
      'log',
      '--name-status',
      '--pretty=format:%ct%x09%aE%x09%H%x09%s',
      '--follow',
      '--',
      fse.path
    ];

    final ProcessResult result =
        await Process.run(gitBin, arguments, workingDirectory: path);

    final List<String> lines = (result.stdout as String).split('\n');
    final List<Change> changeList = <Change>[];

    void processBuffer(List<String> bufferLines) {
      List<String> parts = bufferLines.first.split(new String.fromCharCode(9));
      final int milliseconds = int.parse(parts[0]) * 1000;
      final String authorIdentity = parts[1].trim();
      final String commitHash = parts[2].trim();
      final String message = parts[3].trim();
      List<FileChange> fileChanges = <FileChange>[];

      bufferLines.skip(1).forEach((String line) {
        model.ChangeType changeType =
            model.changeTypeFromString(line.substring(0, 1));
        String filename = line.substring(1).trim();
        fileChanges.add(new FileChange(changeType, filename));
      });

      final Change change = new Change(
          new DateTime.fromMillisecondsSinceEpoch(milliseconds),
          authorIdentity,
          commitHash,
          message: message)..fileChanges = fileChanges;

      changeList.add(change);
    }

    List<String> buffer = <String>[];
    lines.forEach((String line) {
      line = line.trim();

      if (line.isEmpty && buffer.isNotEmpty) {
        processBuffer(buffer);
        buffer.clear();
      } else {
        buffer.add(line);
      }
    });

    String stderr = result.stderr;
    if (stderr.isNotEmpty) {
      _log.severe(stderr);
    }

    if (result.exitCode != 0) {
      _log.shout('Failed to run $gitBin ${arguments.join(' ')}');
      throw new ServerError();
    }

    return changeList;
  }

  /// Determine if a path contains a .git folder
  bool _containsDotGit(String path) => new Directory('$path/.git').existsSync();

  /// Add [File] path to staging area.
  Future<Null> _add(File file) async {
    final ProcessResult result = await Process.run(
        '/usr/bin/git', <String>['add', file.path],
        workingDirectory: path);

    String stdout = result.stdout;
    if (stdout.isNotEmpty && logStdout) {
      _log.finest(stdout);
    }

    String stderr = result.stderr;
    if (stderr.isNotEmpty) {
      _log.severe(stderr);
    }

    if (result.exitCode != 0) {
      _log.shout('Failed to add $path');
      throw new ServerError();
    }
  }

  /// Commit staged changes.
  Future<Null> _commit(String fsePath, String commitMsg, String author) async {
    final String gitBin = '/usr/bin/git';
    final List<String> arguments = <String>[
      'commit',
      fsePath,
      '--author="$author"',
      '-m',
      commitMsg
    ];

    final ProcessResult result =
        await Process.run('/usr/bin/git', arguments, workingDirectory: path);

    String stdout = result.stdout;
    if (stdout.isNotEmpty && logStdout) {
      _log.finest(stdout);
    }

    String stderr = result.stderr;
    if (stderr.isNotEmpty) {
      _log.severe(stderr);
    }

    if (result.exitCode != 0) {
      _log.shout('Failed to run $gitBin ${arguments.join(' ')}');
      throw new ServerError();
    }
  }

  /// Purges [fse] from file system.
  Future<Null> _remove(FileSystemEntity fse) async {
    final ProcessResult result = await Process.run(
        '/usr/bin/git', <String>['rm', fse.path, '-r', '--force'],
        workingDirectory: path);
    String stdout = result.stdout;
    if (stdout.isNotEmpty && logStdout) {
      _log.finest(stdout);
    }

    String stderr = result.stderr;
    if (stderr.isNotEmpty) {
      _log.severe(stderr);
    }

    if (result.exitCode != 0) {
      _log.shout('Failed to remove ${fse.path}');
      throw new ServerError();
    }
  }

  /// Lock the git process and enqueue subsequent actions as [_Job]s.
  bool _lock() {
    if (!ready) {
      return false;
    }

    _busy = new Completer<Null>();
    return true;
  }

  /// Unlock the git process and let the next [_Job] in [_workQueue] start.
  Future<Null> _unlock() async {
    if (ready) {
      _log.shout('Unlocking not previously locked process');
    } else {
      _busy.complete();
    }

    await _processWorkQueue();
  }

  /// Process queued up [_Job]s.
  Future<Null> _processWorkQueue() async {
    if (_workQueue.isNotEmpty) {
      _Job job = _workQueue.removeFirst();

      try {
        await job.work();
        job.completionTicket.complete();
      } catch (e, s) {
        job.completionTicket.completeError(e, s);
      }
    }
  }
}
