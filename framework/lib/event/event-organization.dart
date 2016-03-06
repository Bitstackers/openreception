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
 * 'Enum' representing different outcomes of an [Organization] change.
 */
@deprecated
abstract class OrganizationState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

class OrganizationChange implements Event {
  final DateTime timestamp;

  String get eventName => Key.organizationChange;

  final int orgID;
  int userId;
  final String state;

  /**
   *
   */
  OrganizationChange.created(this.orgID, [this.userId])
      : this.state = Change.created,
        this.timestamp = new DateTime.now();

  /**
   *
   */
  OrganizationChange.updated(this.orgID, [this.userId])
      : this.state = Change.updated,
        this.timestamp = new DateTime.now();

  /**
   *
   */
  OrganizationChange.deleted(this.orgID, [this.userId])
      : this.state = Change.deleted,
        this.timestamp = new DateTime.now();

  @deprecated
  OrganizationChange(this.orgID, this.state)
      : this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap {
    Map template = EventTemplate._rootElement(this);

    Map body = {
      Key.organizationID: this.orgID,
      Key.state: this.state,
      Key.userID: userId
    };

    template[this.eventName] = body;

    return template;
  }

  OrganizationChange.fromMap(Map map)
      : this.orgID = map[Key.organizationChange][Key.organizationID],
        this.state = map[Key.organizationChange][Key.state],
        this.userId = map[Key.organizationChange][Key.userID],
        this.timestamp = Util.unixTimestampToDateTime(map[Key.timestamp]);
}
