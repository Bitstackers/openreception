part of openreception_tests.rest;

void _runUserTests() {
  group('$_namespace.User', () {
    Logger log = new Logger('$_namespace.User');

    ServiceAgent sa;
    TestEnvironment env;
    process.UserServer uProcess;
    process.AuthServer aProcess;
    service.Client client;
    AuthToken authToken;
    service.RESTUserStore restStore;

    process.NotificationServer nServer;
    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
      client = new service.Client();
      authToken = sa.authToken;

      aProcess = new process.AuthServer(
          Config.serverStackPath, env.runpath.path,
          intialTokens: [authToken]);

      nServer = new process.NotificationServer(
          Config.serverStackPath, env.runpath.path);

      uProcess =
          new process.UserServer(Config.serverStackPath, env.runpath.path);
      restStore = new service.RESTUserStore(
          Config.userStoreUri, authToken.tokenName, client);
      sa.userStore = restStore;
      await Future
          .wait([uProcess.whenReady, aProcess.whenReady, nServer.whenReady]);
    });

    tearDown(() async {
      await Future.wait(
          [uProcess.terminate(), aProcess.terminate(), nServer.terminate()]);
      env.clear();
      client.client.close();
      sa.cleanup();
    });

    test(
        'CORS headers present (existingUri)',
        () =>
            isCORSHeadersPresent(resource.User.list(Config.userStoreUri), log));

    test(
        'CORS headers present (non-existingUri)',
        () => isCORSHeadersPresent(
            Uri.parse('${Config.userStoreUri}/nonexistingpath'), log));

    test(
        'Non-existing path',
        () => nonExistingPath(
            Uri.parse('${Config.userStoreUri}/nonexistingpath'
                '?token=${authToken.tokenName}'),
            log));

    test('get', () => storeTest.User.existing(sa));

    test('get (not found)', () => storeTest.User.nonExisting(sa));

    test('create', () => storeTest.User.create(sa));

    test('update', () => storeTest.User.update(sa));

    test('remove', () => storeTest.User.update(sa));

    test('list', () => storeTest.User.list(sa));

    test('groups', () => storeTest.User.listAllGroups(sa));

    test('groups of (known user)', () => storeTest.User.userGroups(sa));

    test('group join', () => storeTest.User.joinGroup(sa));

    test('group leave', () => storeTest.User.leaveGroup(sa));

    test('identity add', () => storeTest.User.addUserIdentity(sa));

    test('identity remove', () => storeTest.User.removeUserIdentity(sa));

    test('get (by identity)', () => storeTest.User.getUserByIdentity(sa));

    /*
     * Service-specific tests.
     */

    test('userState change', () => serviceTest.User.stateChange(sa, restStore));

    test('userState change (event)',
        () => serviceTest.User.stateChangeEvent(sa, restStore));

    test('create (event presence)', () => serviceTest.User.createEvent(sa));

    test('update (event presence)', () => serviceTest.User.updateEvent(sa));

    test('remove (event presence)', () => serviceTest.User.deleteEvent(sa));
  });
}
