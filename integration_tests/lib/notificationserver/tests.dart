part of or_test_fw;

/**
 * TODO: Add tests for both broadcast, send and FIFO message ordering.
 */
void runNotificationTests() {


  group('NotificationService', () {
    Receptionist receptionist1;
    Receptionist receptionist2;
    Receptionist receptionist3;

    setUp (() {
      receptionist1 = ReceptionistPool.instance.aquire();
      receptionist2 = ReceptionistPool.instance.aquire();
      receptionist3 = ReceptionistPool.instance.aquire();

      return Future.wait([receptionist1.initialize(),
                          receptionist2.initialize(),
                          receptionist3.initialize()]);
    });

    tearDown (() {
      ReceptionistPool.instance.release(receptionist1);
      ReceptionistPool.instance.release(receptionist2);
      ReceptionistPool.instance.release(receptionist3);

      return Future.wait([receptionist1.teardown(),
                          receptionist2.teardown(),
                          receptionist3.teardown()]);
    });

    test('Event broadcast', () =>
      NotificationService.eventBroadcast
        ([receptionist1, receptionist2, receptionist3]));
  });
}
