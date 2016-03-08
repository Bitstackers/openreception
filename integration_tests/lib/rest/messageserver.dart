part of openreception_tests.service;

void runMessageTests() {
  group('RESTMessageStore', () {
    transport.Client client = null;
    storage.Message messageStore = null;
    storage.Reception receptionStore = null;
    storage.Contact contactStore = null;

    Receptionist r;

    setUp(() {
      client = new transport.Client();
    });

    tearDown(() {
      client.client.close(force: true);
    });

    test('CORS headers present',
        () => RESTMessageStore.isCORSHeadersPresent(client.client));

    test('Non-existing path',
        () => RESTMessageStore.nonExistingPath(client.client));

    setUp(() {
      client = new transport.Client();
      messageStore = new service.RESTMessageStore(
          Config.messageStoreUri, Config.serverToken, client);
    });

    tearDown(() {
      client.client.close(force: true);
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
      client.client.close(force: true);

      ReceptionistPool.instance.release(r);
      return r.teardown();
    });

    setUp(() {
      client = new transport.Client();
      r = ReceptionistPool.instance.aquire();

      messageStore = new service.RESTMessageStore(
          Config.messageStoreUri, r.authToken, client);
      receptionStore = new service.RESTReceptionStore(
          Config.receptionStoreUri, r.authToken, client);
      contactStore = new service.RESTContactStore(
          Config.contactStoreUri, r.authToken, client);

      return r.initialize();
    });

    test(
        'create',
        () => MessageStore.create(
            messageStore, contactStore, receptionStore, null, null, r));

    test(
        'update',
        () => MessageStore.update(
            messageStore, contactStore, receptionStore, null, null, r));

    test(
        'enqueue',
        () => MessageStore.enqueue(
            messageStore, contactStore, receptionStore, null, null, r));

    test(
        'remove',
        () => MessageStore.remove(
            messageStore, contactStore, receptionStore, null, null, r));

    test(
        'message enqueue (event presence)',
        () => RESTMessageStore.messageEnqueueEvent(
            messageStore, contactStore, receptionStore, null, null, r));

    test(
        'message update (event presence)',
        () => RESTMessageStore.messageUpdateEvent(
            messageStore, contactStore, receptionStore, null, null, r));

    test(
        'message create (event presence)',
        () => RESTMessageStore.messageCreateEvent(
            messageStore, contactStore, receptionStore, null, null, r));
  });
}
