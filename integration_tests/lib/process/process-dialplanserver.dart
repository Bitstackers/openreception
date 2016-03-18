part of openreception_tests.process;

class DialplanServer implements ServiceProcess {
  final Logger _log = new Logger('$_namespace.DialplanServer');
  Process _process;

  final String path;
  final String storePath;
  final String fsConfPath;
  final int servicePort;
  final String bindAddress;
  final Uri authUri;

  final Completer _ready = new Completer();
  bool get ready => _ready.isCompleted;
  Future get whenReady => _ready.future;

  DialplanServer(this.path, this.storePath, this.fsConfPath,
      {this.servicePort: 4030,
      this.bindAddress: '0.0.0.0',
      this.authUri: null}) {
    _init();
  }

  /**
   *
   */
  Future _init() async {
    final arguments = [
      '$path/bin/dialplanserver.dart',
      '--filestore',
      storePath,
      '--httpport',
      servicePort.toString(),
      '--host',
      bindAddress,
      '--freeswitch-conf-path',
      fsConfPath
    ];

    if (authUri != null) {
      arguments.addAll(['--auth-uri', authUri.toString()]);
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
   * Constructs a new [service.PeerAccount] based on the launch
   * parametersof the process.
   */
  service.PeerAccount bindPeerAccountClient(
      service.Client client, AuthToken token,
      {Uri connectUri: null}) {
    if (connectUri == null) {
      connectUri = this.uri;
    }

    return new service.PeerAccount(connectUri, token.tokenName, client);
  }

  /**
   * Constructs a new [service.RESTDialplanStore] based on the launch
   * parametersof the process.
   */
  service.RESTDialplanStore bindDialplanClient(
      service.Client client, AuthToken token,
      {Uri connectUri: null}) {
    if (connectUri == null) {
      connectUri = this.uri;
    }

    return new service.RESTDialplanStore(connectUri, token.tokenName, client);
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
