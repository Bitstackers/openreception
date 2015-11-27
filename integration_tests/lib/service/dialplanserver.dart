part of or_test_fw;


runDialplanTests() {
  group('Service.Dialplan', () {
    Transport.Client transport = null;
    Service.RESTDialplanStore rdpStore = null;

    test(
        'CORS headers present (existingUri)',
        () => isCORSHeadersPresent(
            Resource.ReceptionDialplan.list(Config.dialplanStoreUri)));

    test(
        'CORS headers present (non-existingUri)',
        () =>
            isCORSHeadersPresent(Uri.parse('${Config.dialplanStoreUri}/nonexistingpath')));

    test('Non-existing path', () => nonExistingPath(Service.appendToken(Uri.parse('${Config.dialplanStoreUri}/nonexistingpath'), Config.serverToken)));

    setUp(() {
      transport = new Transport.Client();
      rdpStore = new Service.RESTDialplanStore(
          Config.dialplanStoreUri, Config.serverToken, transport);
    });

    tearDown(() {
      rdpStore = null;
      transport.client.close(force: true);
    });

    test('create', () => ReceptionDialplanStore.create(rdpStore));

    test('get', () => ReceptionDialplanStore.get(rdpStore));

    test('list', () => ReceptionDialplanStore.list(rdpStore));

    test('remove', () => ReceptionDialplanStore.remove(rdpStore));

    test('update', () => ReceptionDialplanStore.update(rdpStore));
  });

}
