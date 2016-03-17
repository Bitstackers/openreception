part of openreception_tests.process;

class ReceptionServer {
  final String path;
  final String storePath;
  final int servicePort;
  final String bindAddress;
  final Logger _log = new Logger('$_namespace.ReceptionServer');
  Process _process;

  final Completer _ready = new Completer();
  bool get ready => _ready.isCompleted;
  Future get whenReady => _ready.future;

  ReceptionServer(this.path, this.storePath,
      {this.servicePort: 4000, this.bindAddress: '0.0.0.0'}) {
    _init();
  }

  Future _init() async {
    _log.fine('Starting new process');
    _process = await Process.start('/usr/bin/dart',
        ['$path/bin/receptionserver.dart', '-f', storePath, '-p', servicePort],
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

  service.RESTReceptionStore createClient(service.Client client, String token,
      {Uri uri: null}) {
    if (uri == null) {
      uri = Uri.parse('http://${bindAddress}:$servicePort');
    }

    return new service.RESTReceptionStore(uri, token, client);
  }
}
