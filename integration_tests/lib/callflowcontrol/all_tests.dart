part of or_test_fw;


void runCallFlowTests() {

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

    test ('originationToForbiddenNumber',
        () => Originate.originationToForbiddenNumber(receptionist));

    //TODO: Figure out why this fails on the ci-server and not locally
    test ('originationToPeer',
        () => Originate.originationToPeer(receptionist, customer.extension));
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
}