part of openreception.model;

class MessageQueueItem {

  int                   ID;
  int                   tries              = 0;
  int                   messageID          = Message.noID;
  List<MessageEndpoint> unhandledEndpoints = [];
  Message                _cachedMessage    = null;

  /**
   * Creates a message from the information given in [map].
   * The expected map format is:
   *     {
   *       int       queue_id,
   *       int       message_id,
   *       int       tries,
   *       List<Map> unhandledEndpoints
   *     }
   */
  MessageQueueItem.fromMap (Map map) {

    this.ID = map['id'];
    this.messageID= map['message_id'];
    this.tries = map['tries'];
    if (tries > 0) {
      this.unhandledEndpoints.addAll
           (map['unhandled_endpoints'].map((Map endpointMap)
                => new MessageEndpoint.fromMap(endpointMap)));
    }
  }

 /**
  * Asyncronously fetches the message associated with the queue entry.
  * The message will be cached, and thus, only fetched once.
  */
  Future<Message> message (Storage.Message messageStore) {
    if (this._cachedMessage == null)
      return messageStore.get(this.messageID).then((Message fetchedMessage) {
        this._cachedMessage = fetchedMessage;

        if (this.tries == 0) {
          fetchedMessage.recipients.asSet.forEach((MessageRecipient recipient) {
            this.unhandledEndpoints.addAll(recipient.endpoints);
          });
        }
        return this._cachedMessage;
      });

    else {
      return new Future(() => this._cachedMessage);
    }
  }

  /**
   * Persistenly stores the message in the [messageStore] passed.
   */
  Future save (Storage.MessageQueue messageQeueStore) => messageQeueStore.save (this);

  /**
   * Persistenly archives the message from the [messageStore] passed.
   */
  Future archive (Storage.MessageQueue messageQeueStore) => messageQeueStore.archive (this);

}