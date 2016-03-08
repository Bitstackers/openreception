part of openreception_tests.service;

void runCallFlowTests() {
  _callFlowControlActiveRecording();
  _callFlowControlHangup();
  _callFlowControlList();
  _callFlowControlTransfer();
  _callFlowControlPeer();
  _callFlowControlPickup();
  _callFlowControlOriginate();
  _callFlowControlPark();
  _callFlowControlUserState();
  _callFlowControlStateReload();
}

/**
 * CallFlowControl active recordings tests.
 */
void _callFlowControlActiveRecording() {
  group('CallFlowControl.ActiveRecording', () {
    service.CallFlowControl callFlow;
    transport.Client client;

    setUp(() {
      client = new transport.Client();

      callFlow = new service.CallFlowControl(
          Config.CallFlowControlUri, Config.serverToken, client);
    });

    tearDown(() {
      client.client.close(force: true);
    });

    test('empty list', () => ActiveRecording.listEmpty(callFlow));

    test('non-existing recording',
        () => ActiveRecording.getNonExisting(callFlow));
  });
}

/**
 * CallFlowControl Call hangup - using Receptionist objects.
 */
void _callFlowControlHangup() {
  group('CallFlowControl.Hangup', () {
    Receptionist receptionist = null;
    Customer customer = null;

    setUp(() {
      receptionist = ReceptionistPool.instance.aquire();
      customer = CustomerPool.instance.aquire();
      return Future.wait([receptionist.initialize(), customer.initialize()]);
    });

    tearDown(() {
      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(customer);

      return Future.wait([receptionist.teardown(), customer.teardown()]);
    });

    test(
        'interfaceCallNotFound',
        () => expect(Hangup.interfaceCallNotFound(receptionist.callFlowControl),
            throwsA(new isInstanceOf<storage.NotFound>())));

    test('eventPresence', () => Hangup.eventPresence(receptionist, customer));

    test('hangupCause', () => Hangup.hangupCause(receptionist, customer));

    test('interfaceCallFound',
        () => Hangup.interfaceCallFound(receptionist, customer));
  });
}

/**
 * CallFlowControl Call listing.
 */
void _callFlowControlList() {
  group('CallFlowControl.List', () {
    Receptionist receptionist;
    Customer customer;

    setUp(() {
      receptionist = ReceptionistPool.instance.aquire();
      customer = CustomerPool.instance.aquire();
      return Future.wait([receptionist.initialize(), customer.initialize()]);
    });

    tearDown(() {
      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(customer);

      return Future.wait([receptionist.teardown(), customer.teardown()]);
    });

    test('callDataOK', () => CallList.callDataOK(receptionist, customer));

    test('interfaceCallFound',
        () => CallList.callPresence(receptionist, customer));

    test('queueLeaveEventFromPickup',
        () => CallList.queueLeaveEventFromPickup(receptionist, customer));

    test('queueLeaveEventFromHangup',
        () => CallList.queueLeaveEventFromHangup(receptionist, customer));
  });
}

/**
 * CallFlowControl Call transfer.
 */
void _callFlowControlTransfer() {
  group('CallFlowControl.Transfer', () {
    Receptionist receptionist;
    Customer caller;
    Customer callee;
    transport.Client client;
    service.RESTReceptionStore receptionStore;
    service.RESTContactStore contactStore;
    service.RESTDialplanStore rdpStore;
    model.OriginationContext context;

    setUp(() async {
      receptionist = ReceptionistPool.instance.aquire();
      caller = CustomerPool.instance.aquire();
      callee = CustomerPool.instance.aquire();
      client = new transport.Client();
      contactStore = new service.RESTContactStore(
          Config.contactStoreUri, receptionist.authToken, client);
      receptionStore = new service.RESTReceptionStore(
          Config.receptionStoreUri, receptionist.authToken, client);
      rdpStore = new service.RESTDialplanStore(
          Config.dialplanStoreUri, receptionist.authToken, client);

      final DateTime now = new DateTime.now();
      model.OpeningHour justNow = new model.OpeningHour.empty()
        ..fromDay = toWeekDay(now.weekday)
        ..toDay = toWeekDay(now.weekday)
        ..fromHour = now.hour - 1
        ..toHour = now.hour + 1
        ..fromMinute = now.minute
        ..toMinute = now.minute;

      model.ReceptionDialplan rdp = new model.ReceptionDialplan()
        ..open = [
          new model.HourAction()
            ..hours = [justNow]
            ..actions = [
              new model.Notify('call-offer'),
              new model.Ringtone(1),
              new model.Playback('no-greeting'),
              new model.Enqueue('waitqueue')
            ]
        ]
        ..extension = 'test-${Randomizer.randomPhoneNumber()}'
            '-${new DateTime.now().millisecondsSinceEpoch}'
        ..defaultActions = [new model.Playback('sorry-dude-were-closed')]
        ..active = true;

      model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp);
      model.ReceptionReference r = await receptionStore.create(
          Randomizer.randomReception()
            ..enabled = true
            ..dialplan = createdDialplan.extension,
          receptionist.user);
      await rdpStore.deployDialplan(rdp.extension, r.id);
      await rdpStore.reloadConfig();

      context = new model.OriginationContext()
        ..receptionId = r.id
        ..contactId = (await contactStore.create(
                Randomizer.randomBaseContact(), receptionist.user))
            .id
        ..dialplan = createdDialplan.extension;

      await Future.wait([
        receptionist.initialize(),
        caller.initialize(),
        callee.initialize()
      ]);
    });

    tearDown(() async {
      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(caller);
      CustomerPool.instance.release(callee);

      await receptionStore.remove(context.receptionId, receptionist.user);
      await Future.wait([
        rdpStore.remove(context.dialplan),
        contactStore.remove(context.contactId, receptionist.user),
        receptionist.teardown(),
        caller.teardown(),
        callee.teardown()
      ]);

      client.client.close(force: true);
    });

    test(
        'inboundCall Call list length checks',
        () => Transfer.inboundCallListLength(
            receptionist, caller, callee, context));

    test(
        'Inbound Call',
        () => Transfer.transferParkedInboundCall(
            receptionist, caller, callee, context));

    test(
        'Outbound Call',
        () => Transfer.transferParkedOutboundCall(
            receptionist, caller, callee, context));
  });
}

/**
 * CallFlowControl Peer tests.
 */
void _callFlowControlPeer() {
  group('CallFlowControl.Peer', () {
    Receptionist receptionist = null;

    /* Setup function for interfaceCallNotFound test. */
    setUp(() {
      receptionist = ReceptionistPool.instance.aquire();
      return Future.wait([receptionist.initialize()]);
    });

    /* Teardown function for interfaceCallNotFound test. */
    tearDown(() {
      ReceptionistPool.instance.release(receptionist);

      return Future.wait([receptionist.teardown()]);
    });

    test('Event presence', () => Peer.eventPresence(receptionist));
    test('Peer listing', () => Peer.list(receptionist.callFlowControl));
  });
}

/**
 * CallFlowControl Call pickup.
 */
void _callFlowControlPickup() {
  group('CallFlowControl.Pickup', () {
    Receptionist receptionist = null;
    Receptionist receptionist2 = null;
    Customer customer = null;

    setUp(() {
      receptionist = ReceptionistPool.instance.aquire();
      customer = CustomerPool.instance.aquire();
      return Future.wait([receptionist.initialize(), customer.initialize()]);
    });

    tearDown(() {
      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(customer);

      return Future.wait([receptionist.teardown(), customer.teardown()]);
    });

    /* Perform test. */
    test('pickupSpecified',
        () => Pickup.pickupSpecified(receptionist, customer));

    test('pickupUnspecified',
        () => Pickup.pickupUnspecified(receptionist, customer));

    test('pickupNonExistingCall',
        () => Pickup.pickupNonExistingCall(receptionist));

    test('pickupLockedCall',
        () => Pickup.pickupLockedCall(receptionist, customer));

    test('pickupCallTwice',
        () => Pickup.pickupCallTwice(receptionist, customer));

    test('pickupEventInboundCall',
        () => Pickup.pickupEventInboundCall(receptionist, customer));

    test('pickupEventOutboundCall',
        () => Pickup.pickupEventOutboundCall(receptionist, customer));

    setUp(() {
      receptionist = ReceptionistPool.instance.aquire();
      receptionist2 = ReceptionistPool.instance.aquire();
      customer = CustomerPool.instance.aquire();
      return Future.wait([
        receptionist.initialize(),
        receptionist2.initialize(),
        customer.initialize()
      ]);
    });

    tearDown(() {
      ReceptionistPool.instance.release(receptionist);
      ReceptionistPool.instance.release(receptionist2);
      CustomerPool.instance.release(customer);

      return Future.wait([
        receptionist.teardown(),
        receptionist2.teardown(),
        customer.teardown()
      ]);
    });

    test(
        'pickupAllocatedCall',
        () =>
            Pickup.pickupAllocatedCall(receptionist, receptionist2, customer));

    test('pickupRace',
        () => Pickup.pickupRace(receptionist, receptionist2, customer));
  });
}

/**
 * CallFlowControl Call originate.
 */
void _callFlowControlOriginate() {
  group('CallFlowControl.Originate', () {
    Receptionist receptionist = null;
    Customer customer = null;

    setUp(() {
      receptionist = ReceptionistPool.instance.aquire();
      customer = CustomerPool.instance.aquire();
      return Future.wait([receptionist.initialize(), customer.initialize()]);
    });

    tearDown(() {
      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(customer);

      return Future.wait([receptionist.teardown(), customer.teardown()]);
    });

    // TODO: This one requires a dialplan change.
//    test ('originationToHostedNumber',
//        () => Originate.originationToHostedNumber(receptionist));

    test('originationOnAgentCallRejected',
        () => Originate.originationOnAgentCallRejected(receptionist, customer));

    test(
        'originationOnAgentAutoAnswer',
        () => Originate.originationOnAgentAutoAnswerDisabled(
            receptionist, customer));

    test('originationToForbiddenNumber',
        () => Originate.originationToForbiddenNumber(receptionist));

    test('originationToPeer',
        () => Originate.originationToPeer(receptionist, customer));

    test('originationWithCallContext',
        () => Originate.originationWithCallContext(receptionist, customer));

    test(
        'originationToPeerCheckforduplicate',
        () => Originate.originationToPeerCheckforduplicate(
            receptionist, customer));
  });
}

/**
 * CallFlowControl Call Park.
 */
void _callFlowControlPark() {
  group('CallFlowControl.Park', () {
    Receptionist receptionist = null;
    Customer customer = null;

    setUp(() {
      receptionist = ReceptionistPool.instance.aquire();
      customer = CustomerPool.instance.aquire();
      return Future.wait([receptionist.initialize(), customer.initialize()]);
    });

    tearDown(() {
      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(customer);

      return Future.wait([receptionist.teardown(), customer.teardown()]);
    });

    test('parkCallListLength',
        () => CallPark.parkCallListLength(receptionist, customer));

    test('explicitParkPickup',
        () => CallPark.explicitParkPickup(receptionist, customer));

    test('unparkEventFromHangup',
        () => CallPark.unparkEventFromHangup(receptionist, customer));

    test('parkNonexistingCall',
        () => CallPark.parkNonexistingCall(receptionist));
  });
}

/**
 * CallFlowControl user state.
 */
void _callFlowControlUserState() {
  group('CallFlowControl.UserState', () {
    Receptionist receptionist = null;
    Customer customer = null;
    Customer customer2 = null;

    setUp(() {
      receptionist = ReceptionistPool.instance.aquire();
      customer = CustomerPool.instance.aquire();
      customer2 = CustomerPool.instance.aquire();
      return Future.wait([
        receptionist.initialize(),
        customer.initialize(),
        customer2.initialize()
      ]);
    });

    tearDown(() {
      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(customer);

      return Future.wait(
          [receptionist.teardown(), customer.teardown(), customer2.teardown()]);
    });

    test('originateForbidden',
        () => UserState.originateForbidden(receptionist, customer, customer2));

    test('pickupForbidden',
        () => UserState.pickupForbidden(receptionist, customer, customer2));
  });
}

/**
 * CallFlowControl state reload.
 */
void _callFlowControlStateReload() {
  group('CallFlowControl.StateReload', () {
    Receptionist receptionist = null;
    Customer customer = null;
    Customer customer2 = null;

    setUp(() {
      receptionist = ReceptionistPool.instance.aquire();
      customer = CustomerPool.instance.aquire();

      return Future.wait([receptionist.initialize(), customer.initialize()]);
    });

    tearDown(() {
      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(customer);

      return Future.wait([receptionist.teardown(), customer.teardown()]);
    });

    test('inboundCallUnanswered',
        () => StateReload.inboundUnansweredCall(receptionist, customer));

    test('inboundAnsweredCall',
        () => StateReload.inboundAnsweredCall(receptionist, customer));

    test('inboundParkedCall',
        () => StateReload.inboundParkedCall(receptionist, customer));

    test('inboundUnparkedCall',
        () => StateReload.inboundUnparkedCall(receptionist, customer));

    test('outboundUnansweredCall',
        () => StateReload.outboundUnansweredCall(receptionist, customer));

    test('outboundAnsweredCall',
        () => StateReload.outboundAnsweredCall(receptionist, customer));

    setUp(() {
      receptionist = ReceptionistPool.instance.aquire();
      customer = CustomerPool.instance.aquire();
      customer2 = CustomerPool.instance.aquire();
      return Future.wait([
        receptionist.initialize(),
        customer.initialize(),
        customer2.initialize()
      ]);
    });

    tearDown(() {
      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(customer);

      return Future.wait(
          [receptionist.teardown(), customer.teardown(), customer2.teardown()]);
    });

    test('transferredCalls',
        () => StateReload.transferredCalls(receptionist, customer, customer2));
  });
}
