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

part of openreception.framework.resource;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class PeerAccount {
  static Uri list(Uri host) => Uri.parse('$host/peeraccount');

  static Uri single(Uri host, String accountName) =>
      Uri.parse('$host/peeraccount/$accountName');

  static Uri deploy(Uri host, int uid) =>
      Uri.parse('$host/peeraccount/user/$uid/deploy');
}
