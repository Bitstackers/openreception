part of or_test_fw;


void runMessageTests() {

  group ('Database.Message', () {
    Storage.Reception receptionStore;
    Storage.Contact contactStore;
    Transport.Client transport;
    Receptionist r;


    Database.Message messageDB;
    Database.Connection connection;

    setUp(() {

      return Database.Connection
          .connect(Config.dbDSN)
          .then((Database.Connection conn) {
        connection = conn;
        messageDB = new Database.Message(connection);
      });
    });

    tearDown (() {
      return connection.close();
    });

    test ('list',
        () => MessageStore.list(messageDB));

    test ('get',
        () => MessageStore.get(messageDB));

    setUp(() {

      return Database.Connection
          .connect(Config.dbDSN)
          .then((Database.Connection conn) {
        connection = conn;
        messageDB = new Database.Message(connection);

        transport = new Transport.Client();
        receptionStore = new Service.RESTReceptionStore(Config.receptionStoreUri,
              Config.serverToken, transport);
        contactStore = new Service.RESTContactStore(Config.contactStoreUri,
              Config.serverToken, transport);
        r = ReceptionistPool.instance.aquire();

        return r.initialize();
      });
    });


   tearDown (() {
     receptionStore = null;
     contactStore = null;
     transport.client.close(force : true);
     return connection.close().then((_) => r.teardown());

   });

    test ('create',
        () => MessageStore.create(messageDB, contactStore, receptionStore, r));

    test ('update',
        () => MessageStore.update(messageDB, contactStore, receptionStore, r));
  });

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
     () => MessageStore.list(messageStore));

   test('message (non-existing ID)',
     () => RESTMessageStore.nonExistingMessage(messageStore));

   test('get',
     () => MessageStore.get(messageStore));

   test('list',
     () => MessageStore.list (messageStore));

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

    test ('create',
        () => MessageStore.create(messageStore, contactStore, receptionStore, r));

    test ('update',
        () => MessageStore.update(messageStore, contactStore, receptionStore, r));

//   test('message enqueue (event presence)',
//     () => RESTMessageStore.messageEnqueueEvent
//             (messageStore, contactStore, receptionStore, r));

   test('message update (event presence)',
     () => RESTMessageStore.messageUpdateEvent  (messageStore, contactStore, receptionStore, r));

   test('message create (event presence)',
     () => RESTMessageStore.messageCreateEvent
             (messageStore, contactStore, receptionStore, r));
  });
}
