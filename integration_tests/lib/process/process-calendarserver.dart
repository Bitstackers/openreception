part of openreception_tests.process;

class CalendarServer implements ServiceProcess {
  final Logger _log = new Logger('$_namespace.CalendarServer');
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
  CalendarServer(this.path, this.storePath,
      {this.servicePort: 4060,
      this.bindAddress: '0.0.0.0',
      this.authUri: null,
      this.notificationUri}) {
    _init();
  }

  /**
   *
   */
  Future _init() async {
    final arguments = [
      '$path/bin/calendarserver.dart',
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
   * Constructs a new [service.RESTCalendarStore] based on the launch
   * parameters of the process.
   */
  service.RESTCalendarStore bindClient(service.Client client, AuthToken token,
      {Uri connectUri: null}) {
    if (connectUri == null) {
      connectUri = this.uri;
    }

    return new service.RESTCalendarStore(connectUri, token.tokenName, client);
  }

  /**
   *
   */
  Uri get uri => Uri.parse('http://$bindAddress:$servicePort');

  /**
   *
   */
  Future terminate() async {
    _process.kill();
    await _process.exitCode;
  }
}
