part of or_test_fw;


void runCallFlowTests() {

  Uri notificationSocketURI = Uri.parse('${Config.NotificationSocketUri}'
                                        '?token=${Config.serverToken}');

  /**
   * CallFlowControl Call hangup (basic).
   */
  group('CallFlowControl.Hangup', () {
    Transport.Client transport = null;
    Service.CallFlowControl callFlowServer = null;
    Transport.WebSocketClient websocket = null;
    Service.NotificationSocket notificationSocket = null;
    Receptionist receptionist = null;
    Customer customer = null;

    /* Setup function for interfaceCallNotFound test. */
    setUp (() {
      transport = new Transport.Client();
      callFlowServer = new Service.CallFlowControl
              (Config.CallFlowControlUri, Config.serverToken, transport);

      websocket = new Transport.WebSocketClient();
      notificationSocket = new Service.NotificationSocket (websocket);

      return websocket.connect(notificationSocketURI);
    });

    /* Teardown function for interfaceCallNotFound test. */
    tearDown (() {
      callFlowServer = null;
      transport.client.close(force : false);

      return notificationSocket.close();
    });

    /* Actual test. */
    test ('interfaceCallNotFound',
       () => expect(Hangup.interfaceCallNotFound(callFlowServer),
           throwsA(new isInstanceOf<Storage.NotFound>())));
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
        () => CallList.callPresence().then((_) => expect('', isNotNull)));

    test ('queueLeaveEventFromPickup',
        () => CallList.queueLeaveEventFromPickup (receptionist, customer));

    test ('queueLeaveEventFromHangup',
        () => CallList.queueLeaveEventFromHangup(receptionist, customer));
  });


  /**
   * CallFlowControl Call transfer.
   */
  group('CallFlowControl.Transfer', () {
    test ('Inbound Call', Transfer.transferParkedInboundCall);
    test ('Outbound Call', Transfer.transferParkedOutboundCall);
  });

  /**
   * CallFlowControl Peer tests.
   */
  group('CallFlowControl.Peer', () {
    Transport.Client transport = null;
    Service.CallFlowControl callFlowServer = null;
    Transport.WebSocketClient websocket = null;
    Service.NotificationSocket notificationSocket = null;

    test ('Event presence', Peer.eventPresence);

    /* Setup function for interfaceCallNotFound test. */
    setUp (() {
      transport = new Transport.Client();
      callFlowServer = new Service.CallFlowControl
              (Config.CallFlowControlUri, Config.serverToken, transport);

      websocket = new Transport.WebSocketClient();
      notificationSocket = new Service.NotificationSocket (websocket);

      return websocket.connect(notificationSocketURI);
    });

    /* Teardown function for interfaceCallNotFound test. */
    tearDown (() {
      callFlowServer = null;
      transport.client.close(force : false);

      return notificationSocket.close();
    });
    test ('Peer listing', () => Peer.list(callFlowServer));
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

    test ('pickupNonExistingSpecificCall',
        () => Pickup.pickupNonExistingSpecificCall(receptionist));

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

    test ('originationToPeer',
        () => Originate.originationToPeer(receptionist, customer.extension));

  });
}