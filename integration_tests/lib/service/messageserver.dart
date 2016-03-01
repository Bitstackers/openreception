part of or_test_fw;

void runMessageTests() {
  group('RESTMessageStore', () {
    Transport.Client transport = null;
    Storage.Message messageStore = null;
    Storage.Reception receptionStore = null;
    Storage.Contact contactStore = null;
    Storage.Endpoint epStore;

    Receptionist r;

    setUp(() {
      transport = new Transport.Client();
    });

    tearDown(() {
      transport.client.close(force: true);
    });

    test('CORS headers present',
        () => RESTMessageStore.isCORSHeadersPresent(transport.client));

    test('Non-existing path',
        () => RESTMessageStore.nonExistingPath(transport.client));

    setUp(() {
      transport = new Transport.Client();
      messageStore = new Service.RESTMessageStore(
          Config.messageStoreUri, Config.serverToken, transport);
    });

    tearDown(() {
      transport.client.close(force: true);
      messageStore = null;
    });

    test('message listing (non-filtered)',
        () => MessageStore.list(messageStore));

    test('message (non-existing ID)',
        () => RESTMessageStore.nonExistingMessage(messageStore));

    test('get', () => MessageStore.get(messageStore));

    test('list', () => MessageStore.list(messageStore));

    tearDown(() {
      messageStore = null;
      receptionStore = null;
      contactStore = null;
      transport.client.close(force: true);

      ReceptionistPool.instance.release(r);
      return r.teardown();
    });

    setUp(() {
      transport = new Transport.Client();
      r = ReceptionistPool.instance.aquire();

      messageStore = new Service.RESTMessageStore(
          Config.messageStoreUri, r.authToken, transport);
      receptionStore = new Service.RESTReceptionStore(
          Config.receptionStoreUri, r.authToken, transport);
      contactStore = new Service.RESTContactStore(
          Config.contactStoreUri, r.authToken, transport);

      dlStore = new Service.RESTDistributionListStore(
          Config.contactStoreUri, r.authToken, transport);
      epStore = new Service.RESTEndpointStore(
          Config.contactStoreUri, r.authToken, transport);

      return r.initialize();
    });

    test(
        'create',
        () => MessageStore.create(
            messageStore, contactStore, receptionStore, null, epStore, r));

    test(
        'update',
        () => MessageStore.update(
            messageStore, contactStore, receptionStore, null, epStore, r));

    test(
        'enqueue',
        () => MessageStore.enqueue(
            messageStore, contactStore, receptionStore, null, epStore, r));

    test(
        'remove',
        () => MessageStore.remove(
            messageStore, contactStore, receptionStore, null, epStore, r));

    test(
        'message enqueue (event presence)',
        () => RESTMessageStore.messageEnqueueEvent(
            messageStore, contactStore, receptionStore, null, epStore, r));

    test(
        'message update (event presence)',
        () => RESTMessageStore.messageUpdateEvent(
            messageStore, contactStore, receptionStore, null, epStore, r));

    test(
        'message create (event presence)',
        () => RESTMessageStore.messageCreateEvent(
            messageStore, contactStore, receptionStore, null, epStore, r));
  });
}
