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
 * 'Enum' representing different outcomes of an [Endpoint] change.
 */
abstract class EndpointState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

class EndpointChange implements Event {

  final DateTime timestamp;

  String get eventName => Key.endpointChange;

  final int receptionID;
  final int contactID;
  final String address;
  final String addressType;
  final String state;

  EndpointChange (this.contactID, this.receptionID, this.state,
                  this.address, this.addressType) :
    this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap {
    Map template = EventTemplate._rootElement(this);

    Map body = {
      Key.contactID   : contactID,
      Key.receptionID : receptionID,
      Key.address     : address,
      Key.addressType : addressType,
      Key.state       : state};

    template[this.eventName] = body;

    return template;
  }

  EndpointChange.fromMap (Map map) :
    this.contactID = map[Key.endpointChange][Key.contactID],
    this.receptionID = map[Key.endpointChange][Key.receptionID],
    this.address = map[Key.endpointChange][Key.address],
    this.addressType = map[Key.endpointChange][Key.addressType],
    this.state = map[Key.endpointChange][Key.state],
    this.timestamp = Util.unixTimestampToDateTime (map[Key.timestamp]);
}