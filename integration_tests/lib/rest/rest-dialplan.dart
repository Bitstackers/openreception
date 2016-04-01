part of openreception_tests.rest;

_runDialplanTests() {
  Logger log = new Logger('$_namespace.dialplan');

  group('rest.Dialplan', () {
    ServiceAgent sa;
    TestEnvironment env;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
    });

    tearDown(() {
      env.clear();
    });

    test(
        'CORS headers present (existingUri)',
        () async => isCORSHeadersPresent(
            resource.ReceptionDialplan
                .list((await env.requestDialplanProcess()).uri),
            log));

    test(
        'CORS headers present (non-existingUri)',
        () async => isCORSHeadersPresent(
            Uri.parse(
                '${(await env.requestDialplanProcess()).uri}/nonexistingpath'),
            log));

    test(
        'Non-existing path',
        () async => nonExistingPath(
            Uri.parse(
                '${(await env.requestDialplanProcess()).uri}/nonexistingpath'
                '?token=${sa.authToken.tokenName}'),
            log));

    /**
     * CRUD tests
     */
    service.RESTDialplanStore rdpStore;
    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
      rdpStore = (await env.requestDialplanProcess())
          .bindDialplanClient(env.httpClient, sa.authToken);
    });

    tearDown(() {
      env.clear();
    });

    test('create', () => storeTest.ReceptionDialplan.create(rdpStore, sa.user));

    test('get', () => storeTest.ReceptionDialplan.get(rdpStore, sa.user));

    test('list', () => storeTest.ReceptionDialplan.list(rdpStore, sa.user));

    test('remove', () => storeTest.ReceptionDialplan.remove(rdpStore, sa.user));

    test('update', () => storeTest.ReceptionDialplan.update(rdpStore, sa.user));

    // /**
    //  * Deploy test.
    //  */
    // service.RESTReceptionStore rStore;
    // setUp(() async {
    //   env = new TestEnvironment();
    //   sa = await env.createsServiceAgent();
    //   rdpStore = (await env.requestDialplanProcess())
    //       .bindDialplanClient(env.httpClient, sa.authToken);
    //   rdpStore = (await env.requestReceptionProcess())
    //       .bindClient(env.httpClient, sa.authToken);
    // });
    //
    // tearDown(() {
    //   env.clear();
    // });
    //
    // test('deploy',
    //     () => serviceTest.ReceptionDialplanStore.deploy(rdpStore, rStore));
  });
}

_runDialplanDeploymentTests() {
  Future authenticate(esl.Connection client) =>
      client.authenticate(Config.eslPassword).then((reply) {
        if (reply.status != esl.Reply.OK) {
          throw new StateError('ESL Authentication failed!');
        }
      });

  group('DialplanDeployment', () {
    esl.Connection eslClient;
    Logger log = new Logger('$_namespace.Call');

    ServiceAgent sa;
    TestEnvironment env;
    process.FreeSwitch fsProcess;
    Customer c;

    /// Transient object
    model.ReceptionDialplan rdp;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();

      fsProcess = await env.requestFreeswitchProcess();

      c = await sa.spawnCustomer();

      final org = await sa.createsOrganization();
      final rec = await sa.createsReception(org);
      rdp = await sa.createsDialplan();
      await sa.deploysDialplan(rdp, rec);

      /// Initilize ESL connection.
      eslClient = new esl.Connection();

      Future authentication = eslClient.requestStream
          .firstWhere(
              (packet) => packet.contentType == esl.ContentType.Auth_Request)
          .then((_) => authenticate(eslClient));

      await eslClient.connect(Config.eslHost, Config.eslPort);
      await authentication;
    });

    tearDown(() async {
      log.finest('FSLOG:\n ${fsProcess.latestLog.readAsStringSync()}');
      await eslClient.disconnect();
      await env.clear();
    });

    test(
        'No opening hours',
        () => serviceTest.DialplanDeployment
            .noHours(c, sa.dialplanService, sa.receptionStore, eslClient));

    test(
        'Opening hours - open',
        () => serviceTest.DialplanDeployment.openHoursOpen(
            c, sa.dialplanService, sa.receptionStore, eslClient));

    test(
        'Reception Transfer',
        () => serviceTest.DialplanDeployment.receptionTransfer(
            c, sa.dialplanService, sa.receptionStore, eslClient));
  });
}
