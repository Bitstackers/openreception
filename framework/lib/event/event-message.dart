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
  @override
  final DateTime timestamp;

  @override
  String get eventName => Key.messageChange;

  bool get created => state == Change.created;
  bool get updated => state == Change.updated;
  bool get deleted => state == Change.deleted;

  final int mid;
  final int modifierUid;
  final DateTime createdAt;
  final String state;
  final model.MessageState messageState;

  MessageChange._internal(
      this.mid, this.modifierUid, this.state, this.messageState, this.createdAt)
      : timestamp = new DateTime.now();

  factory MessageChange.create(int mid, int modifierUid,
          model.MessageState messageState, DateTime createdAt) =>
      new MessageChange._internal(
          mid, modifierUid, Change.created, messageState, createdAt);

  factory MessageChange.update(int mid, int modifierUid,
          model.MessageState messageState, DateTime createdAt) =>
      new MessageChange._internal(
          mid, modifierUid, Change.updated, messageState, createdAt);

  factory MessageChange.delete(int mid, int modifierUid,
          model.MessageState messageState, DateTime createdAt) =>
      new MessageChange._internal(
          mid, modifierUid, Change.deleted, messageState, createdAt);

  @override
  String toString() => this.asMap.toString();

  Map get asMap => toJson();

  @override
  Map toJson() => {
        Key.event: eventName,
        Key.timestamp: util.dateTimeToUnixTimestamp(timestamp),
        Key.modifierUid: this.modifierUid,
        Key.messageID: this.mid,
        Key.state: this.state,
        Key.messageState: this.messageState.index,
        Key._createdAt: util.dateTimeToUnixTimestamp(createdAt)
      };

  /**
   * Deserializing contstructor.
   */
  MessageChange.fromMap(Map map)
      : modifierUid = map.containsKey(Key.modifierUid)
            ? map[Key.modifierUid]
            : map.containsKey('messageChange')
                ? map['messageChange']['userID']
                : model.User.noId,
        mid = map[Key.messageID],
        state = map[Key.state],
        messageState = map.containsKey(Key.messageState)
            ? model.MessageState.values[map[Key.messageState]]
            : model.MessageState.unknown,
        timestamp = util.unixTimestampToDateTime(map[Key.timestamp]),
        createdAt = util.unixTimestampToDateTime(map[Key._createdAt]);
}
