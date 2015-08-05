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

part of openreception.resource;

abstract class Notification {

  static Uri notifications(Uri host) {
    if (!['ws', 'wss'].contains(host.scheme)) {
      throw new ArgumentError.value(host.scheme, 'Resource.Notification', 'expected "ws" or "wss" scheme');
    }

    return Uri.parse('${host}/notifications');
  }

  static Uri send(Uri host)
      => Uri.parse('${host}/send');

  static Uri broadcast(Uri host)
      => Uri.parse('${host}/broadcast');
  
  static Uri clientConnections(Uri host)
      => Uri.parse('${host}/connection');
  
  static Uri clientConnection(Uri host, int uid)
      => Uri.parse('${host}/connection/${uid}');
}