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

/**
 * Message state 'enum'.
 */
abstract class MessageState {

  static const Saved   = 'saved';
  static const Sent    = 'sent';
  static const Pending = 'pending';
  static const NotSaved = 'notsaved';

  static List<String> validStates = [Saved, Sent, Pending, NotSaved];

  static String ofMessage (Message message) {
    if (message.enqueued) {
      return Pending;
    } else if (message.sent) {
      return Sent;
    } else if (!message.sent && ! message.enqueued){
      return Saved;
    } else {
      return '';
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

    userID = map.containsKey(Key.userID)
        ? map[Key.userID]
        : userID;

    messageState = map.containsKey(Key.state)
        ? map[Key.state]
        : messageState;

    receptionID = map.containsKey(Key.receptionID)
        ? map[Key.receptionID]
        : receptionID;

    contactID = map.containsKey(Key.contactID)
        ? map[Key.contactID]
        : contactID;

    upperMessageID = map.containsKey(Key.upperMessageId)
        ? map[Key.upperMessageId]
        : upperMessageID;

    limitCount = map.containsKey(Key.limit)
        ? map[Key.limit]
        : limitCount;
  }

  /**
   * Current message state.
   */
  String get messageState  => this._messageState;
  void   set messageState (String newState) {

    if (newState == null) {
      throw new ArgumentError.notNull(newState);
    }

    if (newState.isNotEmpty) {
      if (!MessageState.validStates.contains(newState.toLowerCase())) {
        throw new ArgumentError.value (newState, 'newState',
            'State must one of: ${MessageState.validStates}');
      }

      this._messageState = newState.toLowerCase();
    } else {
      this._messageState = '';
    }
  }

  /**
   * Check if this filter is active (any field is set).
   */
  bool get active =>
      userID != User.noID ||
      receptionID != Reception.noID ||
      contactID != Contact.noID ||
      upperMessageID != Message.noID ||
      messageState.isNotEmpty;


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

  /**
   * Equals operator override. All fields of filter needs match in order for
   * two filter instances to be equal.
   */
  @override
  bool operator ==(MessageFilter other) =>
      this.upperMessageID == other.upperMessageID &&
      this.limitCount     == other.limitCount &&
      this.messageState   == other.messageState &&
      this.userID         == other.userID &&
      this.receptionID    == other.receptionID &&
      this.contactID      == other.contactID;

  /**
   * JSON serialization function.
   */
  Map toJson() => this.asMap;

  /**
   * Returns a map representation of the object.
   */
  Map get asMap {
    Map retval = {};

    if (this.userID != User.noID) {
      retval[Key.userID] = this.userID;
    }

    if (this.messageState != Message.noID) {
      retval[Key.state] = this.messageState;
    }

    if (this.receptionID != Reception.noID) {
      retval[Key.receptionID] = this.receptionID;
    }

    if (this.contactID != Contact.noID) {
      retval[Key.contactID] = this.contactID;
    }

    if (this.upperMessageID != Message.noID) {
      retval[Key.upperMessageId] = upperMessageID;
    }

    if (this.limitCount != Message.noID) {
      retval[Key.limit] = this.limitCount;
    }

    return retval;
  }

  /**
   * Returns a list of active limit fields used in SQL filter function.
   */
  List<String> get _activeFields {
    List<String> retval = [];

    if (this.upperMessageID != Message.noID) {
      retval.add('message.id <= ${this.upperMessageID}');
    }

    if (userID != User.noID) {
       retval.add('taken_by_agent = ${this.userID}');
    }

    if (receptionID != Reception.noID) {
       retval.add('context_reception_id = ${this.receptionID}');
    }

    if (contactID != Contact.noID) {
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
        retval.add('(NOT enqueued AND NOT sent)');
        break;

      case MessageState.NotSaved :
        retval.add('(enqueued OR sent)');
        break;

    }

    return retval;
  }

  /**
   * Return this filter as an SQL 'Where' clause.
   *
   * FIXME: This does not perform any form of expression checking and is, thus,
   * vulnerable to SQL injection.
   */
  String get asSQL =>
      (this.active ? 'WHERE ${this._activeFields.join(' AND ')}' : '');

}