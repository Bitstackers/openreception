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

part of orf.event;

/// Event that notifies about a complete call-state reload.
class CallStateReload implements Event {
  @override
  final String eventName = _Key._callStateReload;
  @override
  final DateTime timestamp;

  /// Default constructor. Subtypes the general [CallEvent] class and should
  /// be used to notify clients about a full call-state reload.
  CallStateReload() : this.timestamp = new DateTime.now();

  /// Create a new [CallStateReload] object from serialized data stored in [map].
  CallStateReload.fromJson(Map<String, dynamic> map)
      : this.timestamp = util.unixTimestampToDateTime(map[_Key._timestamp]);

  /// Returns an umodifiable map representation of the object, suitable for
  /// serialization.
  @override
  Map<String, dynamic> toJson() =>
      new Map<String, dynamic>.unmodifiable(<String, dynamic>{
        _Key._event: eventName,
        _Key._timestamp: util.dateTimeToUnixTimestamp(timestamp)
      });

  /// Returns a brief string-represented summary of the event, suitable for
  /// logging or debugging purposes.
  @override
  String toString() => '$timestamp-$eventName';
}
