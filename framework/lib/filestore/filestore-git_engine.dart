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

class FileChange {
  final model.ChangeType changeType;
  final String filename;

  const FileChange(this.changeType, this.filename);

  /**
   *
   */
  String toJson() => '$changeType $filename';
}

class Change {
  final DateTime changeTime;
  final String author;
  final String message;
  final String commitHash;
  List<FileChange> fileChanges = [];

  Change(this.changeTime, this.author, this.commitHash, {this.message: ''});

  /**
   *
   */
  Map toJson() => {
        'changed': changeTime.millisecondsSinceEpoch,
        'author': author,
        'message': message,
        'changes': new List<String>.from(fileChanges.map((fc) => fc.toJson()))
      };
}

class GitEngine {
  final Logger _log = new Logger('$libraryName.GitEngine');
  final String path;
  bool logStdout = false;

  Future get initialized => _initialized.future;
  Completer _initialized;
  bool get ready => _busy.isCompleted;

  Future get whenReady => _busy.future;

  Completer _busy = new Completer();

  GitEngine(String this.path);

  /**
   *
   */
  Future init() async {
    final _storeDir = new Directory(path);

    if (_initialized != null) {
      return whenReady;
    }
    _initialized = new Completer();

    if (!_storeDir.existsSync()) {
      _log.info('Directory "$path" not found - creating it');
      _storeDir.createSync();

      ProcessResult result = await Process.run('/usr/bin/git', ['init', path],
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
    }

    /// Check write permissions
    else {
      _log.fine('Directory "$path" found - checking permissions');

      final tmpDir = _storeDir.createTempSync();
      tmpDir.delete();

      ProcessResult status =
          await Process.run('/usr/bin/git', ['status'], workingDirectory: path);

      if (!(_containsDotGit(path)) && status.exitCode == 0) {
        throw new StateError(
            'Path ${_storeDir.absolute} is already under Git revisioning. Consider relocating store');
      }

      if (status.exitCode != 0) {
        _log.info('Git repos not found in "$path" not found - creating it');
        ProcessResult result = await Process.run('/usr/bin/git', ['init', path],
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
            await Process.run('/bin/pwd', [], workingDirectory: path);
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

  /**
   *
   */
  Future add(File file, String commitMsg, String author) async {
    await init();
    _lock();

    try {
      await _add(file);
      await _commit(commitMsg, author);
      _unlock();
    } catch (e, s) {
      _unlockError(e, s);
    }
  }

  /**
   *
   */
  Future commit(File file, String commitMsg, String author) async {
    await init();
    if (!await _hasChanges(file)) {
      throw new storage.Unchanged('No new content');
    }

    _lock();
    try {
      await _commit(commitMsg, author);
      _unlock();
    } catch (e, s) {
      _unlockError(e, s);
    }
  }

  /**
   *
   */
  Future<bool> _hasChanges(File file) async {
    String filePath = file.path.replaceFirst(path, '');
    while (filePath.startsWith('/')) {
      filePath = filePath.replaceFirst('/', '');
    }

    final ProcessResult result = await Process.run(
        '/usr/bin/git', ['status', '--porcelain', filePath],
        workingDirectory: path);

    String stderr = result.stderr;
    if (stderr.isNotEmpty) {
      _log.severe(stderr);
    }

    if (result.exitCode != 0) {
      _log.shout('Failed to get status of ${filePath}');
      throw new storage.ServerError();
    }

    final List<String> lines = result.stdout.split('\n');

    if (!lines.any((line) => line.contains(filePath))) {
      return false;
    }

    return true;
  }

  /**
   *
   */
  Future remove(FileSystemEntity fse, String commitMsg, String author) async {
    await init();
    _lock();

    try {
      await _remove(fse);
      await _commit(commitMsg, author);
      _unlock();
    } catch (e, s) {
      _unlockError(e, s);
    }
  }

  /**
   *
   */
  Future<Iterable<Change>> changes(FileSystemEntity fse) async {
    final String gitBin = '/usr/bin/git';
    final List<String> arguments = [
      'log',
      '--name-status',
      '--pretty=format:%ct%x09%aE%x09%H%x09%s',
      '--follow',
      '--',
      fse.path
    ];

    _log.finest('Running command $gitBin ${arguments.join(' ')}');
    final ProcessResult result =
        await Process.run(gitBin, arguments, workingDirectory: path);

    final List<String> lines = result.stdout.split('\n');
    final List<Change> changeList = [];

    void processBuffer(List<String> bufferLines) {
      List<String> parts = bufferLines.first.split(new String.fromCharCode(9));
      final int milliseconds = int.parse(parts[0]) * 1000;
      final String authorIdentity = parts[1].trim();
      final String commitHash = parts[2].trim();
      final String message = parts[3].trim();
      List<FileChange> fileChanges = [];

      bufferLines.skip(1).forEach((line) {
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

    List<String> buffer = [];
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
      throw new storage.ServerError();
    }

    return changeList;
  }

  /**
   * Determine if a path contains a .git folder
   */
  bool _containsDotGit(String path) => new Directory('$path/.git').existsSync();

  /**
   *
   */
  Future _add(File file) async {
    final ProcessResult result = await Process
        .run('/usr/bin/git', ['add', file.path], workingDirectory: path);

    String stdout = result.stdout;
    if (stdout.isNotEmpty && logStdout) {
      _log.finest(stdout);
    }

    String stderr = result.stderr;
    if (stderr.isNotEmpty) {
      _log.severe(stderr);
    }

    if (result.exitCode != 0) {
      _log.shout('Failed to add ${path}');
      throw new storage.ServerError();
    }
  }

  /**
   *
   */
  Future _commit(String commitMsg, String author) async {
    final ProcessResult result = await Process.run(
        '/usr/bin/git', ['commit', path, '--author="$author"', '-m', commitMsg],
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
      _log.shout('Failed to commit ${path}');
      throw new storage.ServerError();
    }
  }

  /**
   *
   */
  Future _remove(FileSystemEntity fse) async {
    final ProcessResult result = await Process.run(
        '/usr/bin/git', ['rm', fse.path, '-r', '--force'],
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
      throw new storage.ServerError();
    }
  }

  /**
   *
   */
  void _lock() {
    if (!ready) {
      throw new storage.Busy();
    }

    _busy = new Completer();
  }

  /**
   *
   */
  void _unlock() {
    if (ready) {
      _log.shout('Unlocking not previously locked process');
    } else {
      _busy.complete();
    }
  }

  /**
   *
   */
  void _unlockError(error, stackTrace) {
    if (ready) {
      _log.shout('Unlocking not previously locked process');
    } else {
      _busy.completeError(error, stackTrace);
    }
  }
}
