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
  InvalidState(this._state);
}

/**
 * Message state 'enum'.
 */
abstract class MessageState {
  static const Saved = 'saved';
  static const Sent = 'sent';
  static const Pending = 'pending';
  static const NotSaved = 'notsaved';

  static List<String> validStates = [Saved, Sent, Pending, NotSaved];

  static String ofMessage(Message message) {
    if (message.enqueued) {
      return Pending;
    } else if (message.sent) {
      return Sent;
    } else if (!message.sent && !message.enqueued) {
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
  String _messageState = '';

  int userId = User.noId;
  int receptionId = Reception.noId;
  int contactId = BaseContact.noId;
  int limitCount = 100;

  /**
   * Default empty constructor.
   */
  MessageFilter.empty();

  /**
   * Deserializing constructor.
   */
  MessageFilter.fromMap(Map map) {
    userId = map.containsKey(Key.userId) ? map[Key.userId] : userId;

    messageState = map.containsKey(Key.state) ? map[Key.state] : messageState;

    receptionId =
        map.containsKey(Key.receptionId) ? map[Key.receptionId] : receptionId;

    contactId = map.containsKey(Key.contactId) ? map[Key.contactId] : contactId;

    limitCount = map.containsKey(Key.limit) ? map[Key.limit] : limitCount;
  }

  /**
   * Current message state.
   */
  String get messageState => this._messageState;
  void set messageState(String newState) {
    if (newState == null) {
      throw new ArgumentError.notNull(newState);
    }

    if (newState.isNotEmpty) {
      if (!MessageState.validStates.contains(newState.toLowerCase())) {
        throw new ArgumentError.value(newState, 'newState',
            'State must one of: ${MessageState.validStates}');
      }

      _messageState = newState.toLowerCase();
    } else {
      _messageState = '';
    }
  }

  /**
   * Check if this filter is active (any field is set).
   */
  bool get active =>
      userId != User.noId ||
      receptionId != Reception.noId ||
      contactId != ReceptionAttributes.noId ||
      messageState.isNotEmpty;

  /**
   * Check if the filter applies to [message].
   */
  bool appliesTo(Message message) =>
      [message.context.contactId, ReceptionAttributes.noId]
          .contains(contactId) &&
      [message.context.receptionId, Reception.noId].contains(receptionId) &&
      [message.senderId, User.noId].contains(userId) &&
      [MessageState.ofMessage(message), Message.noId].contains(contactId);

  /**
   * Filters [messages] using this filter.
   */
  Iterable<Message> filter(Iterable<Message> messages) =>
      messages.where((Message message) => appliesTo(message));

  /**
   * Equals operator override. All fields of filter needs match in order for
   * two filter instances to be equal.
   */
  @override
  bool operator ==(MessageFilter other) =>
      limitCount == other.limitCount &&
      messageState == other.messageState &&
      userId == other.userId &&
      receptionId == other.receptionId &&
      contactId == other.contactId;

  /**
   * JSON serialization function. Returns a map representation of the object.
   */
  Map toJson() {
    Map retval = {};

    if (userId != User.noId) {
      retval[Key.userId] = userId;
    }

    if (messageState != Message.noId) {
      retval[Key.state] = messageState;
    }

    if (receptionId != Reception.noId) {
      retval[Key.receptionId] = receptionId;
    }

    if (contactId != ReceptionAttributes.noId) {
      retval[Key.contactId] = contactId;
    }

    retval[Key.limit] = limitCount;

    return retval;
  }

  /**
   * Returns a list of active limit fields used in SQL filter function.
   */
  List<String> get _activeFields {
    List<String> retval = [];

    if (userId != User.noId) {
      retval.add('taken_by_agent = ${this.userId}');
    }

    if (receptionId != Reception.noId) {
      retval.add('context_reception_id = ${this.receptionId}');
    }

    if (contactId != ReceptionAttributes.noId) {
      retval.add('context_contact_id = ${this.contactId}');
    }

    switch (this._messageState) {
      case MessageState.Pending:
        retval.add('enqueued');
        break;

      case MessageState.Sent:
        retval.add('sent');
        break;

      case MessageState.Saved:
        retval.add('(NOT enqueued AND NOT sent)');
        break;

      case MessageState.NotSaved:
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
