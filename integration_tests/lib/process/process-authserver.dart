part of openreception_tests.process;

class AuthServer {
  final String path;
  final String storePath;
  final Logger _log = new Logger('$_namespace.AuthServer');
  Process _process;

  final Completer _ready = new Completer();
  bool get ready => _ready.isCompleted;
  Future get whenReady => _ready.future;

  AuthServer(this.path, this.storePath,
      {Iterable<AuthToken> intialTokens: const []}) {
    _init(intialTokens);
  }

  Future _init(Iterable<AuthToken> intialTokens) async {
    final AuthTokenDir tokenDir = new AuthTokenDir(
        new Directory('/tmp').createTempSync(),
        intialTokens: intialTokens);
    _log.finest('Writing ${intialTokens.length} tokens '
        'to ${tokenDir.dir.path}');
    await tokenDir.writeTokens();

    _log.fine('Starting new process');
    _process = await Process.start(
        '/usr/bin/dart',
        [
          '$path/bin/authserver.dart',
          '-d',
          tokenDir.dir.absolute.path,
          '-f',
          storePath
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
    _log.finest('Started process, cleaning temp auth dir');

    /// Clean out temporary tokens.
    whenReady.then((_) => tokenDir.dir.delete(recursive: true));
  }

  Future terminate() async {
    _process.kill();
    await _process.exitCode;
  }
}
