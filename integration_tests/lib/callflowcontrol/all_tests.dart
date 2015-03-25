part of or_test_fw;


void runCallFlowTests() {

  Uri notificationSocketURI = Uri.parse('${Config.NotificationSocketUri}'
                                        '?token=${Config.serverToken}');

  /// Variables used in tests.
  SupportTools supportTools = null;
  Transport.Client transport = null;
  Service.CallFlowControl callFlowServer = null;
  Transport.WebSocketClient websocket = null;
  Service.NotificationSocket notificationSocket = null;
  Receptionist receptionist = null;
  Customer customer = null;

  group('CallFlowControl.Hangup', () {

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

    /* Setup instantiates the support tools.  */
    setUp (() {
      return SupportTools.instance
        .then((SupportTools st) => supportTools = st);
    });

    /* Clear the previous tearDown function. */
    tearDown (() {});

    /* Perform test. */
    test ('eventPresence',
        () => Hangup.eventPresence().then((_) => expect('', isNotNull)));

    /* Clear the previous setUp function. */
    setUp(() {});


    test ('interfaceCallFound',
        () => Hangup.interfaceCallFound().then((_) => expect('', isNotNull)));
  });


  group('CallFlowControl.List', () {

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

  group('CallFlowControl.Transfer', () {
    test ('Inbound Call', Transfer.transferParkedInboundCall);
    test ('Outbound Call', Transfer.transferParkedOutboundCall);
  });

  group('CallFlowControl.Peer', () {
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

}