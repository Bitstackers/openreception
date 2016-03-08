part of openreception_tests.service;

/**
 * TODO: Add tests for both broadcast, send and FIFO message ordering.
 */
void runNotificationTests() {
  group('NotificationService', () {
    Receptionist receptionist1;
    Receptionist receptionist2;
    Receptionist receptionist3;
    service.NotificationService notificationService;
    transport.Client client;

    setUp(() {
      receptionist1 = ReceptionistPool.instance.aquire();
      receptionist2 = ReceptionistPool.instance.aquire();
      receptionist3 = ReceptionistPool.instance.aquire();
      client = new transport.Client();
      notificationService = new service.NotificationService(
          Config.notificationServiceUri, Config.serverToken, client);

      return Future.wait([
        receptionist1.initialize(),
        receptionist2.initialize(),
        receptionist3.initialize()
      ]);
    });

    tearDown(() {
      ReceptionistPool.instance.release(receptionist1);
      ReceptionistPool.instance.release(receptionist2);
      ReceptionistPool.instance.release(receptionist3);
      client.client.close(force: true);
      notificationService = null;

      return Future.wait([
        receptionist1.teardown(),
        receptionist2.teardown(),
        receptionist3.teardown()
      ]);
    });

    test(
        'Event broadcast',
        () => NotificationService
            .eventBroadcast([receptionist1, receptionist2, receptionist3]));

    test(
        'ConnectionState listing',
        () => NotificationService.connectionStateList(
            [receptionist1, receptionist2, receptionist3],
            notificationService));

    test(
        'ConnectionState get',
        () => NotificationService.connectionState(
            [receptionist1, receptionist2, receptionist3],
            notificationService));

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
