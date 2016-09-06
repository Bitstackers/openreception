part of ort.process;

class FreeSwitchConfig {}

class FreeSwitch implements ServiceProcess {
  final String binPath;
  final String basePath;
  final Directory confTemplateDir;
  final Directory exampleSoundsDir;

  String get logPath => basePath + '/log';
  String get confPath => basePath + '/conf';
  String get runPath => basePath + '/run';
  String get dbPath => basePath + '/db';
  String get soundsPath => basePath + '/sounds';
  String get ivrPath => confPath + '/ivr_menus';
  String get dialplanPath => confPath + '/dialplan';
  String get receptionDialplanPath => dialplanPath + '/receptions';
  String get userDirectoryPath => confPath + '/directory';
  String get receptionistsPath => userDirectoryPath + '/receptionists';
  String get testCallersPath => userDirectoryPath + '/test-callers';
  String get voicemailPath => userDirectoryPath + '/voicemail';

  final Logger _log = new Logger('$_namespace.FreeSwitch');
  Process _process;

  final Completer _ready = new Completer();
  bool get ready => _ready.isCompleted;
  Future get whenReady => _ready.future;

  FreeSwitch(this.binPath, this.basePath, this.confTemplateDir,
      this.exampleSoundsDir) {
    _init();
  }

  /**
   *
   */
  Future _createDirs() async {
    [
      logPath,
      confPath,
      runPath,
      dbPath,
      soundsPath,
      ivrPath,
      dialplanPath,
      receptionDialplanPath,
      userDirectoryPath,
      receptionistsPath,
      testCallersPath,
      voicemailPath
    ].forEach((path) {
      Directory dir = new Directory(path);
      if (!dir.existsSync()) {
        _log.fine('Creating directory ${dir.absolute.path}');
        dir.createSync();
      }
    });
  }

  /**
   *
   */
  Future cleanConfig() async {
    Directory confDir = new Directory(confPath);
    confDir.deleteSync(recursive: true);
    confDir.createSync();
    await _createDirs();

    _log.info('Cleaning config in directory ${confDir.absolute.path}');

    final args = ['-r', confTemplateDir.absolute.path, basePath];
    _log.info('Running /bin/cp ${args.join(' ')}');
    final copy = await Process.run('/bin/cp', args, workingDirectory: basePath);
    if (copy.exitCode != 0) {
      _log.shout('Failed to copy files to source dir');

      if (copy.stderr.isNotEmpty) {
        _log.shout(copy.stderr);
      }
      if (copy.stdout.isNotEmpty) {
        _log.shout(copy.stdout);
      }
    }

    _log.info('Copying example sounds from ${exampleSoundsDir.absolute.path}'
        ' to $soundsPath');

    final files = exampleSoundsDir.listSync().where((fse) => fse is File);

    Future.wait(files.map((File f) async {
      final String newPath = soundsPath + '/' + basename(f.path);

      _log.finest('Copying "${f.path}" -> "${newPath}"');
      await f.copy(newPath);
    }));
  }

  /**
   *
   */
  void reRollLog() {
    _log.info('Rerolling log');
    _process.kill(ProcessSignal.SIGHUP);
  }

  /**
   *
   */
  void reloadXml() {
    _process.stdin.writeln('reloadxml');
  }

  /**
   *
   */
  Future _init() async {
    final Stopwatch initTimer = new Stopwatch()..start();
    whenReady.whenComplete(() {
      initTimer.stop();
      _log.info('Process initialization time was: '
          '${initTimer.elapsedMilliseconds}ms');
    });

    await _createDirs();
    await cleanConfig();
    final arguments = [
      '-nonat',
      '-nonatmap',
      '-c',
      '-log',
      logPath,
      '-conf',
      confPath,
      '-run',
      runPath,
      '-db',
      dbPath
    ];
    _log.fine(
        'Starting new process $binPath in path ${basePath} arguments: ${arguments.join(' ')}');
    _process = await Process.start('/usr/bin/freeswitch', arguments)
      ..stdout
          .transform(new Utf8Decoder())
          .transform(new LineSplitter())
          .listen((String line) {
        if (!ready && line.contains('FreeSWITCH Started')) {
          _log.info('Ready');
          _ready.complete();
        }
      })
      ..stderr
          .transform(new Utf8Decoder())
          .transform(new LineSplitter())
          .listen(_log.warning);
    _log.finest('Started process');

    await new Future.delayed(new Duration(seconds: 1));
    new Timer.periodic(new Duration(milliseconds: 100), (Timer t) {
      if (!ready) {
        _process.kill(ProcessSignal.SIGHUP);
        _log.finest('Waiting for freeswitch to become ready');
      } else {
        _log.info('Cancelling timer');
        t.cancel();
      }
    });

    _log.finest('Started freeswitch process (pid: ${_process.pid})');
    _launchedProcesses.add(_process);

    /// Protect from hangs caused by process crashes.
    _process.exitCode.then((int exitCode) {
      if (exitCode != 0 && !ready) {
        _ready.completeError(new StateError('Failed to launch process. '
            'Exit code: $exitCode'));
      }
    });
  }

  /**
   *
   */
  File get latestLog => new File('$logPath/freeswitch.log');

  /**
   *
   */
  Future terminate() async {
    _log.info('terminating freeswitch');
    _process.kill();
    await _process.exitCode;
    _log.info('Freeswitch terminated');
  }
}
