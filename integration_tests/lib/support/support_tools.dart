part of or_test_fw;

class SupportTools {
  List<Receptionist> receptionists = [];
  List<Customer> customers = [];

  static SupportTools _instance = null;
  Completer _ready = new Completer();

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

  /// Maps token to a User object.
  Map<String, Model.User> tokenMap = {};

  /// Maps a peerID to a token.
  Map<String, String> peerMap = {};

  Service.Authentication authService = new Service.Authentication
      (Config.authenticationServerUri, Config.serverToken, new Transport.Client());

  Future buildUserMap() =>
      Future.forEach(Config.authTokens, ((String token) =>
          authService.userOf(token).then((Model.User user) {
              tokenMap[token] = user;
              peerMap[user.peer] = token;
      })));


  Future setupReceptionists() =>
    Future.doWhile(() {

      Phonio.SIPAccount account = ConfigPool.requestLocalSipAccount();
      String token = peerMap[account.username];
      Phonio.SIPPhone phone = new Phonio.PJSUAProcess(Config.simpleClientBinaryPath, ConfigPool.requestPjsuaPort());
      Model.User user = tokenMap[token];

      phone.addAccount(account);

      Receptionist receptionist = new Receptionist(phone, token, user);

      receptionists.add(receptionist);
      return ConfigPool.hasAvailableLocalSipAccount();

    })
    .whenComplete(() =>
        ReceptionistPool.instance = new ReceptionistPool(receptionists));

  Future initializeReceptionists() =>
      Future.forEach (receptionists,
          (Receptionist receptionist) => receptionist.initialize());

  Future setupCustomers() =>
    Future.doWhile(() {

    Phonio.SIPAccount account = ConfigPool.requestExternalSIPAccount();
    Phonio.SIPPhone phone = new Phonio.PJSUAProcess(Config.simpleClientBinaryPath, ConfigPool.requestPjsuaPort());

      phone.addAccount(account);

      customers.add(new Customer(phone));


      return ConfigPool.hasAvailableExternalSipAccount();
    })
    .whenComplete(() =>
        CustomerPool.instance = new CustomerPool(customers));

  Future initializeCustomers() =>
      Future.forEach (customers,
          (Customer customer) => customer.initialize());

  Future tearDownReceptionists () => Future.forEach(receptionists,
      ((Receptionist receptionist) => receptionist.teardown()));

  Future tearDownCustomers () => Future.forEach(customers,
      ((Customer customer) => customer.teardown()));


  void printCustomers() => customers.forEach(print);

  void printReceptionists() => receptionists.forEach(print);

  Future _initialize() =>
      this.buildUserMap()
      .then((_) => this.setupCustomers())
      .then((_) => this.setupReceptionists())
      .then((_) => this._ready.complete())
      .catchError(this._ready.completeError);

  Future tearDown() =>
      Future.wait([this.tearDownCustomers(),
                   this.tearDownReceptionists()])
            .then((_) => ConfigPool.resetCounters());
}



