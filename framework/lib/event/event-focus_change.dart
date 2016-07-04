/*                  This file is part of OpenReception
                   Copyright (C) 2016-, BitStackers K/S

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
class FocusChange implements Event {
  final DateTime timestamp;

  String get eventName => Key.focusChange;

  final int uid;
  final bool inFocus;

  /**
   * Default constructor. Takes [uid] of the user changing the widget and
   * the new focus state ([inFocus]) as mandatory arguments.
   */
  FocusChange(int this.uid, bool this.inFocus) : timestamp = new DateTime.now();

  /**
   * Deserializing constructor.
   */
  FocusChange.fromMap(Map map)
      : uid = map[Key.changedBy],
        inFocus = map[Key.inFocus],
        timestamp = util.unixTimestampToDateTime(map[Key.timestamp]);

  /**
   * Serialization function.
   */
  Map toJson() => {
        Key.event: eventName,
        Key.timestamp: util.dateTimeToUnixTimestamp(timestamp),
        Key.changedBy: uid,
        Key.inFocus: inFocus
      };

  /**
   * Returns a string reprensentation of the object.
   */
  @override
  String toString() => toJson().toString();
}
