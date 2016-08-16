part of openreception_tests.rest;

/**
 * TODO: Add tests for both broadcast, send and FIFO message ordering.
 * Add CORS tests
 */
void _runNotificationTests() {
  group('$_namespace.Notification', () {
    List<ServiceAgent> sas = new List<ServiceAgent>();
    TestEnvironment env;
    process.NotificationServer nProcess;
    service.NotificationService nService;

    setUp(() async {
      env = new TestEnvironment();
      sas = [];
      await Future.forEach(new List.generate(10, (i) => i),
          (_) async => sas.add(await env.createsServiceAgent()));

      nProcess = await env.requestNotificationserverProcess();

      nService = nProcess.bindClient(env.httpClient, sas.first.authToken);

      await Future.wait(sas.map((sa) => sa.notificationSocket));
    });

    tearDown(() async {
      await env.clear();
    });

    test(
        'Event broadcast',
        () async => serviceTest.NotificationService.eventBroadcast(
            await Future.wait(sas.map((sa) => sa.notificationSocket)),
            nService));

    test('Event send',
        () => serviceTest.NotificationService.eventSend(sas, nService));

    test(
        'ConnectionState listing',
        () async =>
            serviceTest.NotificationService.connectionStateList(sas, nService));

    test('ConnectionState get',
        () => serviceTest.NotificationService.connectionState(sas, nService));
  });
}
