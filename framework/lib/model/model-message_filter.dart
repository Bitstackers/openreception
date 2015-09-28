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

class InvalidState implements Exception {
  String _state;
  InvalidState (this._state);
}


abstract class MessageState {

  static const Saved   = 'saved';
  static const Sent    = 'sent';
  static const Pending = 'pending';
  static const NotSaved = 'notSaved';

  static List<String> validStates = [Saved, Sent, Pending, NotSaved];

  static String ofMessage (Message message) {
    if (message.enqueued) {
      return Pending;
    } else if (message.sent) {
      return Sent;
    } else if (!message.sent && ! message.enqueued){
      return Saved;
    } else if (!message.sent || ! message.enqueued){
      return NotSaved;
    } else {
      return null;
    }
  }
}

/**
 * Message filter model class. Meant for transmitting a filter 'function' from
 * a client to a server.
 */
class MessageFilter {
  String    _messageState  = '';

  int    upperMessageID = Message.noID;
  int    userID         = User.noID;
  int    receptionID    = Reception.noID;
  int    contactID      = Contact.noID;
  int    limitCount     = 100;

  /**
   * Default empty constructor.
   */
  MessageFilter.empty();

  /**
   * Deserializing constructor.
   */
  MessageFilter.fromMap(Map map) {

    userID = map.containsKey('user_id')
        ? map['user_id']
        : userID;

    messageState = map.containsKey('state')
        ? map['state']
        : messageState;

    receptionID = map.containsKey('reception_id')
        ? map['reception_id']
        : receptionID;

    contactID = map.containsKey('contact_id')
        ? map['contact_id']
        : contactID;

    upperMessageID = map.containsKey('upper_message_id')
        ? map['upper_message_id']
        : upperMessageID;

    limitCount = map.containsKey('limit')
        ? map['limit']
        : limitCount;
  }

  /**
   * Current message state.
   */
  String get messageState  => this._messageState;
  void   set messageState (String newState) {

    if (newState != null) {
      if (!MessageState.validStates.contains(newState.toLowerCase())) {
        throw new InvalidState (newState.toLowerCase());
      }

      this._messageState = newState.toLowerCase();
    } else {
      this._messageState = '';
    }
  }

  bool get active => [userID, receptionID, contactID, upperMessageID]
                      .any((int field) => field != null && field != Message.noID)
                      || messageState != null;


  /**
   * Check if the filter applies to [message].
   */
  bool appliesTo (Message message) =>
      [message.context.contactID, Contact.noID].contains(this.contactID) &&
      [message.context.receptionID, Reception.noID].contains(this.receptionID) &&
      [message.senderId, User.noID].contains(this.userID) &&
      [MessageState.ofMessage(message), Message.noID].contains(this.contactID);

  /**
   * Filters [messages] using this filter.
   */
  Iterable<Message> filter (Iterable<Message> messages) =>
      messages.where((Message message) => this.appliesTo (message));

  @override
  operator == (MessageFilter other) =>
      this.upperMessageID == other.upperMessageID &&
      this.limitCount     == other.limitCount &&
      this.messageState   == other.messageState &&
      this.userID         == other.userID &&
      this.receptionID    == other.receptionID &&
      this.contactID      == other.contactID;

  Map toJson() => this.asMap;

  Map get asMap {
    Map retval = {};

    if (this.userID != User.noID) {
      retval['user_id'] = this.userID;
    }

    if (this.messageState != Message.noID) {
      retval['state'] = this.messageState;
    }

    if (this.receptionID != Reception.noID) {
      retval['reception_id'] = this.receptionID;
    }

    if (this.contactID != Contact.noID) {
      retval['contact_id'] = this.contactID;
    }

    if (this.upperMessageID != Message.noID) {
      retval['upper_message_id'] = upperMessageID;
    }

    if (this.limitCount != Message.noID) {
      retval['limit'] = this.limitCount;
    }

    return retval;
  }

  List<String> get activeFields {
    List<String> retval = [];

    if (this.upperMessageID != Message.noID) {
      retval.add('message.id <= ${this.upperMessageID}');
    }

    if (userID != null) {
       retval.add('taken_by_agent = ${this.userID}');
    }

    if (receptionID != null) {
       retval.add('context_reception_id = ${this.receptionID}');
    }

    if (contactID != null) {
       retval.add('context_contact_id = ${this.contactID}');
    }

    switch (this._messageState) {
      case MessageState.Pending :
        retval.add('enqueued');
        break;

      case MessageState.Sent :
        retval.add('sent');
        break;

      case MessageState.Saved :
        retval.add('NOT enqueued AND NOT sent');
        break;

      case MessageState.NotSaved :
        retval.add('NOT enqueued OR NOT sent');
        break;
    }

    return retval;
  }

  String get asSQL =>
      (this.active ? 'WHERE ${this.activeFields.join(' AND ')}' : '');

}