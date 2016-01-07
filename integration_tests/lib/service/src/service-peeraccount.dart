part of or_test_fw;

abstract class PeerAccountService {
  static Logger _log = new Logger('$libraryName.PeerAccountService');

  /**
   *
   */
  static Future list(Service.PeerAccount paService) async {
    expect(await paService.list(), new isInstanceOf<List>());
  }

  /**
   *
   */
  static Future deploy(Model.User user, Service.PeerAccount paService) async {
    final Model.PeerAccount pa = Randomizer.randomPeerAccount();
    _log.info('Deploying peer account ${pa.toJson()} for user'
        ' ${user.toJson()}');

    await paService.deployAccount(pa, user.ID);
    expect((await paService.list()).contains(pa.username), isTrue);

    await paService.remove(pa.username);
  }

  /**
   *
   */
  static Future remove(Model.User user, Service.PeerAccount paService) async {
    final Model.PeerAccount pa = Randomizer.randomPeerAccount();
    _log.info('Deploying peer account ${pa.toJson()} '
        'for user ${user.toJson()}');

    await paService.deployAccount(pa, user.ID);
    await paService.remove(pa.username);
    expect((await paService.list()).contains(pa.username), isFalse);
  }

  /**
   *
   */
  static Future deployAndRegister(
      Model.User user,
      Service.PeerAccount paService,
      Service.CallFlowControl callFlow,
      Service.RESTDialplanStore dpStore) async {
    final Model.PeerAccount pa = Randomizer.randomPeerAccount();
    _log.info('Deploying peer account ${pa.toJson()} for user'
        ' ${user.toJson()}');

    await paService.deployAccount(pa, user.ID);
    await dpStore.reloadConfig();
    await callFlow.stateReload();

    final Phonio.SIPAccount account = new Phonio.SIPAccount(
        pa.username, pa.password, Config.externalHostname);

    final Phonio.PJSUAProcess phone = new Phonio.PJSUAProcess(
        Config.simpleClientBinaryPath, Config.pjsuaPortAvailablePorts.last);

    phone.addAccount(account);
    await phone.initialize();
    await phone.register();

    await Future.doWhile(() async {
      bool registered = (await callFlow.peerList())
          .firstWhere((peer) => peer.ID == pa.username)
          .registered;

      if (!registered) {
        await new Future.delayed(new Duration(milliseconds: 100));
        return true;
      }
      return false;
    }).timeout(new Duration(seconds: 10));

    await phone.unregister();
    await phone.finalize();

    await paService.remove(pa.username);
  }
}
