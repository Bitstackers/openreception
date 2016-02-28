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
 * 'Enum' representing different outcomes of a
 * [Contact] or [BaseContact] change.
 */
abstract class ContactState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

class ContactChange implements Event {

  final DateTime timestamp;

  String get eventName => Key.contactChange;

  final int contactID;
  final String state;

  ContactChange (this.contactID, this.state) :
    this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap {
    Map template = EventTemplate._rootElement(this);

    Map body = {Key.contactID   : this.contactID,
                Key.state       : this.state};

    template[Key.calendarChange] = body;

    return template;
  }

  ContactChange.fromMap (Map map) :
    this.contactID = map[Key.calendarChange][Key.contactID],
    this.state = map[Key.calendarChange][Key.state],
    this.timestamp = util.unixTimestampToDateTime (map[Key.timestamp]);
}
