part of openreception_tests.process;

class NotificationServer implements ServiceProcess {
  final Logger _log = new Logger('$_namespace.NotificationServer');
  Process _process;

  final String path;
  final String storePath;
  final int servicePort;
  final String bindAddress;
  final Uri authUri;

  final Completer _ready = new Completer();
  bool get ready => _ready.isCompleted;
  Future get whenReady => _ready.future;

  /**
   *
   */
  NotificationServer(this.path, this.storePath,
      {this.servicePort: 4200,
      this.bindAddress: '0.0.0.0',
      this.authUri: null}) {
    _init();
  }

  /**
   *
   */
  Future _init() async {
    final Stopwatch initTimer = new Stopwatch()..start();
    whenReady.whenComplete(() {
      initTimer.stop();
      _log.info('Process initialization time was: '
          '${initTimer.elapsedMilliseconds}ms');
    });

    final arguments = [
      '$path/bin/notificationserver.dart',
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

    _log.finest('Started notificationserver process (pid: ${_process.pid})');
    _launchedProcesses.add(_process);

    /// Protect from hangs caused by process crashes.
    _process.exitCode.then((int exitCode) {
      if (exitCode != 0 && !ready) {
        _ready.completeError(new StateError('Failed to launch process. '
            'Exit code: $exitCode'));
      }
    });
  }

  /**
   * Constructs a new [service.NotificationService] based on the launch parameters
   * of the process.
   */
  service.NotificationService bindClient(service.Client client, AuthToken token,
      {Uri connectUri: null}) {
    if (connectUri == null) {
      connectUri = this.uri;
    }

    return new service.NotificationService(connectUri, token.tokenName, client);
  }

  /**
   *
   */
  Future<service.NotificationSocket> bindWebsocketClient(
      service.WebSocketClient wsc, AuthToken token) async {
    final Uri uri = Uri.parse('$notifyUri?token=${token.tokenName}');

    _log.finest('Connecting websocket to $uri');
    final connectedClient = await wsc.connect(uri);
    _log.finest('Connected websocket to $uri');
    return new service.NotificationSocket(connectedClient);
  }

  /**
   *
   */
  Uri get uri => Uri.parse('http://$bindAddress:$servicePort');

  /**
   *
   */
  Uri get notifyUri =>
      Uri.parse('ws://$bindAddress:$servicePort/notifications');
  /**
   *
   */
  Future terminate() async {
    _process.kill();
    await _process.exitCode;
  }

  String toString() => '$runtimeType,pid:${_process.pid}:uri$uri';
}
