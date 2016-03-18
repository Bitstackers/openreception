part of openreception_tests.process;

class CalendarServer implements ServiceProcess {
  final String path;
  final String storePath;
  final Logger _log = new Logger('$_namespace.CalendarServer');
  Process _process;

  final Completer _ready = new Completer();
  bool get ready => _ready.isCompleted;
  Future get whenReady => _ready.future;

  CalendarServer(this.path, this.storePath) {
    _init();
  }

  Future _init() async {
    _log.fine('Starting new process');
    _process = await Process.start(
        '/usr/bin/dart', ['$path/bin/calendarserver.dart', '-f', storePath],
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
