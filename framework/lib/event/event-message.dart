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
 *
 */
class MessageChange implements Event {
  final DateTime timestamp;

  String get eventName => Key.messageChange;

  bool get created => state == Change.created;
  bool get updated => state == Change.updated;
  bool get deleted => state == Change.deleted;

  final int mid;
  final int modifierUid;
  final String state;

  MessageChange._internal(this.mid, this.modifierUid, this.state)
      : timestamp = new DateTime.now();

  factory MessageChange.create(int mid, int modifierUid) =>
      new MessageChange._internal(mid, modifierUid, Change.created);

  factory MessageChange.update(int mid, int modifierUid) =>
      new MessageChange._internal(mid, modifierUid, Change.updated);

  factory MessageChange.delete(int mid, int modifierUid) =>
      new MessageChange._internal(mid, modifierUid, Change.deleted);

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap {
    Map template = EventTemplate._rootElement(this);

    Map body = {
      Key.modifierUid: this.modifierUid,
      Key.messageID: this.mid,
      Key.state: this.state
    };

    template[this.eventName] = body;

    return template;
  }

  MessageChange.fromMap(Map map)
      : modifierUid = map[Key.messageChange][Key.modifierUid],
        mid = map[Key.messageChange][Key.messageID],
        state = map[Key.messageChange][Key.state],
        timestamp = Util.unixTimestampToDateTime(map[Key.timestamp]);
}
