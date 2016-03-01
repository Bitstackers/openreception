part of openreception_tests.storage;

abstract class MessageStore {
  static final Logger log = new Logger('$_libraryName.MessageStore');

  /**
   * Test server behaviour when trying to retrieve a non-filtered list of
   * message objects.
   *
   * The expected behaviour is that the server should return a list
   * of message objects.
   */
  static Future list(storage.Message messageStore) {
    log.info('Listing messages non-filtered.');

    return messageStore.list().then((Iterable<model.Message> messages) {
      expect(messages.length, greaterThan(0));
      expect(messages.every((msg) => msg is model.Message), isTrue);
    });
  }

  /**
   *
   */
  static Future<model.Message> _createMessage(
      storage.Message messageStore,
      storage.Contact contactStore,
      storage.Reception receptionStore,
      storage.Endpoint epStore,
      Receptionist sender) async {
    String receptionID = '1';
    String contactID = '4';
    model.ReceptionAttributes contact =
        await contactStore.getByReception(contactID, receptionID);
    model.Reception reception = await receptionStore.get(receptionID);
    Set<model.MessageRecipient> recipients = new Set();

    await Future.wait(
        (await dlStore.list(contact.receptionID, contact.ID)).map((dle) async {
      Iterable<model.MessageEndpoint> eps =
          await epStore.list(contact.receptionID, contact.ID);
      recipients.addAll(eps.map(
          (model.MessageEndpoint mep) => new model.MessageRecipient(mep, dle)));
    }));

    model.Message newMessage = Randomizer.randomMessage()
      ..context = new model.MessageContext.fromContact(contact, reception)
      ..recipients = recipients
      ..senderUuid = sender.user.ID;

    return messageStore.create(newMessage);
  }

  /**
   *
   */
  static Future create(
      storage.Message messageStore,
      storage.Contact contactStore,
      storage.Reception receptionStore,
      Storage.DistributionList dlStore,
      storage.Endpoint epStore,
      Receptionist sender) async {
    model.Message createdMessage = await _createMessage(
        messageStore, contactStore, receptionStore, dlStore, epStore, sender);

    model.Message fetchedMessage = await messageStore.get(createdMessage.ID);

    expect(createdMessage.asMap, equals(fetchedMessage.asMap));

    expect(createdMessage.body, isNotEmpty);
    expect(createdMessage.enqueued, isFalse);
    expect(createdMessage.sent, isFalse);
    expect(createdMessage.senderUuid, sender.user.id);

    return messageStore.remove(createdMessage.ID);
  }

  /**
   *
   */
  static Future remove(
      storage.Message messageStore,
      storage.Contact contactStore,
      storage.Reception receptionStore,
      Storage.DistributionList dlStore,
      storage.Endpoint epStore,
      Receptionist sender) async {
    model.Message createdMessage = await _createMessage(
        messageStore, contactStore, receptionStore, dlStore, epStore, sender);

    await messageStore.remove(createdMessage.ID);

    expect(messageStore.get(createdMessage.ID),
        throwsA(new isInstanceOf<storage.NotFound>()));
  }

  static Future enqueue(
      storage.Message messageStore,
      storage.Contact contactStore,
      storage.Reception receptionStore,
      Storage.DistributionList dlStore,
      storage.Endpoint epStore,
      Receptionist sender) async {
    model.Message createdMessage = await _createMessage(
        messageStore, contactStore, receptionStore, dlStore, epStore, sender);

    return messageStore.enqueue(createdMessage);
  }

  /**
   * Test server behaviour when trying to aquire a message object that
   * exists.
   *
   * The expected behaviour is that the server should return the
   * Reception object.
   */
  static Future<model.Message> get(storage.Message messageStore) {
    int existingMessageID = 1;

    log.info('Checking server behaviour on an existing message.');

    return messageStore.get(existingMessageID).then((model.Message message) {
      expect(message.ID, equals(existingMessageID));
    });
  }

  /**
   *
   */
  static Future update(
      storage.Message messageStore,
      storage.Contact contactStore,
      storage.Reception receptionStore,
      Storage.DistributionList dlStore,
      storage.Endpoint epStore,
      Receptionist sender) {
    return _createMessage(messageStore, contactStore, receptionStore, dlStore,
        epStore, sender).then((model.Message createdMessage) {
      {
        model.Message randMsg = Randomizer.randomMessage();
        randMsg.ID = createdMessage.ID;
        randMsg.context = createdMessage.context;
        randMsg.senderUuid = createdMessage.senderUuid;
        createdMessage = randMsg;
      }

      return messageStore
          .update(createdMessage)
          .then((model.Message updatedMessage) {
        expect(createdMessage.ID, equals(updatedMessage.ID));
        expect(createdMessage.asMap, equals(updatedMessage.asMap));
        expect(createdMessage.body, equals(updatedMessage.body));
        expect(createdMessage.callerInfo.asMap,
            equals(updatedMessage.callerInfo.asMap));
        expect(createdMessage.closed, equals(updatedMessage.closed));
        expect(
            createdMessage.flag.toJson(), equals(updatedMessage.flag.toJson()));
        expect(
            createdMessage.hasRecpients, equals(updatedMessage.hasRecpients));
        expect(createdMessage.recipients, equals(updatedMessage.recipients));
        expect(createdMessage.senderUuid, equals(updatedMessage.senderUuid));
        expect(createdMessage.sent, equals(updatedMessage.sent));
      });
    });
  }
}
