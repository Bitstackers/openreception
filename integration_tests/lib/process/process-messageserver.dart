part of openreception_tests.process;

class MessageServer implements ServiceProcess {
  final String path;
  final String storePath;
  final int servicePort;
  final String bindAddress;

  final Uri authUri;
  final Uri notificationUri;
  final Logger _log = new Logger('$_namespace.MessageServer');
  Process _process;

  final Completer _ready = new Completer();
  bool get ready => _ready.isCompleted;
  Future get whenReady => _ready.future;

  MessageServer(this.path, this.storePath,
      {this.servicePort: 4040,
      this.bindAddress: '0.0.0.0',
      this.authUri: null,
      this.notificationUri}) {
    _init();
  }

  Future _init() async {
    final arguments = [
      '$path/bin/messageserver.dart',
      '-f',
      storePath,
      '-p',
      servicePort.toString(),
      '-h',
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
   * Constructs a new [service.RESTMessageStore] based on the launch parameters
   * of the process.
   */
  service.RESTMessageStore bindClient(service.Client client, AuthToken token,
      {Uri connectUri: null}) {
    if (connectUri == null) {
      connectUri = this.uri;
    }

    return new service.RESTMessageStore(connectUri, token.tokenName, client);
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
