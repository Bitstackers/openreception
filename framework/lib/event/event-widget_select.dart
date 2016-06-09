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

class WidgetSelect implements Event {
  final DateTime timestamp;

  String get eventName => Key.widgetSelect;

  final int uid;
  final String widgetName;

  WidgetSelect._internal(this.uid, this.widgetName)
      : timestamp = new DateTime.now();

  factory WidgetSelect(int uid, String widgetName) =>
      new WidgetSelect._internal(uid, widgetName);

  Map toJson() => {
        Key.event: eventName,
        Key.timestamp: util.dateTimeToUnixTimestamp(timestamp),
        Key.changedBy: uid,
        Key.widget: widgetName
      };

  /**
   *
   */
  @override
  String toString() => toJson().toString();

  /**
  *
  */
  WidgetSelect.fromMap(Map map)
      : uid = map[Key.changedBy],
        widgetName = map[Key.widget],
        timestamp = util.unixTimestampToDateTime(map[Key.timestamp]);
}

class FocusChange implements Event {
  final DateTime timestamp;

  String get eventName => Key.widgetSelect;

  final int uid;
  final bool inFocus;

  FocusChange._internal(this.uid, this.inFocus)
      : timestamp = new DateTime.now();

  factory FocusChange(int uid, bool inFocus) =>
      new FocusChange._internal(uid, inFocus);

  Map toJson() => {
        Key.event: eventName,
        Key.timestamp: util.dateTimeToUnixTimestamp(timestamp),
        Key.changedBy: uid,
        Key.inFocus: inFocus
      };

  /**
   *
   */
  @override
  String toString() => toJson().toString();

  /**
  *
  */
  FocusChange.fromMap(Map map)
      : uid = map[Key.changedBy],
        inFocus = map[Key.inFocus],
        timestamp = util.unixTimestampToDateTime(map[Key.timestamp]);
}
