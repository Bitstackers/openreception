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

part of openreception.model;

/**
 * Model class representing a client connection. A client connection object is
 * an information object that reveals information about how many open
 * push notification connections a user (of id [userID]) currently has.
 */
class ClientConnection {
  int userID;
  int connectionCount;


  @deprecated
  factory ClientConnection() => new ClientConnection.empty();

  /**
   * Default emtpy constructor.
   */
  ClientConnection.empty();

  /**
   * Deserializing constructor.
   */
  ClientConnection.fromMap(Map map) {
    userID = map[_Key.userID];
    connectionCount = map[_Key.connectionCount];
  }

  /**
   * JSON encoding function.
   */
  Map toJson() => this.asMap;

  /**
   * Returns a map representation of this object.
   */
  Map get asMap => {
    _Key.userID : userID,
    _Key.connectionCount : connectionCount
  };
}