part of openreception_tests.rest;

void _runOrganizationTests() {
  group('$_namespace.Organization', () {
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
      sa.organizationStore = new service.RESTOrganizationStore(
          Config.receptionStoreUri, authToken.tokenName, client);

      await Future.wait([rProcess.whenReady, aProcess.whenReady]);
    });

    tearDown(() async {
      await Future.wait([rProcess.terminate(), aProcess.terminate()]);
      env.clear();
      client.client.close();
    });

    test('create', () => storeTest.Organization.create(sa));
    test('create (empty)', () => storeTest.Organization.createEmpty(sa));

    test('update', () => storeTest.Organization.update(sa));
    test('update (invalid)', () => storeTest.Organization.updateInvalid(sa));

    test('remove', () => storeTest.Organization.remove(sa));
    test('remove (non-existing)',
        () => storeTest.Organization.removeNonExisting(sa));

    test('get', () => storeTest.Organization.existingOrganization(sa));

    test('get (non-existing)',
        () => storeTest.Organization.nonExistingOrganization(sa));

    test('list', () => storeTest.Organization.list(sa));

    test('Contact list',
        () => storeTest.Organization.existingOrganizationContacts(sa));

    test('Contact list (non-existing organization)',
        () => storeTest.Organization.nonExistingOrganizationContacts(sa));

    test('Reception listing',
        () => storeTest.Organization.existingOrganizationReceptions(sa));

    test('Reception listing Non-existing organization',
        () => storeTest.Organization.nonExistingOrganizationReceptions(sa));
  });
}
