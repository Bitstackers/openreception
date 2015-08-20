part of or_test_fw;

abstract class RESTMessageStore {
  static const int invalidMessageID = -1;

  static final Logger log = new Logger ('$libraryName.RESTMessageStore');

  /**
   * Test for the presence of CORS headers.
   */
  static Future isCORSHeadersPresent(HttpClient client) {

    Uri uri = Uri.parse ('${Config.messageStoreUri}/nonexistingpath');

    log.info('Checking CORS headers on a non-existing URL.');
    return client.getUrl(uri)
      .then((HttpClientRequest request) => request.close()
      .then((HttpClientResponse response) {
        if (response.headers['access-control-allow-origin'] == null &&
            response.headers['Access-Control-Allow-Origin'] == null) {
          fail ('No CORS headers on path $uri');
        }
      }))
      .then ((_) {
        log.info('Checking CORS headers on an existing URL.');
        uri = Resource.Reception.single (Config.messageStoreUri, 1);
        return client.getUrl(uri)
          .then((HttpClientRequest request) => request.close()
          .then((HttpClientResponse response) {
          if (response.headers['access-control-allow-origin'] == null &&
              response.headers['Access-Control-Allow-Origin'] == null) {
            fail ('No CORS headers on path $uri');
          }
      }));
    });
  }

  /**
   * Test server behaviour when trying to access a resource not associated with
   * a handler.
   *
   * The expected behaviour is that the server should return a Not Found error.
   */
  static Future nonExistingPath (HttpClient client) {
    Uri uri = Uri.parse ('${Config.messageStoreUri}/nonexistingpath?token=${Config.serverToken}');

    log.info('Checking server behaviour on a non-existing path.');

    return client.getUrl(uri)
      .then((HttpClientRequest request) => request.close()
      .then((HttpClientResponse response) {
        if (response.statusCode != 404) {
          fail ('Expected to received a 404 on path $uri');
        }
      }))
      .then((_) => log.info('Got expected status code 404.'))
      .whenComplete(() => client.close(force : true));
  }

  /**
   * Test server behaviour when trying to aquire a message object that
   * does not exist.
   *
   * The expected behaviour is that the server should return a Not Found error.
   */
  static void nonExistingMessage (Storage.Message messageStore) {

    log.info('Checking server behaviour on a non-existing message.');

    return expect(messageStore.get(invalidMessageID),
            throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  static Future messageSend(Storage.Message messageStore,
                              Storage.Contact contactStore,
                              Storage.Reception receptionStore,
                              Receptionist sender) {

    int receptionID = 1;
    int contactID = 4;

    return contactStore.getByReception(contactID, receptionID)
      .then((Model.Contact contact) =>
        receptionStore.get(receptionID)
          .then((Model.Reception reception) {
            Model.Message newMessage = Randomizer.randomMessage()
              ..context = new Model.MessageContext.fromContact
                            (contact, reception)
              ..recipients = contact.distributionList
              ..senderId = sender.user.ID;

            return messageStore.save(newMessage)
              .then((Model.Message savedMessage) =>
                messageStore.enqueue(savedMessage));
    }));
  }

  static Future messageFilter(Storage.Message messageStore) {
    Model.MessageFilter filter = new Model.MessageFilter.empty();


    return messageStore.list(filter : filter)
      .then((Iterable<Model.Message> messages) {
        expect (messages.length, greaterThan(0));

      /// Update the filter
      filter.receptionID = messages.first.context.receptionID;
    })
    .then ((_) => messageStore.list(filter : filter)
        .then((Iterable<Model.Message> messages) {

      bool matchesFilter(Model.Message message) =>
          message.context.receptionID == filter.receptionID;

      expect (messages.every(matchesFilter), isTrue);

    }));
  }

  static Future messageCreateEvent(Storage.Message messageStore,
                                   Storage.Contact contactStore,
                                   Storage.Reception receptionStore,
                                   Receptionist sender) {

    log.info('Started messageCreateEvent test');

    int receptionID = 1;
    int contactID = 4;
    Model.Reception reception;
    Model.Contact contact;

    return MessageStore._createMessage(messageStore, contactStore, receptionStore, sender)
        .then((Model.Message message) =>
            sender.waitFor(eventType : Event.Key.messageChange)
        .then((Event.MessageChange changeEvent) {
          expect (changeEvent.messageID, isNotNull);
          expect (changeEvent.messageID, equals(message.ID));
    }))
    .whenComplete(() => log.info('Finished messageCreateEvent test'));
  }

  static Future messageEnqueueEvent(Storage.Message messageStore,
                                   Storage.Contact contactStore,
                                   Storage.Reception receptionStore,
                                   Receptionist sender) {
    int receptionID = 1;
    int contactID = 4;
    int messageID;
    Model.Reception reception;
    Model.Contact contact;

    log.info('Starting messageEnqueueEvent test');

    return contactStore.getByReception(contactID, receptionID)
        .then((Model.Contact c) =>
          contact = c)
      .then((_) => receptionStore.get(receptionID)
        .then((Model.Reception r) =>
            reception = r)
      .then((_) {
         Model.Message newMessage = Randomizer.randomMessage()
           ..context = new Model.MessageContext.fromContact
                       (contact, reception)
           ..recipients = contact.distributionList
           ..senderId = sender.user.ID;
         return messageStore.save(newMessage)
           .then((Model.Message savedMessage) =>
             sender.waitFor(eventType: Event.Key.messageChange)
             .then((Event.MessageChange event) {

                newMessage.ID = savedMessage.ID;
                messageID = savedMessage.ID;
                log.finest(savedMessage.asMap);
                log.finest(newMessage.asMap);
                sender.eventStack.clear();
         }))
           .then((_) => messageStore.save(newMessage)
               .then((Model.Message savedMessage) =>
                 messageStore.enqueue(savedMessage)
               .then((_) => sender.waitFor(eventType: Event.Key.messageChange)
                 .then((Event.MessageChange event) {
                    expect (event.messageID, equals(messageID));
           }))));
     }))
     .whenComplete(() => log.info('Finished messageEnqueueEvent test'));
  }
  static Future messageUpdateEvent(Storage.Message messageStore,
                                   Receptionist sender) {

    log.info('Started messageUpdateEvent test');

    return messageStore.list()
        .then((Iterable<Model.Message> messages) {
      Model.Message message = messages.last;

      message..body = Randomizer.randomMessageBody()
             ..callerInfo = Randomizer.randomCaller();

      return messageStore.save(message)
        .then((_) => sender.waitFor(eventType: Event.Key.messageChange)
          .then((Event.MessageChange event) {
            expect(event.messageID, equals(message.ID));
      }));
    })
    .whenComplete(() => log.info('Finished messageUpdateEvent test'));
  }
}
