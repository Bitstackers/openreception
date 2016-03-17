part of openreception_tests.rest;

runDialplanTests() {
  Logger log = new Logger('$_namespace.dialplan');

  group('Service.Dialplan', () {
    service.Client client = null;
    service.RESTDialplanStore rdpStore = null;
    service.RESTReceptionStore receptionStore = null;

    test(
        'CORS headers present (existingUri)',
        () => isCORSHeadersPresent(
            resource.ReceptionDialplan.list(Config.dialplanStoreUri), log));

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

    setUp(() {
      client = new service.Client();
      rdpStore = new service.RESTDialplanStore(
          Config.dialplanStoreUri, Config.serverToken, client);
    });

    tearDown(() {
      rdpStore = null;
      client.client.close(force: true);
    });

    test('create', () => serviceTest.ReceptionDialplanStore.create(rdpStore));

    test('get', () => serviceTest.ReceptionDialplanStore.get(rdpStore));

    test('list', () => serviceTest.ReceptionDialplanStore.list(rdpStore));

    test('remove', () => serviceTest.ReceptionDialplanStore.remove(rdpStore));

    test('update', () => serviceTest.ReceptionDialplanStore.update(rdpStore));

    setUp(() {
      client = new service.Client();
      rdpStore = new service.RESTDialplanStore(
          Config.dialplanStoreUri, Config.serverToken, client);
      receptionStore = new service.RESTReceptionStore(
          Config.receptionStoreUri, Config.serverToken, client);
    });

    tearDown(() {
      rdpStore = null;
      receptionStore = null;
      client.client.close(force: true);
    });

    test(
        'deploy',
        () => serviceTest.ReceptionDialplanStore
            .deploy(rdpStore, receptionStore));
  });
}

runDialplanDeploymentTests() {
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
    process.CallFlowControl cProcess;
    process.DialplanServer dProcess;
    process.AuthServer aProcess;
    process.NotificationServer nProcess;
    process.FreeSwitch fsProcess;
    process.UserServer uProcess;
    service.Client client;
    AuthToken authToken;
    Receptionist r;
    Customer c;

    /// Transient object
    model.ReceptionDialplan rdp;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
      client = new service.Client();
      authToken = new AuthToken(sa.user);
      sa.authToken = authToken.tokenName;

      nProcess = new process.NotificationServer(
          Config.serverStackPath, env.runpath.path);

      aProcess = new process.AuthServer(
          Config.serverStackPath, env.runpath.path,
          intialTokens: [authToken]);

      fsProcess = await env.freeswitchProcess;

      uProcess =
          new process.UserServer(Config.serverStackPath, env.runpath.path);

      dProcess = new process.DialplanServer(
          Config.serverStackPath, env.runpath.path, fsProcess.confPath);

      cProcess =
          new process.CallFlowControl(Config.serverStackPath, env.runpath.path);

      sa.callflow = new service.CallFlowControl(
          Config.CallFlowControlUri, authToken.tokenName, client);

      await new Future.delayed(new Duration(seconds: 3));
      await Future.wait([
        aProcess.whenReady,
        nProcess.whenReady,
        uProcess.whenReady,
        cProcess.whenReady,
        dProcess.whenReady
      ]);

      sa.paService = new service.PeerAccount(
          Config.dialplanStoreUri, sa.authToken, client);
      sa.dpService = new service.RESTDialplanStore(
          Config.dialplanStoreUri, sa.authToken, client);

      final org = await sa.createsOrganization();
      final rec = await sa.createsReception(org);
      rdp = await sa.createsDialplan();
      await sa.deploysDialplan(rdp, rec);

      r = await sa.createsReceptionist();
      c = await sa.spawnCustomer();
      log.finest('Restarting authserver');
      await aProcess.terminate();
      aProcess = new process.AuthServer(
          Config.serverStackPath, env.runpath.path,
          intialTokens: [authToken, new AuthToken(r.user)]);
      await aProcess.whenReady;

      final registerEvent = sa.notificationSocket.eventStream.firstWhere((e) =>
          e is event.PeerState &&
          e.peer.name == r.user.peer &&
          e.peer.registered);

      await r.initialize();

      await registerEvent;

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
      await Future.wait([
        eslClient.disconnect(),
        dProcess.terminate(),
        cProcess.terminate(),
        uProcess.terminate(),
        aProcess.terminate(),
        nProcess.terminate(),
        fsProcess.cleanConfig()
      ]);
      log.finest('FSLOG:\n ${fsProcess.latestLog.readAsStringSync()}');
      await env.clear();
      client.client.close();
    });

    test(
        'No opening hours',
        () => serviceTest.DialplanDeployment
            .noHours(c, sa.dpService, sa.receptionStore, eslClient));

    test(
        'Opening hours - open',
        () => serviceTest.DialplanDeployment
            .openHoursOpen(c, sa.dpService, sa.receptionStore, eslClient));

    test(
        'Reception Transfer',
        () => serviceTest.DialplanDeployment
            .receptionTransfer(c, sa.dpService, sa.receptionStore, eslClient));
  });
}
