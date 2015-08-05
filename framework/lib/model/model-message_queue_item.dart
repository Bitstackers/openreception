/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.model;

class MessageQueueItem {

  int                   ID;
  int                   tries              = 0;
  int                   messageID          = Message.noID;
  List<MessageEndpoint> unhandledEndpoints = [];
  Message                _cachedMessage    = null;


  /**
   * Default constructor.
   */
  MessageQueueItem();

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
   * Serialization function
   */
  Map toJson() => {
    'id' : ID,
    'message_id' : messageID,
    'tries' : tries
  };


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