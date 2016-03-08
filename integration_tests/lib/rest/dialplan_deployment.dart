part of openreception_tests.service;

runDialplanDeploymentTests() {
  group('DialplanDeployment', () {
    esl.Connection eslClient;
    transport.Client client = null;
    service.RESTDialplanStore rdpStore = null;
    service.RESTReceptionStore receptionStore = null;
    Customer customer = null;

    Logger _log = new Logger('$_namespace.DialplanDeployment');

    Future authenticate(esl.Connection client) =>
        client.authenticate(Config.eslPassword).then((reply) {
          if (reply.status != esl.Reply.OK) {
            _log.shout('ESL Authentication failed - exiting');
            throw new StateError('Not authenticated!');
          }
        });

    setUp(() async {
      eslClient = new esl.Connection();
      client = new transport.Client();
      rdpStore = new service.RESTDialplanStore(
          Config.dialplanStoreUri, Config.serverToken, client);
      receptionStore = new service.RESTReceptionStore(
          Config.receptionStoreUri, Config.serverToken, client);
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
      client.client.close(force: true);

      await customer.teardown();
      await eslClient.disconnect();
    });

    test(
        'No opening hours',
        () => DialplanDeployment.noHours(
            customer, rdpStore, receptionStore, eslClient));

    test(
        'Opening hours - open',
        () => DialplanDeployment.openHoursOpen(
            customer, rdpStore, receptionStore, eslClient));

    test(
        'Reception Transfer',
        () => DialplanDeployment.receptionTransfer(
            customer, rdpStore, receptionStore, eslClient));
  });
}
