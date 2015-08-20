part of or_test_fw;

abstract class MessageStore {

  static final Logger log = new Logger ('$libraryName.MessageStore');

  /**
   * Test server behaviour when trying to retrieve a non-filtered list of
   * message objects.
   *
   * The expected behaviour is that the server should return a list
   * of message objects.
   */
  static Future list (Storage.Message messageStore) {

    log.info('Listing messages non-filtered.');

    return messageStore.list()
      .then((List<Model.Message> messages) {
        expect(messages.length, greaterThan(0));
        expect(messages.every((msg) => msg is Model.Message), isTrue);
    });
  }

  /**
   *
   */
  static Future<Model.Message> _createMessage(Storage.Message messageStore,
                                Storage.Contact contactStore,
                                Storage.Reception receptionStore,
                                Receptionist sender) {

    int receptionID = 1;
    int contactID = 1;
    Set<Model.MessageRecipient> recipients = new Set();

    return contactStore.getByReception(contactID, receptionID)
      .then((Model.Contact contact) =>
        Future.forEach(contact.distributionList, (Model.DistributionListEntry de) =>
          contactStore.getByReception(de.contactID, de.receptionID)
            .then((Model.Contact c) {
              c.endpoints.forEach((Model.MessageEndpoint mep) {
                recipients.add (new Model.MessageRecipient(mep, de));
              });
      }))
      .then((_) =>
        receptionStore.get(receptionID)
          .then((Model.Reception reception) {
            Model.Message newMessage = Randomizer.randomMessage()
              ..context = new Model.MessageContext.fromContact
                            (contact, reception)
              ..recipients = recipients
              ..senderId = sender.user.ID;

            return messageStore.create(newMessage)
              .then((Model.Message createdMessage) {

              return createdMessage;
            });
    })));
  }

  /**
   *
   */
  static Future create(Storage.Message messageStore,
                                Storage.Contact contactStore,
                                Storage.Reception receptionStore,
                                Receptionist sender) =>

    _createMessage (messageStore, contactStore, receptionStore, sender);

  Future enqueue (Model.Message message);

  /**
   * Test server behaviour when trying to aquire a message object that
   * exists.
   *
   * The expected behaviour is that the server should return the
   * Reception object.
   */
  static Future<Model.Message> get (Storage.Message messageStore) {
    int existingMessageID = 1;

    log.info('Checking server behaviour on an existing message.');

    return messageStore.get(existingMessageID)
      .then ((Model.Message message) {
        expect (message.ID, equals(existingMessageID));
    });
  }


  /**
   *
   */
  static Future update(Storage.Message messageStore,
                         Storage.Contact contactStore,
                         Storage.Reception receptionStore,
                         Receptionist sender) {

      return  _createMessage (messageStore, contactStore, receptionStore, sender)
        .then((Model.Message createdMessage) {
        {
          Model.Message randMsg = Randomizer.randomMessage();
          randMsg.ID = createdMessage.ID;
          randMsg.context = createdMessage.context;
          randMsg.senderId = createdMessage.senderId;
          createdMessage = randMsg;
        }

        return messageStore.update(createdMessage)
            .then((Model.Message updatedMessage) {
          expect(createdMessage.ID, equals(updatedMessage.ID));
          expect(createdMessage.asMap, equals(updatedMessage.asMap));
          expect(createdMessage.body, equals(updatedMessage.body));
          expect(createdMessage.callerInfo.asMap, equals(updatedMessage.callerInfo.asMap));
          expect(createdMessage.closed, equals(updatedMessage.closed));
          expect(createdMessage.flag.toJson(), equals(updatedMessage.flag.toJson()));
          expect(createdMessage.hasRecpients, equals(updatedMessage.hasRecpients));
          expect(createdMessage.recipients, equals(updatedMessage.recipients));
          expect(createdMessage.senderId, equals(updatedMessage.senderId));
          expect(createdMessage.sent, equals(updatedMessage.sent));
        });
      });
    }
}
