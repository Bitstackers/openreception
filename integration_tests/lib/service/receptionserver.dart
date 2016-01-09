part of or_test_fw;

/**
 * 
 */
runReceptionTests() {
  group('service.Reception', () {
    Transport.Client transport = null;
    Service.RESTReceptionStore receptionStore = null;
    Receptionist r;

    setUp(() {
      transport = new Transport.Client();
    });

    tearDown(() {
      transport.client.close(force: true);
    });

    test('CORS headers present',
        () => Reception.isCORSHeadersPresent(transport.client));

    test(
        'Non-existing path', () => Reception.nonExistingPath(transport.client));

    setUp(() {
      transport = new Transport.Client();
      receptionStore = new Service.RESTReceptionStore(
          Config.receptionStoreUri, Config.serverToken, transport);
    });

    tearDown(() {
      receptionStore = null;
      transport.client.close(force: true);
    });

    test('Non-existing reception',
        () => Reception.nonExistingReception(receptionStore));

    test('Existing reception',
        () => Reception.existingReception(receptionStore));

    test('List receptions', () => Reception.listReceptions(receptionStore));

    test('Reception creation', () => Reception.create(receptionStore));

    test('Non-existing Reception update',
        () => Reception.updateNonExisting(receptionStore));

    test('Reception invalid update',
        () => Reception.updateInvalid(receptionStore));

    test('Reception update', () => Reception.update(receptionStore));

    test('Reception removal', () => Reception.remove(receptionStore));

    test('Lookup by extension', () => Reception.byExtension(receptionStore));

    test('Lookup extension', () => Reception.extensionOf(receptionStore));

    setUp(() {
      transport = new Transport.Client();
      receptionStore = new Service.RESTReceptionStore(
          Config.receptionStoreUri, Config.serverToken, transport);
      r = ReceptionistPool.instance.aquire();

      return r.initialize();
    });

    tearDown(() {
      receptionStore = null;
      transport.client.close(force: true);

      ReceptionistPool.instance.release(r);

      return r.teardown();
    });

    test('Reception creation (event presence)',
        () => Reception.createEvent(receptionStore, r));

    test('Reception update (event presence)',
        () => Reception.updateEvent(receptionStore, r));

    test('Reception removal (event presence)',
        () => Reception.deleteEvent(receptionStore, r));
  });
}
