part of openreception_tests.rest;

void _runCallTests() {
  //_runCallHangupTests();
  //_callFlowControlList();
  _callFlowControlPickup();
}

void _runCallHangupTests() {
  group('$_namespace.Call', () {
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
      //log.finest((await callflow.peerList()).map((p) => p.toJson()).join('\n'));
    });

    tearDown(() async {
      await Future.wait([
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
        'CORS headers present (existingUri)',
        () => isCORSHeadersPresent(
            resource.CallFlowControl.list(Config.CallFlowControlUri), log));

    test(
        'CORS headers present (non-existingUri)',
        () => isCORSHeadersPresent(
            Uri.parse('${Config.CallFlowControlUri}/nonexistingpath'), log));

    test(
        'Non-existing path',
        () => nonExistingPath(
            Uri.parse('${Config.CallFlowControlUri}/nonexistingpath'
                '?token=${authToken.tokenName}'),
            log));

    test('interfaceCallNotFound',
        () => serviceTest.Hangup.interfaceCallNotFound(sa));

    test('eventPresence', () => serviceTest.Hangup.eventPresence(rdp, r, c));

    test('hangupCause', () => serviceTest.Hangup.hangupCause(rdp, r, c));

    test('interfaceCallFound',
        () => serviceTest.Hangup.interfaceCallFound(rdp, r, c));
  });
}

/**
 * CallFlowControl Call listing.
 */
void _callFlowControlList() {
  group('$_namespace.Call', () {
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
    model.Reception rec;

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
      rec = await sa.createsReception(org);
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
      //log.finest((await callflow.peerList()).map((p) => p.toJson()).join('\n'));
    });

    tearDown(() async {
      await Future.wait([
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

    test('callDataOK', () => serviceTest.CallList.callDataOK(rec, rdp, r, c));

    test('interfaceCallFound',
        () => serviceTest.CallList.callPresence(rdp, r, c));

    test('queueLeaveEventFromPickup',
        () => serviceTest.CallList.queueLeaveEventFromPickup(rdp, r, c));

    test('queueLeaveEventFromHangup',
        () => serviceTest.CallList.queueLeaveEventFromHangup(rdp, r, c));
  });
}

/**
 * CallFlowControl Call pickup.
 */
void _callFlowControlPickup() {
  group('$_namespace.Call', () {
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
    Receptionist r2;
    Customer c;
    model.Reception rec;

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
      rec = await sa.createsReception(org);
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
      //log.finest((await callflow.peerList()).map((p) => p.toJson()).join('\n'));
    });

    tearDown(() async {
      await Future.wait([
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

    /* Perform test. */
    test(
        'pickupSpecified', () => serviceTest.Pickup.pickupSpecified(rdp, r, c));

    test('pickupUnspecified',
        () => serviceTest.Pickup.pickupUnspecified(rdp, r, c));

    test('pickupNonExistingCall',
        () => serviceTest.Pickup.pickupNonExistingCall(r));

    test('pickupLockedCall',
        () => serviceTest.Pickup.pickupLockedCall(rdp, r, c));

    test(
        'pickupCallTwice', () => serviceTest.Pickup.pickupCallTwice(rdp, r, c));

    test('pickupEventInboundCall',
        () => serviceTest.Pickup.pickupEventInboundCall(rdp, r, c));

    test(
        'pickupEventOutboundCall',
        () => serviceTest.Pickup.pickupEventOutboundCall(
            new model.OriginationContext()
              ..receptionId = rec.id
              ..dialplan = rdp.extension,
            r,
            c));

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
      rec = await sa.createsReception(org);
      rdp = await sa.createsDialplan();
      await sa.deploysDialplan(rdp, rec);

      r = await sa.createsReceptionist();
      r2 = await sa.createsReceptionist();
      c = await sa.spawnCustomer();
      log.finest('Restarting authserver');
      await aProcess.terminate();
      aProcess = new process.AuthServer(
          Config.serverStackPath, env.runpath.path, intialTokens: [
        authToken,
        new AuthToken(r.user),
        new AuthToken(r2.user)
      ]);
      await aProcess.whenReady;

      final registerEvent = sa.notificationSocket.eventStream.firstWhere((e) =>
          e is event.PeerState &&
          e.peer.name == r.user.peer &&
          e.peer.registered);

      await r.initialize();

      await registerEvent;
      //log.finest((await callflow.peerList()).map((p) => p.toJson()).join('\n'));
    });

    tearDown(() async {
      await Future.wait([
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

    test('pickupAllocatedCall',
        () => serviceTest.Pickup.pickupAllocatedCall(rdp, r, r2, c));

    test('pickupRace', () => serviceTest.Pickup.pickupRace(rdp, r, r2, c));
  });
}
