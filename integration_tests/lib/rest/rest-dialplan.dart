part of openreception_tests.rest;

runDialplanTests() {
  Logger log = new Logger('$_namespace.dialplan');

  group('Service.Dialplan', () {
    transport.Client client = null;
    service.RESTDialplanStore rdpStore = null;
    service.RESTReceptionStore receptionStore = null;

    test(
        'CORS headers present (existingUri)',
        () => isCORSHeadersPresent(
            resource.ReceptionDialplan.list(Config.dialplanStoreUri), log));

    test(
        'CORS headers present (non-existingUri)',
        () => isCORSHeadersPresent(
            Uri.parse('${Config.dialplanStoreUri}/nonexistingpath'), log));

    test(
        'Non-existing path',
        () => nonExistingPath(
            Uri.parse('${Config.dialplanStoreUri}/nonexistingpath'
                '?token=${Config.serverToken}'),
            log));

    setUp(() {
      client = new transport.Client();
      rdpStore = new service.RESTDialplanStore(
          Config.dialplanStoreUri, Config.serverToken, client);
    });

    tearDown(() {
      rdpStore = null;
      client.client.close(force: true);
    });

    test('create', () => serviceTest.ReceptionDialplanStore.create(rdpStore));

    test('get', () => serviceTest.ReceptionDialplanStore.get(rdpStore));

    test('list', () => serviceTest.ReceptionDialplanStore.list(rdpStore));

    test('remove', () => serviceTest.ReceptionDialplanStore.remove(rdpStore));

    test('update', () => serviceTest.ReceptionDialplanStore.update(rdpStore));

    setUp(() {
      client = new transport.Client();
      rdpStore = new service.RESTDialplanStore(
          Config.dialplanStoreUri, Config.serverToken, client);
      receptionStore = new service.RESTReceptionStore(
          Config.receptionStoreUri, Config.serverToken, client);
    });

    tearDown(() {
      rdpStore = null;
      receptionStore = null;
      client.client.close(force: true);
    });

    test(
        'deploy',
        () => serviceTest.ReceptionDialplanStore
            .deploy(rdpStore, receptionStore));
  });
}
