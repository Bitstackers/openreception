part of openreception_tests.rest;

/**
 * TODO: Add tests for both broadcast, send and FIFO message ordering.
 */
void runNotificationTests() {
  group('$_namespace.Notification', () {
    Logger log = new Logger('$_namespace.Notification');

    ServiceAgent sa1;
    ServiceAgent sa2;
    ServiceAgent sa3;
    TestEnvironment env;
    process.ReceptionServer rProcess;
    process.AuthServer aProcess;
    process.NotificationServer nProcess;
    service.Client client;
    AuthToken authToken;

    setUp(() async {
      env = new TestEnvironment();
      sa1 = await env.createsServiceAgent();
      sa2 = await env.createsServiceAgent();
      sa3 = await env.createsServiceAgent();
      client = new service.Client();
      authToken = new AuthToken(sa1.user);
      sa1.authToken = authToken.tokenName;
      nProcess = new process.NotificationServer(
          Config.serverStackPath, env.runpath.path);

      aProcess = new process.AuthServer(
          Config.serverStackPath, env.runpath.path,
          intialTokens: [authToken]);

      rProcess =
          new process.ReceptionServer(Config.serverStackPath, env.runpath.path);

      sa1.receptionStore = rProcess.createClient(client, authToken.tokenName);

      await Future
          .wait([nProcess.whenReady, rProcess.whenReady, aProcess.whenReady]);
    });

    tearDown(() async {
      await Future.wait(
          [rProcess.terminate(), aProcess.terminate(), nProcess.terminate()]);
      env.clear();
      client.client.close();
    });

    test(
        'Event broadcast',
        () => serviceTest.NotificationService.eventBroadcast([
              sa1.notificationSocket,
              sa2.notificationSocket,
              sa2.notificationSocket
            ], null));

    test(
        'ConnectionState listing',
        () => serviceTest.NotificationService
            .connectionStateList([sa1, sa2, sa3]));

    // test('ConnectionState get',
    //     () => serviceTest.NotificationService.connectionState([sa1, sa2, sa3], sa1.no));

    //TODO: Implement these tests.
//    test('Event clientConnectionState', () =>
//      NotificationService.clientConnectionState
//        ([receptionist1, receptionist2, receptionist3]));

    //    test('Event send', () =>
//      NotificationService.eventSend
//        ([receptionist1, receptionist2, receptionist3],
//            notificationService));
  });
}
