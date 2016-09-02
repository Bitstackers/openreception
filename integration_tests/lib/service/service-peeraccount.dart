part of openreception_tests.service;

abstract class PeerAccountService {
  static Logger _log = new Logger('$_namespace.PeerAccountService');

  /**
   *
   */
  static Future list(service.PeerAccount paService) async {
    expect(await paService.list(), new isInstanceOf<List>());
  }

  /**
   *
   */
  static Future deploy(model.User user, service.PeerAccount paService) async {
    final model.PeerAccount pa = Randomizer.randomPeerAccount();
    _log.info('Deploying peer account ${pa.toJson()} for user'
        ' ${user.toJson()}');

    await paService.deployAccount(pa, user.id);
    expect((await paService.list()).contains(pa.username), isTrue);

    await paService.remove(pa.username);
  }

  /**
   *
   */
  static Future remove(model.User user, service.PeerAccount paService) async {
    final model.PeerAccount pa = Randomizer.randomPeerAccount();
    _log.info('Deploying peer account ${pa.toJson()} '
        'for user ${user.toJson()}');

    await paService.deployAccount(pa, user.id);
    await paService.remove(pa.username);
    expect((await paService.list()).contains(pa.username), isFalse);
  }

  /**
   *
   */
  static Future deployAndRegister(
      model.User user,
      service.PeerAccount paService,
      service.CallFlowControl callFlow,
      service.RESTDialplanStore dpStore,
      String externalHostname) async {
    final model.PeerAccount pa = Randomizer.randomPeerAccount();
    _log.info('Deploying peer account ${pa.toJson()} for user'
        ' ${user.toJson()}');

    await paService.deployAccount(pa, user.id);
    await dpStore.reloadConfig();
    await callFlow.stateReload();

    final phonio.SIPAccount account =
        new phonio.SIPAccount(pa.username, pa.password, externalHostname);

    final phonio.PJSUAProcess phone = new phonio.PJSUAProcess(
        config.simpleClientBinaryPath, config.pjsuaPortAvailablePorts.last);

    phone.addAccount(account);
    await phone.initialize();
    await phone.register();

    await Future.doWhile(() async {
      bool registered = (await callFlow.peerList())
          .firstWhere((peer) => peer.name == pa.username)
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
