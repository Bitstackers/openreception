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
 * 'Enum' representing different outcomes of a [CalendarEntry] change.
 */
abstract class CalendarEntryState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

/**
 * Model class representing a change in a [CalendarEntry]. May be serialized
 * and sent via a notification socket.
 */
class CalendarChange implements Event {

  final DateTime timestamp;

  String get eventName => Key.calendarChange;

  final int entryID;
  final int contactID;
  final int receptionID;
  final String state;

  CalendarChange (this.entryID, this.contactID, this.receptionID, this.state) :
    this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap {
    Map template = EventTemplate._rootElement(this);

    Map body = {Key.entryID     : this.entryID,
                Key.receptionID : this.receptionID,
                Key.contactID   : this.contactID,
                Key.state       : this.state};

    template[Key.calendarChange] = body;

    return template;
  }

  CalendarChange.fromMap (Map map) :
    this.entryID = map[Key.calendarChange][Key.entryID],
    this.contactID = map[Key.calendarChange][Key.contactID],
    this.receptionID = map[Key.calendarChange][Key.receptionID],
    this.state = map[Key.calendarChange][Key.state],
    this.timestamp = util.unixTimestampToDateTime (map[Key.timestamp]);
}
