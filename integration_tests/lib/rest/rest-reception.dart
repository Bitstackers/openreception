part of openreception_tests.rest;

void _runReceptionTests() {
  group('$_namespace.Reception', () {
    ServiceAgent sa;
    TestEnvironment env;
    process.ReceptionServer rProcess;
    process.AuthServer aProcess;
    transport.Client client;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
      client = new transport.Client();
      AuthToken authToken = new AuthToken(sa.user);

      aProcess = new process.AuthServer(
          Config.serverStackPath, env.runpath.path,
          intialTokens: [authToken]);

      rProcess =
          new process.ReceptionServer(Config.serverStackPath, env.runpath.path);

      sa.receptionStore = new service.RESTReceptionStore(
          Config.receptionStoreUri, authToken.tokenName, client);
      await Future.wait([rProcess.whenReady, aProcess.whenReady]);
    });

    tearDown(() async {
      await Future.wait([rProcess.terminate(), aProcess.terminate()]);
      env.clear();
      client.client.close();
    });

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
  });
}
