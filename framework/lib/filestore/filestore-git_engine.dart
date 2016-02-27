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

class Change {
  final DateTime changeTime;
  final String author;
  final String message;

  const Change(this.changeTime, this.author, {this.message: ''});
}

class GitEngine {
  final Logger _log = new Logger('$libraryName.GitEngine');
  final String path;
  bool logStdout = false;

  Future get initialized => _initialized.future;
  final Completer _initialized = new Completer();
  bool get ready => _busy.isCompleted;

  Future get whenReady => _busy.future;

  Completer _busy = new Completer();

  GitEngine(String this.path);

  /**
   *
   */
  Future init() async {
    final _storeDir = new Directory(path);
    if (_initialized.isCompleted) {
      return;
    }

    if (!_storeDir.existsSync()) {
      _log.info('Directory "$path" not found - creating it');
      _storeDir.createSync();

      ProcessResult result = await Process.run('/usr/bin/git', ['init', path],
          workingDirectory: path);

      final String stdout = result.stdout;
      if (stdout.isNotEmpty && logStdout) {
        _log.finest(stdout);
      }

      final String stderr = result.stderr;
      if (stderr.isNotEmpty) {
        _log.severe(stderr);
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

      if (status.exitCode != 0) {
        ProcessResult result = await Process.run('/usr/bin/git', ['init', path],
            workingDirectory: path);

        if (result.stdout.isNotEmpty && logStdout) {
          _log.finest(stdout);
        }

        if (result.stderr.isNotEmpty) {
          _log.severe(stderr);
        }

        if (result.exitCode != 0) {
          _log.shout('Failed to init git repository!');
          _initialized.completeError('Failed to init git repository!');
        } else {
          _initialized.complete();
        }
      } else {
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
    _lock();

    _busy = new Completer();

    try {
      if (!await _hasChanges(file)) {
        throw new storage.Unchanged('No new content');
      }
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
    final ProcessResult result = await Process.run(
        '/usr/bin/git', ['status', '--porcelain', file.path],
        workingDirectory: path);

    String stderr = result.stderr;
    if (stderr.isNotEmpty) {
      _log.severe(stderr);
    }

    if (result.exitCode != 0) {
      _log.shout('Failed to add ${path}');
      throw new storage.ServerError();
    }

    final List<String> lines = result.stdout.split('\n');

    if (!lines.any((line) => line.contains(file.path))) {
      return false;
    }

    return true;
  }

  /**
   *
   */
  Future remove(File file, String commitMsg, String author) async {
    await init();
    _lock();

    try {
      await _remove(file);
      await _commit(commitMsg, author);
      _unlock();
    } catch (e, s) {
      _unlockError(e, s);
    }
  }

  /**
   *
   */
  Future changes(File file) async {
    final ProcessResult result = await Process.run('/usr/bin/git',
        ['log', '--pretty=format:"%ct%x09%aE%x09%s"', file.path],
        workingDirectory: path);

    List<String> lines = result.stdout.split('\n');
    List<Change> changeList = [];
    lines.forEach((line) {
      List<String> parts = line.split(new String.fromCharCode(9));
      print(parts);
    });

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
  Future _remove(File file) async {
    final ProcessResult result = await Process
        .run('/usr/bin/git', ['rm', file.path], workingDirectory: path);
    String stdout = result.stdout;
    if (stdout.isNotEmpty && logStdout) {
      _log.finest(stdout);
    }

    String stderr = result.stderr;
    if (stderr.isNotEmpty) {
      _log.severe(stderr);
    }

    if (result.exitCode != 0) {
      _log.shout('Failed to remove ${file.path}');
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
