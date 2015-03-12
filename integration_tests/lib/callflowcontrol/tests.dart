part of or_test_fw;


void runCallFlowTests() {

  Uri notificationSocketURI = Uri.parse('${Config.NotificationSocketUri}'
                                        '?token=${Config.serverToken}');

  group('CallFlowControl.Hangup', () {
    /// Variables used in tests.
    Service.CallFlowControl callFlowServer = null;
        new Service.CallFlowControl
        (Config.CallFlowControlUri, Config.serverToken,
            new Transport.Client());

    Transport.WebSocketClient websocket = null;
    Service.NotificationSocket notificationSocket = null;
    SupportTools supportTools = null;

    /* Setup function for interfaceCallNotFound test. */
    setUp (() {
      callFlowServer = new Service.CallFlowControl
              (Config.CallFlowControlUri, Config.serverToken,
                  new Transport.Client());

      websocket = new Transport.WebSocketClient();
      notificationSocket = new Service.NotificationSocket (websocket);

      return websocket.connect(notificationSocketURI);
    });

    /* Teardown function for interfaceCallNotFound test. */
    tearDown (() {
      callFlowServer = null;

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

    /* Before the last test, we define the global tearDown function. */
    tearDown (() {
      supportTools.tearDown();
    });

    /* Last test. */
    test ('interfaceCallFound',
        () => Hangup.interfaceCallFound().then((_) => expect('', isNotNull)));
  });
}


abstract class CallFlowControl {

  final String authToken = Config.serverToken;
  final Uri serverUrl = Config.managementServerURI;

  static final callFlowServer = new Service.CallFlowControl
      (Config.CallFlowControlUri, Config.serverToken, new Transport.Client());


}

abstract class Hangup {

  static Logger log = new Logger('Test.Hangup');

  /**
   * Test for the presence of hangup events when a call is hung up.
   */
  static Future eventPresence() {
    Receptionist receptionist = ReceptionistPool.instance.aquire();
    Customer     customer     = CustomerPool.instance.aquire();

    String       reception = "12340003";

    log.finest ("Customer " + customer.name + " dials " + reception);

    return
      Future.wait([receptionist.initialize(),
                   customer.initialize()])
      .then((_) => customer.dial (reception))
      .then((_) => receptionist.waitForCall())
      .then((_) => customer.hangupAll())
      .then((_) => receptionist.waitFor(eventType:"call_hangup"))
      .whenComplete(() {
        ReceptionistPool.instance.release(receptionist);
        CustomerPool.instance.release(customer);
        return Future.wait([receptionist.teardown(),customer.teardown()]);
      });
  }

  /**
   * Tests the hangup interface using a valid call id.
   */
  static Future interfaceCallFound() {
    Receptionist receptionist = ReceptionistPool.instance.aquire();
    Customer     customer     = CustomerPool.instance.aquire();
    Model.Call   inboundCall  = null;

    String       reception = "12340003";

    log.info ('Customer $customer dials $reception');

    return Future.wait([receptionist.initialize(),
                            customer.initialize()])
        .then((_) => customer.dial (reception))
        .then((_) => receptionist.waitForCall()
          .then((Model.Call call) => inboundCall = call))
        .then((_) => receptionist.pickup(inboundCall))
        .then((_) => receptionist.waitForInboundCall())
        .then((_) => receptionist.hangUp(inboundCall))
        .then((_) => receptionist.waitFor(eventType: 'call_hangup'))
        .whenComplete(() {
          ReceptionistPool.instance.release(receptionist);
          CustomerPool.instance.release(customer);
          return Future.wait([receptionist.teardown(),customer.teardown()]);
        });
  }

  /**
   * Tests the hangup interface using an invalid call id.
   */
  static Future interfaceCallNotFound(Service.CallFlowControl callflow) {
    return callflow.hangup(Model.Call.nullCallID);
  }
}
