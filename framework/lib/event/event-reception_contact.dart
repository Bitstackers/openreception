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
 * 'Enum' representing different outcomes of an [ReceptionContact] change.
 *
 * TODO (krc): Figure out if this is still needed in to ManagementServer.
 */
abstract class ReceptionContactState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

class ReceptionContactChange implements Event {

  final DateTime timestamp;

  String get eventName => Key.receptionContactChange;

  final int receptionID;
  final int contactID;
  final String state;

  ReceptionContactChange (this.contactID, this.receptionID, this.state) :
    this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap {
    Map template = EventTemplate._rootElement(this);

    Map body = {
      Key.contactID   : contactID,
      Key.receptionID : receptionID,
      Key.state       : state};

    template[this.eventName] = body;

    return template;
  }

  ReceptionContactChange.fromMap (Map map) :
    this.contactID = map[Key.receptionContactChange][Key.contactID],
    this.receptionID = map[Key.receptionContactChange][Key.receptionID],
    this.state = map[Key.receptionContactChange][Key.state],
    this.timestamp = Util.unixTimestampToDateTime (map[Key.timestamp]);
}