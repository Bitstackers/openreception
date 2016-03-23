part of openreception_tests.process;

class UserServer implements ServiceProcess {
  final Logger _log = new Logger('$_namespace.UserServer');
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

  /**
   *
   */
  UserServer(this.path, this.storePath,
      {this.servicePort: 4030,
      this.bindAddress: '0.0.0.0',
      this.authUri,
      this.notificationUri}) {
    _init();
  }

  /**
   *
   */
  Future _init() async {
    final arguments = [
      '$path/bin/userserver.dart',
      '--filestore',
      storePath,
      '--httpport',
      servicePort.toString(),
      '--host',
      bindAddress
    ];

    if (authUri != null) {
      arguments.addAll(['--auth-uri', authUri.toString()]);
    }

    if (notificationUri != null) {
      arguments.addAll(['--notification-uri', notificationUri.toString()]);
    }

    _log.fine('Starting process /usr/bin/dart ${arguments.join(' ')}');
    _process = await Process.start('/usr/bin/dart', arguments,
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

  /**
   *
   */
  Future terminate() async {
    _process.kill();
    await _process.exitCode;
  }
}
