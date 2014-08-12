part of openreception.model;

class MessageQueueItem {

  int     ID;
  int     tries                            = null;
  int     messageID                        = Message.noID;
  List<MessageEndpoint> unhandledEndpoints = [];
  Message                _cachedMessage    = null;

  Future<Message> message (Storage.Message messageStore) {
    if (this._cachedMessage == null)
      return messageStore.get(this.messageID).then((Message fetchedMessage) {
        this._cachedMessage = fetchedMessage;

        if (this.tries == 0) {
          assert (this.unhandledEndpoints.isNotEmpty);

          fetchedMessage.recipients.forEach((MessageRecipient recipient) {
            this.unhandledEndpoints.addAll(recipient.endpoints);
          });
        }
        return this._cachedMessage;
      });

    else {
      return new Future(() => this._cachedMessage);
    }
  }

  Future save (Storage.MessageQueue messageQeueStore) {
      return new Future (() => throw new StateError('Not implemented'));
  }

}