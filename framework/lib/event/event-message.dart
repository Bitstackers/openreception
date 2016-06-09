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

part of openreception.framework.event;

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
  final model.MessageState messageState;

  MessageChange._internal(
      this.mid, this.modifierUid, this.state, this.messageState)
      : timestamp = new DateTime.now();

  factory MessageChange.create(
          int mid, int modifierUid, model.MessageState messageState) =>
      new MessageChange._internal(
          mid, modifierUid, Change.created, messageState);

  factory MessageChange.update(
          int mid, int modifierUid, model.MessageState messageState) =>
      new MessageChange._internal(
          mid, modifierUid, Change.updated, messageState);

  factory MessageChange.delete(
          int mid, int modifierUid, model.MessageState messageState) =>
      new MessageChange._internal(
          mid, modifierUid, Change.deleted, messageState);

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap {
    Map template = EventTemplate._rootElement(this);

    Map body = {
      Key.modifierUid: this.modifierUid,
      Key.messageID: this.mid,
      Key.state: this.state,
      Key.messageState: this.messageState.index
    };

    template[this.eventName] = body;

    return template;
  }

  MessageChange.fromMap(Map map)
      : modifierUid = map[Key.messageChange][Key.modifierUid],
        mid = map[Key.messageChange][Key.messageID],
        state = map[Key.messageChange][Key.state],
        messageState = map[Key.messageChange].containsKey(Key.messageState)
            ? model.MessageState.values[map[Key.messageChange]
                [Key.messageState]]
            : model.MessageState.unknown,
        timestamp = Util.unixTimestampToDateTime(map[Key.timestamp]);
}
