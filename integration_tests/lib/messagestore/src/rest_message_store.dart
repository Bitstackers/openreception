part of or_test_fw;

abstract class RESTMessageStore {
  static const int invalidMessageID = -1;

  static final Logger log = new Logger('$libraryName.RESTMessageStore');

  /**
   * Test for the presence of CORS headers.
   */
  static Future isCORSHeadersPresent(HttpClient client) {
    Uri uri = Uri.parse('${Config.messageStoreUri}/nonexistingpath');

    log.info('Checking CORS headers on a non-existing URL.');
    return client
        .getUrl(uri)
        .then((HttpClientRequest request) => request
            .close()
            .then((HttpClientResponse response) {
      if (response.headers['access-control-allow-origin'] == null &&
          response.headers['Access-Control-Allow-Origin'] == null) {
        fail('No CORS headers on path $uri');
      }
    })).then((_) {
      log.info('Checking CORS headers on an existing URL.');
      uri = Resource.Reception.single(Config.messageStoreUri, 1);
      return client.getUrl(uri).then((HttpClientRequest request) => request
          .close()
          .then((HttpClientResponse response) {
        if (response.headers['access-control-allow-origin'] == null &&
            response.headers['Access-Control-Allow-Origin'] == null) {
          fail('No CORS headers on path $uri');
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
  static Future nonExistingPath(HttpClient client) {
    Uri uri = Uri.parse(
        '${Config.messageStoreUri}/nonexistingpath?token=${Config.serverToken}');

    log.info('Checking server behaviour on a non-existing path.');

    return client
        .getUrl(uri)
        .then((HttpClientRequest request) => request
            .close()
            .then((HttpClientResponse response) {
      if (response.statusCode != 404) {
        fail('Expected to received a 404 on path $uri');
      }
    }))
        .then((_) => log.info('Got expected status code 404.'))
        .whenComplete(() => client.close(force: true));
  }

  /**
   * Test server behaviour when trying to aquire a message object that
   * does not exist.
   *
   * The expected behaviour is that the server should return a Not Found error.
   */
  static void nonExistingMessage(Storage.Message messageStore) {
    log.info('Checking server behaviour on a non-existing message.');

    return expect(messageStore.get(invalidMessageID),
        throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  /**
   *
   */
  static Future messageFilter(Storage.Message messageStore) {
    Model.MessageFilter filter = new Model.MessageFilter.empty();

    return messageStore
        .list(filter: filter)
        .then((Iterable<Model.Message> messages) {
      expect(messages.length, greaterThan(0));

      /// Update the filter
      filter.receptionID = messages.first.context.receptionID;
    }).then((_) => messageStore
        .list(filter: filter)
        .then((Iterable<Model.Message> messages) {
      bool matchesFilter(Model.Message message) =>
          message.context.receptionID == filter.receptionID;

      expect(messages.every(matchesFilter), isTrue);
    }));
  }

  static Future messageCreateEvent(Service.RESTMessageStore messageStore,
      Storage.Contact contactStore, Storage.Reception receptionStore,
      Receptionist sender) {
    log.info('Started messageCreateEvent test');

    return MessageStore
        ._createMessage(messageStore, contactStore, receptionStore, sender)
        .then((Model.Message message) => sender
            .waitFor(eventType: Event.Key.messageChange)
            .then((Event.MessageChange changeEvent) {
      expect(changeEvent.messageID, isNotNull);
      expect(changeEvent.messageID, equals(message.ID));
    })).whenComplete(() => log.info('Finished messageCreateEvent test'));
  }

  static Future messageEnqueueEvent(Storage.Message messageStore,
      Storage.Contact contactStore, Storage.Reception receptionStore,
      Receptionist sender) {
    return MessageStore
        ._createMessage(messageStore, contactStore, receptionStore, sender)
        .then((Model.Message createdMessage) {
      {
        Model.Message randMsg = Randomizer.randomMessage();
        randMsg.ID = createdMessage.ID;
        randMsg.context = createdMessage.context;
        randMsg.senderId = createdMessage.senderId;
        createdMessage = randMsg;
      }

      return messageStore.enqueue(createdMessage).then((_) {
        bool idAndStateMatches(Event.Event event) {
          if (event is Event.MessageChange) {
            return event.messageID == createdMessage.ID &&
                event.state == Event.MessageChangeState.UPDATED;
          }

          return false;
        }

        return sender.notificationSocket.eventStream
            .firstWhere(idAndStateMatches).timeout(new Duration(milliseconds : 100));
      });
    });
  }

  /**
   *
   */
  static Future messageUpdateEvent(Storage.Message messageStore,
      Storage.Contact contactStore, Storage.Reception receptionStore,
      Receptionist sender) {
    log.info('Started messageUpdateEvent test');

    return MessageStore
        ._createMessage(messageStore, contactStore, receptionStore, sender)
        .then((Model.Message createdMessage) {
      bool idAndStateMatches(Event.Event event) {
        if (event is Event.MessageChange) {
          return event.messageID == createdMessage.ID &&
              event.state == Event.MessageChangeState.UPDATED;
        }

        return false;
      }

      return sender.notificationSocket.eventStream
          .firstWhere(idAndStateMatches).timeout(new Duration(milliseconds : 100));
    }).whenComplete(() => log.info('Finished messageUpdateEvent test'));
  }
}
