part of or_test_fw;


void runMessageTests() {
  group('RESTMessageStore', () {
    Transport.Client transport = null;
    Storage.Message messageStore = null;
    Storage.Reception receptionStore = null;
    Storage.Contact contactStore = null;
    Receptionist r;

    setUp (() {
      transport = new Transport.Client();
    });

    tearDown (() {
      transport.client.close(force : true);
    });

    test ('CORS headers present',
      () => RESTMessageStore.isCORSHeadersPresent(transport.client));

    test ('Non-existing path',
      () => RESTMessageStore.nonExistingPath(transport.client));

    setUp (() {
      transport = new Transport.Client();
      messageStore = new Service.RESTMessageStore(Config.messageStoreUri,
            Config.serverToken, transport);
    });

    tearDown (() {
      transport.client.close(force: true);
      messageStore = null;
    });

   test('message listing (non-filtered)',
     () => RESTMessageStore.messageList(messageStore));

   test('message (non-existing ID)',
     () => RESTMessageStore.nonExistingMessage(messageStore));

   test('message (existing ID)',
     () => RESTMessageStore.existingMessage(messageStore));

   test('message update',
     () => RESTMessageStore.messageUpdate (messageStore));

   tearDown (() {
     messageStore = null;
     receptionStore = null;
     contactStore = null;
     transport.client.close(force : true);

     ReceptionistPool.instance.release(r);
     return r.teardown();
   });

   setUp (() {
     transport = new Transport.Client();
     messageStore = new Service.RESTMessageStore(Config.messageStoreUri,
           Config.serverToken, transport);
     receptionStore = new Service.RESTReceptionStore(Config.receptionStoreUri,
           Config.serverToken, transport);
     contactStore = new Service.RESTContactStore(Config.contactStoreUri,
           Config.serverToken, transport);

     r = ReceptionistPool.instance.aquire();

     return r.initialize();
   });

   test('message create',
     () => RESTMessageStore.messageCreate
             (messageStore, contactStore, receptionStore, r));

   test('message send',
     () => RESTMessageStore.messageSend
             (messageStore, contactStore, receptionStore, r));

   test('message enqueue (event presence)',
     () => RESTMessageStore.messageEnqueueEvent
             (messageStore, contactStore, receptionStore, r));

   test('message update (event presence)',
     () => RESTMessageStore.messageUpdateEvent (messageStore, r));

   test('message create (event presence)',
     () => RESTMessageStore.messageCreateEvent
             (messageStore, contactStore, receptionStore, r));
  });
}
