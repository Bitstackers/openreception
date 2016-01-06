part of or_test_fw;

abstract class PeerAccountService {
  static Logger _log = new Logger('$libraryName.PeerAccountService');

  /**
   *
   */
  static Future list(Service.PeerAccount paService) async {

    expect (await paService.list(), new isInstanceOf<List>());
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
}
