part of openreception_tests.process;

class FreeSwitchConfig {}

class FreeSwitch implements ServiceProcess {
  final String binPath;
  final String basePath;
  final File confTemplateArchive;
  final Directory exampleSoundsArchive;

  String get logPath => basePath + '/log';
  String get confPath => basePath + '/conf';
  String get runPath => basePath + '/run';
  String get dbPath => basePath + '/db';
  String get soundsPath => basePath + '/sounds';
  final Logger _log = new Logger('$_namespace.FreeSwitch');
  Process _process;

  final Completer _ready = new Completer();
  bool get ready => _ready.isCompleted;
  Future get whenReady => _ready.future;

  FreeSwitch(this.binPath, this.basePath, this.confTemplateArchive,
      this.exampleSoundsArchive) {
    _init();
  }

  /**
   *
   */
  Future _createDirs() async {
    [logPath, confPath, runPath, dbPath, soundsPath].forEach((path) {
      Directory dir = new Directory(path);
      if (!dir.existsSync()) {
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

    _log.info('Cleaning config in directory ${confDir.absolute.path}');
    await Process.run('/bin/tar', ['xf', confTemplateArchive.absolute.path],
        workingDirectory: basePath);

    _log.info(
        'Copying example sounds from ${exampleSoundsArchive.absolute.path}'
        ' to $soundsPath');

    Iterable<File> files =
        exampleSoundsArchive.listSync().where((fse) => fse is File);

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
        _log.info('Canceling timer');
        t.cancel();
      }
    });

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
