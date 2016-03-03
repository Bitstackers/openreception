part of openreception_tests.rest;

void _runContactTests() {
  group('$_namespace.Contact', () {
    Logger log = new Logger('$_namespace.Contact');

    ServiceAgent sa;
    TestEnvironment env;
    process.ContactServer cProcess;
    process.AuthServer aProcess;
    transport.Client client;
    AuthToken authToken;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
      client = new transport.Client();
      authToken = new AuthToken(sa.user);

      aProcess = new process.AuthServer(
          Config.serverStackPath, env.runpath.path,
          intialTokens: [authToken]);

      cProcess =
          new process.ContactServer(Config.serverStackPath, env.runpath.path);

      sa.contactStore = new service.RESTContactStore(
          Config.contactStoreUri, authToken.tokenName, client);
      await Future.wait([cProcess.whenReady, aProcess.whenReady]);
    });

    tearDown(() async {
      await Future.wait([cProcess.terminate(), aProcess.terminate()]);
      env.clear();
      client.client.close();
    });
    test(
        'CORS headers present (existingUri)',
        () => isCORSHeadersPresent(
            resource.User.list(Config.contactStoreUri), log));

    test(
        'CORS headers present (non-existingUri)',
        () => isCORSHeadersPresent(
            Uri.parse('${Config.contactStoreUri}/nonexistingpath'), log));

    test(
        'Non-existing path',
        () => nonExistingPath(
            Uri.parse('${Config.contactStoreUri}/nonexistingpath'
                '?token=${authToken.tokenName}'),
            log));

    test('get contact receptionAttributes',
        () => storeTest.Contact.getByReception(sa));

    test('list contacts of organization',
        () => storeTest.Contact.organizationContacts(sa));

    test('list organizations of contact',
        () => storeTest.Contact.organizations(sa));

    test('list receptions of contact', () => storeTest.Contact.receptions(sa));

    test('list', () => storeTest.Contact.list(sa));

    test('get', () => storeTest.Contact.get(sa));

    test('create', () => storeTest.Contact.create(sa));

    test('update', () => storeTest.Contact.update(sa));

    test('remove', () => storeTest.Contact.remove(sa));

    test('get (not found)', () => storeTest.Contact.nonExistingContact(sa));

    test('List contacts by reception',
        () => storeTest.Contact.listByReception(sa));
    test('List contacts by Non-existing reception',
        () => storeTest.Contact.listContactsByNonExistingReception(sa));

    test('endpoint listing', () => storeTest.Contact.endpoints(sa));
    test('endpoint create', () => storeTest.Contact.endpointCreate(sa));
    test('endpoint update', () => storeTest.Contact.endpointUpdate(sa));
    test('endpoint remove', () => storeTest.Contact.endpointRemove(sa));

    test('phone listing', () => storeTest.Contact.phones(sa));

    test('add receptionAttributes', () => storeTest.Contact.addToReception(sa));

    test('update receptionAttributes',
        () => storeTest.Contact.updateInReception(sa));

    test('delete receptionAttributes',
        () => storeTest.Contact.deleteFromReception(sa));
  });
}
