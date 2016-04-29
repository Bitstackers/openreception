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

part of openreception.framework.model;

/**
 * Message filter model class. Meant for transmitting a filter 'function' from
 * a client to a server.
 */
class MessageFilter {
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
    userId = map.containsKey(Key.uid) ? map[Key.uid] : userId;

    receptionId = map.containsKey(Key.rid) ? map[Key.rid] : receptionId;

    contactId = map.containsKey(Key.cid) ? map[Key.cid] : contactId;

    limitCount = map.containsKey(Key.limit) ? map[Key.limit] : limitCount;
  }

  /**
   * Check if this filter is active (any field is set).
   */
  bool get active =>
      userId != User.noId ||
      receptionId != Reception.noId ||
      contactId != BaseContact.noId;

  /**
   * Check if the filter applies to [message].
   */
  bool appliesTo(Message message) =>
      [message.context.cid, BaseContact.noId].contains(contactId) &&
      [message.context.rid, Reception.noId].contains(receptionId) &&
      [message.sender.id, User.noId].contains(userId);

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
      userId == other.userId &&
      receptionId == other.receptionId &&
      contactId == other.contactId;

  /**
   * JSON serialization function. Returns a map representation of the object.
   */
  Map toJson() {
    Map retval = {};

    if (userId != User.noId) {
      retval[Key.uid] = userId;
    }

    if (receptionId != Reception.noId) {
      retval[Key.rid] = receptionId;
    }

    if (contactId != BaseContact.noId) {
      retval[Key.cid] = contactId;
    }

    retval[Key.limit] = limitCount;

    return retval;
  }

  /**
   *
   */
  String toString() => toJson().toString();
}
