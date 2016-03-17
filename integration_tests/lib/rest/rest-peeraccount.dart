part of openreception_tests.rest;

_runPeerAccountTests() {
  group('$_namespace.PeerAccount', () {
    Logger log = new Logger('$_namespace.PeerAccount');
    service.Client client;
    service.PeerAccount paService;
    service.RESTUserStore userStore;
    service.CallFlowControl callFlow;
    service.RESTDialplanStore dpStore;
    model.User user;

    test(
        'CORS headers present (existingUri)',
        () => isCORSHeadersPresent(
            resource.PeerAccount.list(Config.dialplanStoreUri), log));

    test(
        'CORS headers present (non-existingUri)',
        () => isCORSHeadersPresent(
            Uri.parse('${Config.dialplanStoreUri}/nonexistingpath'), log));

    test(
        'Non-existing path',
        () => nonExistingPath(
            Uri.parse('${Config.dialplanStoreUri}/nonexistingpath'
                '?token=${Config.serverToken}'),
            log));

    setUp(() async {
      client = new service.Client();
      paService = new service.PeerAccount(
          Config.dialplanStoreUri, Config.serverToken, client);
    });

    tearDown(() async {
      paService = null;
      client.client.close(force: true);
    });

    test('list', () => serviceTest.PeerAccountService.list(paService));

    setUp(() async {
      client = new service.Client();
      userStore = new service.RESTUserStore(
          Config.userStoreUri, Config.serverToken, client);
      paService = new service.PeerAccount(
          Config.dialplanStoreUri, Config.serverToken, client);
      user = await userStore
          .create(Randomizer.randomUser(), null)
          .then((uRef) => userStore.get(uRef.id));
    });

    tearDown(() async {
      paService = null;
      client.client.close(force: true);
      await userStore.remove(user.id, null);
    });

    test(
        'remove', () => serviceTest.PeerAccountService.remove(user, paService));

    test(
        'deploy', () => serviceTest.PeerAccountService.deploy(user, paService));

    setUp(() async {
      client = new service.Client();
      userStore = new service.RESTUserStore(
          Config.userStoreUri, Config.serverToken, client);
      paService = new service.PeerAccount(
          Config.dialplanStoreUri, Config.serverToken, client);
      callFlow = new service.CallFlowControl(
          Config.CallFlowControlUri, Config.serverToken, client);
      dpStore = new service.RESTDialplanStore(
          Config.dialplanStoreUri, Config.serverToken, client);
      user = await userStore
          .create(Randomizer.randomUser(), null)
          .then((uref) => userStore.get(uref.id));
    });

    tearDown(() async {
      client.client.close(force: true);
      await userStore.remove(user.id, null);
    });

    test(
        'deployAndRegister',
        () => serviceTest.PeerAccountService
            .deployAndRegister(user, paService, callFlow, dpStore));
  });
}
