part of or_test_fw;


void runCallFlowTests() {

  /**
   * CallFlowControl active recordings tests.
   */
  group('CallFlowControl.ActiveRecording', () {
    Service.CallFlowControl callFlow;
    Transport.Client transport;

    setUp (() {
      transport = new Transport.Client();

      callFlow = new Service.CallFlowControl
          (Config.CallFlowControlUri, Config.serverToken, transport);

    });

    tearDown (() {
      transport.client.close(force : true);
    });

    test ('empty list',
        () => ActiveRecording.listEmpty(callFlow));

    test ('non-existing recording',
        () => ActiveRecording.getNonExisting(callFlow));

  });

  /**
   * CallFlowControl Call hangup - using Receptionist objects.
   */
  group('CallFlowControl.Hangup', () {
    Receptionist receptionist = null;
    Customer customer = null;

    setUp (() {

      receptionist = ReceptionistPool.instance.aquire();
      customer = CustomerPool.instance.aquire();
      return Future.wait(
        [receptionist.initialize(),
         customer.initialize()]);
    });

    tearDown (() {
      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(customer);

      return Future.wait(
        [receptionist.teardown(),
         customer.teardown()]);
    });

    test ('interfaceCallNotFound',
       () => expect(Hangup.interfaceCallNotFound(receptionist.callFlowControl),
           throwsA(new isInstanceOf<Storage.NotFound>())));
    /* Perform test. */
    test ('eventPresence',
        () => Hangup.eventPresence(receptionist, customer));

    test ('interfaceCallFound',
        () => Hangup.interfaceCallFound(receptionist, customer));
  });


  /**
   * CallFlowControl Call listing.
   */
  group('CallFlowControl.List', () {
    Receptionist receptionist;
    Customer customer;

    setUp (() {
      receptionist = ReceptionistPool.instance.aquire();
      customer = CustomerPool.instance.aquire();
      return Future.wait(
        [receptionist.initialize(),
         customer.initialize()]);
    });

    tearDown (() {
      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(customer);

      return Future.wait(
        [receptionist.teardown(),
         customer.teardown()]);
    });

    test ('callDataOK',
        () => CallList.callDataOK(receptionist, customer));

    test ('interfaceCallFound',
        () => CallList.callPresence(receptionist, customer));

    test ('queueLeaveEventFromPickup',
        () => CallList.queueLeaveEventFromPickup (receptionist, customer));

    test ('queueLeaveEventFromHangup',
        () => CallList.queueLeaveEventFromHangup(receptionist, customer));
  });


  /**
   * CallFlowControl Call transfer.
   */
  group('CallFlowControl.Transfer', () {
    Receptionist receptionist = null;
    Customer caller = null;
    Customer callee = null;

    setUp (() {
      receptionist = ReceptionistPool.instance.aquire();
      caller = CustomerPool.instance.aquire();
      callee = CustomerPool.instance.aquire();
      return Future.wait(
        [receptionist.initialize(),
         caller.initialize(),
         callee.initialize()]);
    });

    tearDown (() {

      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(caller);
      CustomerPool.instance.release(callee);

      return Future.wait(
        [receptionist.teardown(),
         caller.teardown(),
         callee.teardown()]);
    });

    test ('inboundCall Call list length checks',
        () => Transfer.inboundCallListLength(receptionist, caller, callee));

    test ('Inbound Call',
        () => Transfer.transferParkedInboundCall(receptionist, caller, callee));

    test ('Outbound Call',
        () => Transfer.transferParkedOutboundCall(receptionist, caller, callee));
  });

  /**
   * CallFlowControl Peer tests.
   */
  group('CallFlowControl.Peer', () {
    Receptionist receptionist = null;

    /* Setup function for interfaceCallNotFound test. */
    setUp (() {
      receptionist = ReceptionistPool.instance.aquire();
      return Future.wait(
        [receptionist.initialize()]);
      });

    /* Teardown function for interfaceCallNotFound test. */
    tearDown (() {
      ReceptionistPool.instance.release(receptionist);

      return Future.wait(
        [receptionist.teardown()]);
    });

    test ('Event presence', () => Peer.eventPresence (receptionist));
    test ('Peer listing', () => Peer.list(receptionist.callFlowControl));
  });

  /**
   * CallFlowControl Call pickup.
   */
  group('CallFlowControl.Pickup', () {
    Receptionist receptionist = null;
    Receptionist receptionist2 = null;
    Customer customer = null;

    setUp (() {
      receptionist = ReceptionistPool.instance.aquire();
      customer = CustomerPool.instance.aquire();
      return Future.wait(
        [receptionist.initialize(),
         customer.initialize()]);
    });

    tearDown (() {
      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(customer);

      return Future.wait(
        [receptionist.teardown(),
         customer.teardown()]);
    });


    /* Perform test. */
    test ('pickupSpecified',
        () => Pickup.pickupSpecified(receptionist, customer));

    test ('pickupUnspecified',
        () => Pickup.pickupUnspecified(receptionist, customer));

    test ('pickupNonExistingCall',
        () => Pickup.pickupNonExistingCall(receptionist));

    test ('pickupLockedCall',
        () => Pickup.pickupLockedCall(receptionist, customer));

    test ('pickupCallTwice',
        () => Pickup.pickupCallTwice(receptionist, customer));

    test ('pickupEventInboundCall',
        () => Pickup.pickupEventInboundCall(receptionist, customer));

    test ('pickupEventOutboundCall',
        () => Pickup.pickupEventOutboundCall(receptionist, customer));

    setUp (() {
      receptionist = ReceptionistPool.instance.aquire();
      receptionist2 = ReceptionistPool.instance.aquire();
      customer = CustomerPool.instance.aquire();
      return Future.wait(
        [receptionist.initialize(),
          receptionist2.initialize(),
         customer.initialize()]);
    });

    tearDown (() {
      ReceptionistPool.instance.release(receptionist);
      ReceptionistPool.instance.release(receptionist2);
      CustomerPool.instance.release(customer);

      return Future.wait(
        [receptionist.teardown(),
         receptionist2.teardown(),
         customer.teardown()]);
    });

    test ('pickupAllocatedCall',
        () => Pickup.pickupAllocatedCall(receptionist, receptionist2, customer));

    test ('pickupRace',
        () => Pickup.pickupRace(receptionist, receptionist2, customer));

  });

  /**
   * CallFlowControl Call originate.
   */
  group('CallFlowControl.Originate', () {
    Receptionist receptionist = null;
    Customer customer = null;

    setUp (() {

      receptionist = ReceptionistPool.instance.aquire();
      customer = CustomerPool.instance.aquire();
      return Future.wait(
        [receptionist.initialize(),
         customer.initialize()]);
    });

    tearDown (() {
      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(customer);

      return Future.wait(
        [receptionist.teardown(),
         customer.teardown()]);
    });


    // TODO: This one requires a dialplan change.
//    test ('originationToHostedNumber',
//        () => Originate.originationToHostedNumber(receptionist));

    test ('originationOnAgentCallRejected',
        () => Originate.originationOnAgentCallRejected(receptionist, customer));

    test ('originationOnAgentAutoAnswer',
        () => Originate.originationOnAgentAutoAnswerDisabled(receptionist, customer));

    test ('originationToForbiddenNumber',
        () => Originate.originationToForbiddenNumber(receptionist));

    test ('originationToPeer',
        () => Originate.originationToPeer(receptionist, customer));

    test ('originationToPeerCheckforduplicate',
        () => Originate.originationToPeerCheckforduplicate(receptionist, customer));

  });

  /**
   * CallFlowControl Call Park.
   */
  group('CallFlowControl.Park', () {
    Receptionist receptionist = null;
    Customer customer = null;

    setUp (() {
      receptionist = ReceptionistPool.instance.aquire();
      customer = CustomerPool.instance.aquire();
      return Future.wait(
        [receptionist.initialize(),
         customer.initialize()]);
    });

    tearDown (() {
      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(customer);

      return Future.wait(
        [receptionist.teardown(),
         customer.teardown()]);
    });

    test ('parkCallListLength',
        () => CallPark.parkCallListLength(receptionist, customer));

    test ('explicitParkPickup',
        () => CallPark.explicitParkPickup(receptionist, customer));

    test ('unparkEventFromHangup',
        () => CallPark.unparkEventFromHangup(receptionist, customer));

    test ('parkNonexistingCall',
        () => CallPark.parkNonexistingCall(receptionist));
  });

  /**
   * CallFlowControl user state.
   */
  group('CallFlowControl.UserState', () {
    Receptionist receptionist = null;
    Customer customer = null;
    Customer customer2 = null;

    setUp (() {
      receptionist = ReceptionistPool.instance.aquire();
      customer = CustomerPool.instance.aquire();
      customer2 = CustomerPool.instance.aquire();
      return Future.wait(
        [receptionist.initialize(),
         customer.initialize(),
         customer2.initialize()]);
    });

    tearDown (() {
      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(customer);

      return Future.wait(
        [receptionist.teardown(),
         customer.teardown(),
         customer2.teardown()]);
    });

    test ('originateForbidden',
        () => UserState.originateForbidden(receptionist, customer, customer2));

    test ('pickupForbidden',
        () => UserState.pickupForbidden(receptionist, customer, customer2));

  });

  /**
   * CallFlowControl state reload.
   */
  group('CallFlowControl.StateReload', () {
    Receptionist receptionist = null;
    Customer customer = null;
    Customer customer2 = null;

    setUp (() {
      receptionist = ReceptionistPool.instance.aquire();
      customer = CustomerPool.instance.aquire();

      return Future.wait(
        [receptionist.initialize(),
         customer.initialize()]);
    });

    tearDown (() {
      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(customer);

      return Future.wait(
        [receptionist.teardown(),
         customer.teardown()]);
    });

    test ('inboundCallUnanswered',
        () => StateReload.inboundUnansweredCall(receptionist, customer));

    test ('inboundAnsweredCall',
        () => StateReload.inboundAnsweredCall(receptionist, customer));

    test ('inboundParkedCall',
        () => StateReload.inboundParkedCall(receptionist, customer));

    test ('inboundUnparkedCall',
        () => StateReload.inboundUnparkedCall(receptionist, customer));

    test ('outboundUnansweredCall',
        () => StateReload.outboundUnansweredCall(receptionist, customer));

    test ('outboundAnsweredCall',
        () => StateReload.outboundAnsweredCall(receptionist, customer));

    setUp (() {
      receptionist = ReceptionistPool.instance.aquire();
      customer = CustomerPool.instance.aquire();
      customer2 = CustomerPool.instance.aquire();
      return Future.wait(
        [receptionist.initialize(),
         customer.initialize(),
         customer2.initialize()]);
    });

    tearDown (() {
      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(customer);

      return Future.wait(
        [receptionist.teardown(),
         customer.teardown(),
         customer2.teardown()]);
    });

    test ('transferredCalls',
        () => StateReload.transferredCalls(receptionist, customer, customer2));



  });
}