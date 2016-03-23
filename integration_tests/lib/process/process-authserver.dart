part of openreception_tests.process;

class AuthServer implements ServiceProcess {
  final String path;
  final String storePath;
  final int servicePort;
  final String bindAddress;
  AuthTokenDir tokenDir;

  final Logger _log = new Logger('$_namespace.AuthServer');
  Process _process;

  Completer _ready = new Completer();
  bool get ready => _ready.isCompleted;
  Future get whenReady => _ready.future;

  /**
   *
   */
  AuthServer(this.path, this.storePath,
      {Iterable<AuthToken> intialTokens: const [],
      this.servicePort: 4050,
      this.bindAddress: '0.0.0.0'}) {
    _init(intialTokens);
  }

  /**
   *
   */
  Future _init(Iterable<AuthToken> intialTokens) async {
    tokenDir = new AuthTokenDir(new Directory('/tmp').createTempSync(),
        intialTokens: intialTokens);

    await _writeTokens();
    final arguments = [
      '$path/bin/authserver.dart',
      '-d',
      tokenDir.dir.absolute.path,
      '--filestore',
      storePath,
      '--httpport',
      servicePort.toString(),
      '--host',
      bindAddress
    ];
    _log.fine('Starting process /usr/bin/dart ${arguments.join(' ')}');

    _process = await Process.start('/usr/bin/dart', arguments,
        workingDirectory: path)
      ..stdout
          .transform(new Utf8Decoder())
          .transform(new LineSplitter())
          .listen((String line) {
        _log.finest(line);
        if ((!ready && line.contains('Ready to handle requests')) ||
            (!ready && line.contains('Reloaded tokens from disk'))) {
          _log.info('Ready');
          _ready.complete();
        }
      })
      ..stderr
          .transform(new Utf8Decoder())
          .transform(new LineSplitter())
          .listen(_log.warning);
    _log.finest('Started process');
  }

  /**
   *
   */
  Future _writeTokens() async {
    _log.finest('Writing ${tokenDir.tokens.length} tokens '
        'to ${tokenDir.dir.path}');
    await tokenDir.writeTokens();
  }

  /**
   *
   */
  Future addTokens(Iterable<AuthToken> ts) async {
    await whenReady;
    _ready = new Completer();
    tokenDir.tokens.addAll(ts);
    await _writeTokens();
    _process.kill(ProcessSignal.SIGHUP);
    await whenReady;
  }

  /**
   * Constructs a new [service.Autentication] based on the launch parameters
   * of the process.
   */
  service.Authentication bindClient(service.Client client, AuthToken token,
      {Uri connectUri: null}) {
    if (connectUri == null) {
      connectUri = this.uri;
    }

    return new service.Authentication(connectUri, token.tokenName, client);
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
