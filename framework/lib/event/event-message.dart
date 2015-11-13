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

part of openreception.event;

/**
 * 'Enum' representing different outcomes of a [Message] change.
 */
abstract class MessageChangeState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

class MessageChange implements Event {

  final DateTime timestamp;

  String get eventName => Key.messageChange;

  final int messageID;
  final int userID;
  final String state;

  MessageChange.created (this.messageID, this.userID) :
    timestamp = new DateTime.now(),
    state = MessageChangeState.CREATED;

  MessageChange.updated (this.messageID, this.userID) :
    timestamp = new DateTime.now(),
    state = MessageChangeState.UPDATED;

  MessageChange.deleted (this.messageID, this.userID) :
    timestamp = new DateTime.now(),
    state = MessageChangeState.DELETED;

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap {
    Map template = EventTemplate._rootElement(this);

    Map body = {
      Key.userID    : this.userID,
      Key.messageID : this.messageID,
      Key.state     : this.state};

    template[this.eventName] = body;

    return template;
  }

  MessageChange.fromMap (Map map) :
    userID = map[Key.messageChange][Key.userID],
    messageID = map[Key.messageChange][Key.messageID],
    state = map[Key.messageChange][Key.state],
    timestamp = Util.unixTimestampToDateTime (map[Key.timestamp]);
}
