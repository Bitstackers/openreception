part of or_test_fw;


void runMessageTests() {
  group('RESTMessageStore', () {
    Transport.Client transport = null;
    Storage.Message messageStore = null;
    Storage.Reception receptionStore = null;
    Storage.Contact contactStore = null;
    Service.Authentication authServer= null;

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
      messageStore = new Service.RESTMessageStore
        (Config.messageStoreUri, Config.serverToken, transport);

    });

    tearDown (() {
      messageStore = null;
      transport.client.close(force : true);
    });

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
     authServer= null;
     transport.client.close(force : true);
   });

   setUp (() {
     transport = new Transport.Client();
     messageStore = new Service.RESTMessageStore(Config.messageStoreUri,
           Config.serverToken, transport);
     receptionStore = new Service.RESTReceptionStore(Config.receptionStoreUri,
           Config.serverToken, transport);
     contactStore = new Service.RESTContactStore(Config.contactStoreUri,
           Config.serverToken, transport);
     authServer= new Service.Authentication(Config.authenticationServerUri,
         Config.serverToken, transport);
   });

   test('message enqueue',
     () => authServer.userOf(Config.serverToken)
       .then((Model.User sender) =>
         RESTMessageStore.messageCreate
             (messageStore, contactStore, receptionStore, sender)));

   test('message send',
     () => authServer.userOf(Config.serverToken)
       .then((Model.User sender) =>
         RESTMessageStore.messageSend
             (messageStore, contactStore, receptionStore, sender)));
  });
}
