part of openreception_tests.process;

class ContactServer implements ServiceProcess {
  final Logger _log = new Logger('$_namespace.ContactServer');
  Process _process;
  final String path;
  final String storePath;

  final int servicePort;
  final String bindAddress;
  final Uri authUri;
  final Uri notificationUri;

  final Completer _ready = new Completer();
  bool get ready => _ready.isCompleted;
  Future get whenReady => _ready.future;

  ContactServer(this.path, this.storePath,
      {this.servicePort: 4010,
      this.bindAddress: '0.0.0.0',
      this.authUri: null,
      this.notificationUri}) {
    _init();
  }

  Future _init() async {
    _log.fine('Starting new process');
    _process = await Process.start(
        '/usr/bin/dart', ['$path/bin/contactserver.dart', '-f', storePath],
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
