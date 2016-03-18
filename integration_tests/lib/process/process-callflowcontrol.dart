part of openreception_tests.process;

class CallFlowControl implements ServiceProcess {
  final Logger _log = new Logger('$_namespace.CallFlowControl');
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
  CallFlowControl(this.path, this.storePath,
      {this.servicePort: 4030,
      this.bindAddress: '0.0.0.0',
      this.authUri: null,
      this.notificationUri: null}) {
    _init();
  }

  /**
   *
   */
  Future _init() async {
    final arguments = [
      '$path/bin/callflowcontrol.dart',
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
   * Constructs a new [service.CallFlowControl] based on the launch
   * parametersof the process.
   */
  service.CallFlowControl bindClient(service.Client client, AuthToken token,
      {Uri connectUri: null}) {
    if (connectUri == null) {
      connectUri = this.uri;
    }

    return new service.CallFlowControl(connectUri, token.tokenName, client);
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
