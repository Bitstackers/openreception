part of or_test_fw;


void runCallFlowTests() {

  Uri notificationSocketURI = Uri.parse('${Config.NotificationSocketUri}'
                                        '?token=${Config.serverToken}');
  SupportTools supportTools = null;

  group('CallFlowControl.Hangup', () {
    /// Variables used in tests.
    Service.CallFlowControl callFlowServer = null;
        new Service.CallFlowControl
        (Config.CallFlowControlUri, Config.serverToken,
            new Transport.Client());

    Transport.WebSocketClient websocket = null;
    Service.NotificationSocket notificationSocket = null;


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


    test ('interfaceCallFound',
        () => Hangup.interfaceCallFound().then((_) => expect('', isNotNull)));
  });


  group('CallFlowControl.List', () {
    test ('interfaceCallFound',
        () => CallList.callPresence().then((_) => expect('', isNotNull)));
  });

  group('CallFlowControl.Peer', () {
    test ('Event presence', Peer.eventPresence);
  });

}


abstract class CallFlowControl {

  final String authToken = Config.serverToken;
  final Uri serverUrl = Config.managementServerURI;

  static final callFlowServer = new Service.CallFlowControl
      (Config.CallFlowControlUri, Config.serverToken, new Transport.Client());
}
