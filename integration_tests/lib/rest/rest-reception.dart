part of openreception_tests.rest;

void _runReceptionTests() {
  group('$_namespace.Reception', () {
    Logger log = new Logger('$_namespace.Organization');

    ServiceAgent sa;
    TestEnvironment env;
    process.ReceptionServer rProcess;
    process.AuthServer aProcess;
    process.NotificationServer nProcess;
    transport.Client client;
    AuthToken authToken;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
      client = new transport.Client();
      authToken = new AuthToken(sa.user);
      sa.authToken = authToken.tokenName;
      nProcess = new process.NotificationServer(
          Config.serverStackPath, env.runpath.path);

      aProcess = new process.AuthServer(
          Config.serverStackPath, env.runpath.path,
          intialTokens: [authToken]);

      rProcess =
          new process.ReceptionServer(Config.serverStackPath, env.runpath.path);

      sa.receptionStore = new service.RESTReceptionStore(
          Config.receptionStoreUri, authToken.tokenName, client);
      await Future
          .wait([nProcess.whenReady, rProcess.whenReady, aProcess.whenReady]);
    });

    tearDown(() async {
      await Future.wait(
          [rProcess.terminate(), aProcess.terminate(), nProcess.terminate()]);
      env.clear();
      client.client.close();
    });
    test(
        'CORS headers present (existingUri)',
        () => isCORSHeadersPresent(
            resource.ReceptionDialplan.list(Config.receptionStoreUri), log));

    test(
        'CORS headers present (non-existingUri)',
        () => isCORSHeadersPresent(
            Uri.parse('${Config.receptionStoreUri}/nonexistingpath'), log));

    test(
        'Non-existing path',
        () => nonExistingPath(
            Uri.parse('${Config.receptionStoreUri}/nonexistingpath'
                '?token=${authToken.tokenName}'),
            log));

    test('create', () => storeTest.Reception.create(sa));
    test('update', () => storeTest.Reception.update(sa));
    test('update (not found)', () => storeTest.Reception.updateNonExisting(sa));
    test('update (invalid)', () => storeTest.Reception.updateInvalid(sa));
    test('remove', () => storeTest.Reception.remove(sa));

    test('extension of', () => storeTest.Reception.extensionOf(sa));
    test('by extension', () => storeTest.Reception.byExtension(sa));

    test('get', () => storeTest.Reception.existingReception(sa));
    test('get (not found)', () => storeTest.Reception.nonExistingReception(sa));
    test('list', () => storeTest.Reception.listReceptions(sa));

    test('Reception creation (event presence)',
        () => serviceTest.Reception.createEvent(sa));

    test('Reception update (event presence)',
        () => serviceTest.Reception.updateEvent(sa));

    test('Reception removal (event presence)',
        () => serviceTest.Reception.deleteEvent(sa));
  });
}
