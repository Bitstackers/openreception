part of or_test_fw;

runPeerAccountTests() {
  group('Service.PeerAccount', () {
    Transport.Client transport;
    Service.PeerAccount paService;
    Service.RESTUserStore userStore;
    Service.CallFlowControl callFlow;
    Service.RESTDialplanStore dpStore;
    Model.User user;

    test(
        'CORS headers present (existingUri)',
        () => isCORSHeadersPresent(
            Resource.PeerAccount.list(Config.dialplanStoreUri)));

    test(
        'CORS headers present (non-existingUri)',
        () => isCORSHeadersPresent(
            Uri.parse('${Config.dialplanStoreUri}/nonexistingpath')));

    test(
        'Non-existing path',
        () => nonExistingPath(
            Uri.parse('${Config.dialplanStoreUri}/nonexistingpath'
                '?token=${Config.serverToken}')));

    setUp(() async {
      transport = new Transport.Client();
      paService = new Service.PeerAccount(
          Config.dialplanStoreUri, Config.serverToken, transport);
    });

    tearDown(() async {
      paService = null;
      transport.client.close(force: true);
    });

    test('list', () => PeerAccountService.list(paService));

    setUp(() async {
      transport = new Transport.Client();
      userStore = new Service.RESTUserStore(
          Config.userStoreUri, Config.serverToken, transport);
      paService = new Service.PeerAccount(
          Config.dialplanStoreUri, Config.serverToken, transport);
      user = await userStore.create(Randomizer.randomUser());
    });

    tearDown(() async {
      paService = null;
      transport.client.close(force: true);
      await userStore.remove(user.ID);
    });

    test('remove', () => PeerAccountService.remove(user, paService));

    test('deploy', () => PeerAccountService.deploy(user, paService));

    setUp(() async {
      transport = new Transport.Client();
      userStore = new Service.RESTUserStore(
          Config.userStoreUri, Config.serverToken, transport);
      paService = new Service.PeerAccount(
          Config.dialplanStoreUri, Config.serverToken, transport);
      callFlow = new Service.CallFlowControl(
          Config.CallFlowControlUri, Config.serverToken, transport);
      dpStore = new Service.RESTDialplanStore(
          Config.dialplanStoreUri, Config.serverToken, transport);
      user = await userStore.create(Randomizer.randomUser());
    });

    tearDown(() async {
      transport.client.close(force: true);
      await userStore.remove(user.ID);
    });

    test(
        'deploy',
        () => PeerAccountService.deployAndRegister(
            user, paService, callFlow, dpStore));
  });
}
