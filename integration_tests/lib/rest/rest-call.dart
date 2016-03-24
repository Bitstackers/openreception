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
    Receptionist r;
    Customer c;

    /// Transient object
    model.ReceptionDialplan rdp;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();

      final org = await sa.createsOrganization();
      final rec = await sa.createsReception(org);
      rdp = await sa.createsDialplan();
      await sa.deploysDialplan(rdp, rec);

      r = await sa.createsReceptionist();
      c = await sa.spawnCustomer();
    });

    tearDown(() async {
      //log.finest('FSLOG:\n ${fsProcess.latestLog.readAsStringSync()}');
      await env.clear();
    });

    test(
        'CORS headers present (existingUri)',
        () async => isCORSHeadersPresent(
            resource.CallFlowControl
                .list((await env.requestCallFlowProcess()).uri),
            log));

    test(
        'CORS headers present (non-existingUri)',
        () async => isCORSHeadersPresent(
            Uri.parse(
                '${(await env.requestCallFlowProcess()).uri}/nonexistingpath'),
            log));

    test(
        'Non-existing path',
        () async => nonExistingPath(
            Uri.parse(
                '${(await env.requestCallFlowProcess()).uri}/nonexistingpath'
                '?token=${sa.authToken.tokenName}'),
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
    Receptionist r;
    Customer c;

    /// Transient object
    model.ReceptionDialplan rdp;
    model.Reception rec;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();

      final org = await sa.createsOrganization();
      rec = await sa.createsReception(org);
      rdp = await sa.createsDialplan();
      await sa.deploysDialplan(rdp, rec);

      r = await sa.createsReceptionist();
      c = await sa.spawnCustomer();
    });

    tearDown(() async {
      //log.finest('FSLOG:\n ${fsProcess.latestLog.readAsStringSync()}');
      await env.clear();
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
    ServiceAgent sa;
    TestEnvironment env;
    Receptionist r;
    Receptionist r2;
    Customer c;

    /// Transient object
    model.ReceptionDialplan rdp;
    model.Reception rec;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();

      final org = await sa.createsOrganization();
      rec = await sa.createsReception(org);
      rdp = await sa.createsDialplan();
      await sa.deploysDialplan(rdp, rec);

      r = await sa.createsReceptionist();
      r2 = await sa.createsReceptionist();
      c = await sa.spawnCustomer();
    });

    tearDown(() async {
      //log.finest('FSLOG:\n ${fsProcess.latestLog.readAsStringSync()}');
      await env.clear();
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

    test('pickupAllocatedCall',
        () => serviceTest.Pickup.pickupAllocatedCall(rdp, r, r2, c));

    test('pickupRace', () => serviceTest.Pickup.pickupRace(rdp, r, r2, c));
  });
}
