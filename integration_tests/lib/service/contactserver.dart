part of or_test_fw;

runContactTests() {
  serviceDistributionListTests();
  serviceContactTests();
  serviceEndpoint();
}

void serviceEndpoint() {
  group('Service.RESTEndpointStore', () {
    Transport.Client transport = null;
    Service.RESTEndpointStore endpointStore;

    setUp(() {
      transport = new Transport.Client();
      endpointStore = new Service.RESTEndpointStore(
          Config.contactStoreUri, Config.serverToken, transport);
    });

    tearDown(() {
      endpointStore = null;
      transport.client.close(force: true);
    });

    test('list', () => ContactStore.endpoints(endpointStore));

    test('create', () => ContactStore.endpointCreate(endpointStore));

    test('remove', () => ContactStore.endpointRemove(endpointStore));

    test('update', () => ContactStore.endpointUpdate(endpointStore));
  });
}

void serviceContactTests() {
  group('RESTContactStore', () {
    Transport.Client transport = null;
    Service.RESTEndpointStore endpointStore;

    Service.RESTContactStore contactStore;
    Receptionist r;

    setUp(() {
      transport = new Transport.Client();
    });

    tearDown(() {
      transport.client.close(force: true);
    });

    test('CORS headers present',
        () => ContactStore.isCORSHeadersPresent(transport.client));

    test('Non-existing path',
        () => ContactStore.nonExistingPath(transport.client));

    setUp(() {
      transport = new Transport.Client();
      contactStore = new Service.RESTContactStore(
          Config.contactStoreUri, Config.serverToken, transport);

      endpointStore = new Service.RESTEndpointStore(
          Config.contactStoreUri, Config.serverToken, transport);
    });

    tearDown(() {
      contactStore = null;
      endpointStore = null;
      transport.client.close(force: true);
    });
    test('getByReception', () => ContactStore.getByReception(contactStore));

    test('organizationContacts',
        () => ContactStore.organizationContacts(contactStore));

    test('organizations', () => ContactStore.organizations(contactStore));

    test('organizations', () => ContactStore.organizations(contactStore));

    test('receptions', () => ContactStore.receptions(contactStore));

    test('list', () => ContactStore.list(contactStore));

    test('get', () => ContactStore.get(contactStore));

    test('BaseContact create', () => ContactStore.create(contactStore));

    test('BaseContact update', () => ContactStore.update(contactStore));

    test('BaseContact remove', () => ContactStore.remove(contactStore));

    test('Non-existing contact',
        () => ContactStore.nonExistingContact(contactStore));
    test('List contacts by reception',
        () => ContactStore.listByReception(contactStore));
    test('List contacts by Non-existing reception',
        () => ContactStore.listContactsByNonExistingReception(contactStore));

    setUp(() {
      transport = new Transport.Client();
      contactStore = new Service.RESTContactStore(
          Config.contactStoreUri, Config.serverToken, transport);

      endpointStore = new Service.RESTEndpointStore(
          Config.contactStoreUri, Config.serverToken, transport);
    });

    tearDown(() {
      contactStore = null;
      endpointStore = null;
      transport.client.close(force: true);
    });

    test('Calendar event creation',
        () => ContactStore.calendarEntryCreate(contactStore));
    test('Calendar event update',
        () => ContactStore.calendarEntryUpdate(contactStore));
    test('Calendar event',
        () => ContactStore.calendarEntryExisting(contactStore));
    test('Calendar event (non-existing)',
        () => ContactStore.calendarEntryNonExisting(contactStore));
    test('Calendar event removal',
        () => ContactStore.calendarEntryDelete(contactStore));

    test('Calendar event changes (create)',
        () => ContactStore.calendarEntryChangeCreate(contactStore));

    test('Calendar event changes (update)',
        () => ContactStore.calendarEntryChangeUpdate(contactStore));

    test('Calendar event changes (delete)',
        () => ContactStore.calendarEntryChangeDelete(contactStore));

    test('Endpoint listing', () => ContactStore.endpoints(endpointStore));

    test('Phone listing', () => ContactStore.phones(contactStore));

    test('addToReception', () => ContactStore.addToReception(contactStore));

    test('updateInReception',
        () => ContactStore.updateInReception(contactStore));

    test('deleteFromReception',
        () => ContactStore.deleteFromReception(contactStore));

    setUp(() {
      transport = new Transport.Client();
      contactStore = new Service.RESTContactStore(
          Config.contactStoreUri, Config.serverToken, transport);
      r = ReceptionistPool.instance.aquire();

      return r.initialize();
    });

    tearDown(() {
      contactStore = null;
      transport.client.close(force: true);

      ReceptionistPool.instance.release(r);
      return r.teardown();
    });

    test('CalendarEntry creation (event presence)',
        () => ContactStore.calendarEntryCreateEvent(contactStore, r));

    test('CalendarEntry update (event presence)',
        () => ContactStore.calendarEntryUpdateEvent(contactStore, r));

    test('CalendarEntry creation (event presence)',
        () => ContactStore.calendarEntryDeleteEvent(contactStore, r));
  });
}

void serviceDistributionListTests() {
  group('Service.RESTDistributionList', () {
    Transport.Client transport = null;
    Service.RESTDistributionListStore dlistStore;

    setUp(() {
      transport = new Transport.Client();
      dlistStore = new Service.RESTDistributionListStore(
          Config.contactStoreUri, Config.serverToken, transport);
    });

    tearDown(() {
      dlistStore = null;
      transport.client.close(force: true);
    });

    test('list', () => ContactStore.distributionList(dlistStore));

    test('create', () => ContactStore.distributionRecipientAdd(dlistStore));

    test('remove', () => ContactStore.distributionRecipientRemove(dlistStore));
  });
}
