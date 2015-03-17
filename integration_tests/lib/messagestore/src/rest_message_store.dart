part of or_test_fw;

abstract class RESTMessageStore {
  static const int invalidMessageID = -1;

  static final Logger log = new Logger ('$libraryName.MessageStore');

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

    Uri uri = Uri.parse ('${Config.messageStoreUri}/nonexistingpath');

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

  /**
   * Test server behaviour when trying to aquire a message object that
   * exists.
   *
   * The expected behaviour is that the server should return the
   * Reception object.
   */
  static Future existingMessage (Storage.Message messageStore) {
    int existingMessageID = 1;

    log.info('Checking server behaviour on an existing message.');

    return messageStore.get(existingMessageID)
      .then ((Model.Message message) {
        expect (message.ID, equals(existingMessageID));
    });
  }

  /**
   * Test server behaviour when trying to retrieve a non-filtered list of
   * message objects.
   *
   * The expected behaviour is that the server should return a list
   * of message objects.
   */
  static Future messageList (Storage.Message messageStore) {

    log.info('Listing messages non-filtered.');

    return messageStore.list()
      .then((List<Model.Message> messages) {
        expect(messages.length, greaterThan(0));
    });

  }

  /**
   * We inherit the timestamp from the fetched message in order to avoid
   * false negatives arising from datebase timestamps being different than our
   * test data. (Message timestamp is generated along with the database).
   */
  static Future messageMapEquality
    (Storage.Message store, int id, Model.Message expectedMessage) =>
        store.get(id).then((message) {
          expect(message.recipients.asMap,
            equals(expectedMessage.recipients.asMap));
          expect(message.toRecipients.asMap(),
            equals(expectedMessage.toRecipients.asMap()));
          expect(message.ccRecipients.asMap(),
             equals(expectedMessage.ccRecipients.asMap()));
          expect(message.bccRecipients.asMap(),
             equals(expectedMessage.bccRecipients.asMap()));
          expect(message.body,
             equals(expectedMessage.body));
          expect(message.createdAt.isBefore(new DateTime.now()), isTrue);
          expect(message.caller.asMap,
             equals(expectedMessage.caller.asMap));
          expect(message.context.asMap,
             equals(expectedMessage.context.asMap));

          expect(message.flags,
             equals(expectedMessage.flags));

          expect(message.ID, greaterThan(Model.Message.noID));

          expect(message.sender.toJson(),
             equals(expectedMessage.sender.toJson()));

          /// We don't really known if the messageDispatcher has processed
          /// the message yet.
          //expect(message.enqueued, isTrue);
          //expect(message.hasRecpients, isTrue);
          //expect(message.sent, isFalse);

          expect(message.urgent,
             equals(expectedMessage.urgent));
  });

  static Future messageCreate(Storage.Message messageStore,
                              Storage.Contact contactStore,
                              Storage.Reception receptionStore,
                              Model.User sender) {

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
              ..sender = sender;

            return messageStore.save(newMessage);
    }));
  }

  static Future messageSend(Storage.Message messageStore,
                              Storage.Contact contactStore,
                              Storage.Reception receptionStore,
                              Model.User sender) {

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
              ..sender = sender;

            return messageStore.enqueue(newMessage);
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


  static Future messageUpdate(Storage.Message messageStore) {

    return messageStore.list()
        .then((Iterable<Model.Message> messages) {
      Model.Message message = messages.last;

      message..body = Randomizer.randomMessageBody()
             ..caller = Randomizer.randomCaller()
             ..flags = Randomizer.randomMessageFlags();

      return messageStore.save(message)
        .then((Model.Message savedMessage) {
          expect (savedMessage.ID, message.ID);
          expect (savedMessage.body, message.body);
          expect (savedMessage.caller.asMap, message.caller.asMap);
          expect (savedMessage.flags, message.flags);
      });
    });
  }
}
