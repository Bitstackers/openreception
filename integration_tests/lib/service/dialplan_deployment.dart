part of or_test_fw;

runDialplanDeploymentTests() {
  group('DialplanDeployment', () {
    esl.Connection eslClient;
    Transport.Client transport = null;
    Service.RESTDialplanStore rdpStore = null;
    Service.RESTReceptionStore receptionStore = null;
    Customer customer = null;

    Logger _log = new Logger('$libraryName.DialplanDeployment');

    Future authenticate(esl.Connection client) =>
        client.authenticate(Config.eslPassword).then((reply) {
          if (reply.status != esl.Reply.OK) {
            _log.shout('ESL Authentication failed - exiting');
            throw new StateError('Not authenticated!');
          }
        });

    setUp(() async {
      eslClient = new esl.Connection();
      transport = new Transport.Client();
      rdpStore = new Service.RESTDialplanStore(
          Config.dialplanStoreUri, Config.serverToken, transport);
      receptionStore = new Service.RESTReceptionStore(
          Config.receptionStoreUri, Config.serverToken, transport);
      customer = CustomerPool.instance.aquire();

      Future authentication = eslClient.requestStream
          .firstWhere(
              (packet) => packet.contentType == esl.ContentType.Auth_Request)
          .then((_) => authenticate(eslClient));

      await eslClient.connect(Config.eslHost, Config.eslPort);
      await authentication;

      await customer.initialize();
    });

    tearDown(() async {
      rdpStore = null;
      receptionStore = null;
      transport.client.close(force: true);

      await customer.teardown();
      await eslClient.disconnect();
    });

    test(
        'No opening hours',
        () => DialplanDeployment.noHours(
            customer, rdpStore, receptionStore, eslClient));

    test(
        'Opening hours - open',
        () => DialplanDeployment.openHoursOpen (
            customer, rdpStore, receptionStore, eslClient));
  });
}
