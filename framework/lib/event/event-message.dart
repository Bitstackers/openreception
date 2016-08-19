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

/// Model class representing a change in a persistent [model.Message]
/// object. May be serialized and sent via a notification socket.
class MessageChange implements Event {
  @override
  final DateTime timestamp;

  @override
  final String eventName = _Key._messageChange;

  /// The message ID of the message that was modified.
  final int mid;

  /// The uid of the user modifying the calendar entry.
  final int modifierUid;

  /// The creation time of the [model.Message] object.
  final DateTime createdAt;

  /// The modification state. Must be one of the valid [Change] values.
  final String state;

  /// The state of the [model.Message].
  final model.MessageState messageState;

  /// Create a new creation event.
  factory MessageChange.create(int mid, int modifierUid,
          model.MessageState messageState, DateTime createdAt) =>
      new MessageChange._internal(
          mid, modifierUid, Change.created, messageState, createdAt);

  /// Create a new update event.
  factory MessageChange.update(int mid, int modifierUid,
          model.MessageState messageState, DateTime createdAt) =>
      new MessageChange._internal(
          mid, modifierUid, Change.updated, messageState, createdAt);

  /// Create a new deletion event.
  factory MessageChange.delete(int mid, int modifierUid,
          model.MessageState messageState, DateTime createdAt) =>
      new MessageChange._internal(
          mid, modifierUid, Change.deleted, messageState, createdAt);

  MessageChange._internal(
      this.mid, this.modifierUid, this.state, this.messageState, this.createdAt)
      : timestamp = new DateTime.now();

  /// Create a new [MessageChange] object from serialized data stored in [map].
  MessageChange.fromMap(Map<String, dynamic> map)
      : modifierUid = map.containsKey(_Key._modifierUid)
            ? map[_Key._modifierUid]
            : map.containsKey('messageChange')
                ? map['messageChange']['userID']
                : model.User.noId,
        mid = map[_Key._mid],
        state = map[_Key._state],
        messageState = map.containsKey(_Key._messageState)
            ? model.MessageState.values[map[_Key._messageState]]
            : model.MessageState.unknown,
        timestamp = util.unixTimestampToDateTime(map[_Key._timestamp]),
        createdAt = util.unixTimestampToDateTime(map[_Key._createdAt]);

  /// Determines if the object signifies a creation.
  bool get created => state == Change.created;

  /// Determines if the object signifies an update.
  bool get updated => state == Change.updated;

  /// Determines if the object signifies a deletion.
  bool get deleted => state == Change.deleted;

  /// Returns an umodifiable map representation of the object, suitable for
  /// serialization.
  @override
  Map<String, dynamic> toJson() =>
      new Map<String, dynamic>.unmodifiable(<String, dynamic>{
        _Key._event: eventName,
        _Key._timestamp: util.dateTimeToUnixTimestamp(timestamp),
        _Key._modifierUid: this.modifierUid,
        _Key._mid: this.mid,
        _Key._state: this.state,
        _Key._messageState: this.messageState.index,
        _Key._createdAt: util.dateTimeToUnixTimestamp(createdAt)
      });

  /// Returns a brief string-represented summary of the event, suitable for
  /// logging or debugging purposes.
  @override
  String toString() => '$timestamp-$eventName $state '
      'modifier:$modifierUid,mid:$mid,';
}
