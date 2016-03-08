part of openreception_tests.rest;

runIvrTests() {
  group('Service.Ivr', () {
    Logger log = new Logger('$_namespace.ivr');

    transport.Client client = null;
    service.RESTIvrStore ivrStore = null;

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
      ivrStore = new service.RESTIvrStore(
          Config.dialplanStoreUri, Config.serverToken, client);
    });

    tearDown(() {
      ivrStore = null;
      client.client.close(force: true);
    });

    test('create', () => storeTest.Ivr.create(ivrStore));

    test('get', () => storeTest.Ivr.get(ivrStore));

    test('list', () => storeTest.Ivr.list(ivrStore));

    test('remove', () => storeTest.Ivr.remove(ivrStore));

    test('update', () => storeTest.Ivr.update(ivrStore));
  });
}
