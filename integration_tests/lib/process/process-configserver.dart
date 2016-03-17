part of openreception_tests.process;

class ConfigServer {
  final String path;
  final int servicePort;
  final String bindAddress;

  final Logger _log = new Logger('$_namespace.ConfigServer');
  Process _process;

  final Completer _ready = new Completer();
  bool get ready => _ready.isCompleted;
  Future get whenReady => _ready.future;

  /**
   *
   */
  ConfigServer(this.path,
      {this.servicePort: 4080, this.bindAddress: '0.0.0.0'}) {
    _init();
  }

  /**
   *
   */
  Future _init() async {
    _log.fine('Starting new process');
    _process = await Process.start(
        '/usr/bin/dart',
        [
          '$path/bin/configserver.dart',
          '-p',
          servicePort.toString(),
          '-h',
          bindAddress
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

  /**
   * Constructs a new [service.RESTConfiguration] based on the launch parameters
   * of the process.
   */
  service.RESTConfiguration createClient(service.Client client,
      {Uri uri: null}) {
    if (uri == null) {
      uri = Uri.parse('http://${bindAddress}:$servicePort');
    }

    return new service.RESTConfiguration(uri, client);
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
