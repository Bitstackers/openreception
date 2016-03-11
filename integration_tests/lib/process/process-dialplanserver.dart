part of openreception_tests.process;

class DialplanServer {
  final String path;
  final String storePath;
  final String fsConfPath;
  final Logger _log = new Logger('$_namespace.DialplanServer');
  Process _process;

  final Completer _ready = new Completer();
  bool get ready => _ready.isCompleted;
  Future get whenReady => _ready.future;

  DialplanServer(this.path, this.storePath, this.fsConfPath) {
    _init();
  }

  Future _init() async {
    _log.fine('Starting new process');
    _process = await Process.start(
        '/usr/bin/dart',
        [
          '$path/bin/dialplanserver.dart',
          '-f',
          storePath,
          '--freeswitch-conf-path',
          fsConfPath
        ],
        workingDirectory: path)
      ..stdout
          .transform(new Utf8Decoder())
          .transform(new LineSplitter())
          .listen((String line) {
        _log.finest(line);
        if (!ready && line.contains('Ready to handle requests')) {
          _log.info('Ready');
          _ready.complete();
        }
      })
      ..stderr
          .transform(new Utf8Decoder())
          .transform(new LineSplitter())
          .listen(_log.warning);
  }

  Future terminate() async {
    _process.kill();
    await _process.exitCode;
  }
}
