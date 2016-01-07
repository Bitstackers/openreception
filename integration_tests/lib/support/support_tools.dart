part of or_test_fw;

class SupportTools {
  List<Receptionist> receptionists = [];
  List<Customer> customers = [];

  static final Logger log = new Logger('Test.SupportTools');

  static SupportTools _instance = null;
  Completer _ready = new Completer();

  static SupportTools fig = _instance;

  static Future<SupportTools> get instance {
    if (_instance == null) {
      SupportTools testFramework = new SupportTools();
      _instance = testFramework;

      _instance._initialize();
    }

    if (_instance._ready.isCompleted) {
      return new Future.value(_instance);
    } else {
      return _instance._ready.future.then((_) => _instance);
    }
  }

  void outputState() {
    log.shout('Receptionists: '
        '${ReceptionistPool.instance.busy.length}/'
        '${ReceptionistPool.instance.available.length}, '
        'Customers: ${CustomerPool.instance.busy.length}/'
        '${CustomerPool.instance.available.length}');
  }

  /// Maps token to a User object.
  Map<String, Model.User> tokenMap = {};

  /// Maps a peerID to a token.
  Map<String, String> peerMap = {};

  Future buildUserMap() {
    Transport.Client transport = new Transport.Client();
    Service.Authentication authService = new Service.Authentication(
        Config.authenticationServerUri, Config.serverToken, transport);

    return Future
        .forEach(
            Config.authTokens,
            ((String token) =>
                authService.userOf(token).then((Model.User user) {
                  tokenMap[token] = user;
                  peerMap[user.peer] = token;
                })))
        .whenComplete(() => transport.client.close(force: true));
  }

  Future setupReceptionists() => Future.doWhile(() {
        if (Config.authTokens.isEmpty) {
          return false;
        }

        Phonio.SIPAccount account = ConfigPool.requestLocalSipAccount();
        String token = peerMap[account.username];
        Phonio.SIPPhone phone = new Phonio.PJSUAProcess(
            Config.simpleClientBinaryPath, ConfigPool.requestPjsuaPort());
        Model.User user = tokenMap[token];

        phone.addAccount(account);

        Receptionist receptionist = new Receptionist(phone, token, user);

        receptionists.add(receptionist);
        return ConfigPool.hasAvailableLocalSipAccount();
      }).whenComplete(() =>
          ReceptionistPool.instance = new ReceptionistPool(receptionists));

  Future setupCustomers() => Future.doWhile(() {
        Phonio.SIPAccount account = ConfigPool.requestExternalSIPAccount();
        Phonio.SIPPhone phone = new Phonio.PJSUAProcess(
            Config.simpleClientBinaryPath, ConfigPool.requestPjsuaPort());

        phone.addAccount(account);

        customers.add(new Customer(phone));

        return ConfigPool.hasAvailableExternalSipAccount();
      }).whenComplete(
          () => CustomerPool.instance = new CustomerPool(customers));

  Future tearDownReceptionists() => Future.wait(receptionists
      .map((Receptionist receptionist) => receptionist.finalize()));

  Future tearDownCustomers() =>
      Future.wait(customers.map((Customer customer) => customer.finalize()));

  Future _initialize() => this
      .buildUserMap()
      .then((_) => createPeerAccounts())
      .then((_) => this.setupCustomers())
      .then((_) => this.setupReceptionists())
      .then((_) => this._ready.complete())
      .catchError(this._ready.completeError)
      .whenComplete(() => log.info(this));

  /**
   * Tear down the state of the support tools.
   */
  Future tearDown() async {
    await Future.wait([
      tearDownCustomers(),
      tearDownReceptionists(),
      removePeerAccounts()]);
    ConfigPool.resetCounters();
  }

  /**
   *
   */
  Future createPeerAccounts() {
    Transport.Client transport = new Transport.Client();

    Service.RESTDialplanStore rdpStore = new Service.RESTDialplanStore(
        Config.dialplanStoreUri, Config.serverToken, transport);

    Service.CallFlowControl callFlow = new Service.CallFlowControl(
        Config.CallFlowControlUri, Config.serverToken, transport);

    Service.PeerAccount paService = new Service.PeerAccount(
        Config.dialplanStoreUri, Config.serverToken, transport);

    Iterable peerAccounts = Config.localSipAccounts.map(
        (Phonio.SIPAccount acc) =>
            new Model.PeerAccount(acc.username, acc.password, 'receptions'));

    log.info(tokenMap[peerMap[peerAccounts.first.username]].ID);

    return Future
        .wait(peerAccounts.map((pa) =>
            paService.deployAccount(pa, tokenMap[peerMap[pa.username]].ID)))
        .then((_) => rdpStore.reloadConfig())
        .then((_) => callFlow.stateReload())
        .whenComplete(() => transport.client.close(force: true));
  }

  /**
   *
   */
  Future removePeerAccounts() {
    Transport.Client transport = new Transport.Client();

    Service.PeerAccount paService = new Service.PeerAccount(
        Config.dialplanStoreUri, Config.serverToken, transport);

    Service.RESTDialplanStore rdpStore = new Service.RESTDialplanStore(
        Config.dialplanStoreUri, Config.serverToken, transport);

    Service.CallFlowControl callFlow = new Service.CallFlowControl(
        Config.CallFlowControlUri, Config.serverToken, transport);

    Iterable peerAccounts = Config.localSipAccounts.map(
        (Phonio.SIPAccount acc) =>
            new Model.PeerAccount(acc.username, acc.password, 'receptionists'));

    log.info(tokenMap[peerMap[peerAccounts.first.username]].ID);

    return Future
        .wait(peerAccounts.map((pa) => paService.remove(pa.username)))
        .then((_) => rdpStore.reloadConfig())
        .then((_) => callFlow.stateReload())
        .whenComplete(() => transport.client.close(force: true));
  }

  @override
  String toString() {
    Iterable tokenMappings =
        tokenMap.keys.map((String key) => '$key -> ${tokenMap[key].asSender}');

    Iterable peerMappings =
        peerMap.keys.map((String key) => '$key -> ${peerMap[key]}');

    return 'Support tools state:\n'
        ' Token map:\n'
        '  ${tokenMappings.join('\n  ')}\n'
        ' Peer map:\n'
        '  ${peerMappings.join('\n  ')}\n'
        ' Receptionists:\n'
        '  ${receptionists.join('\n  ')}\n'
        ' Customers:\n'
        '  ${customers.join('\n  ')}\n';
  }
}
