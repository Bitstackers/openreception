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

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class User {

  static const String _user = 'user';
  static const String _group = 'group';
  static const String _identity = 'identity';

  static Uri single(Uri host, int userID)
    => Uri.parse('${root(host)}/${userID}');

  static Uri root(Uri host)
    => Uri.parse('$host/$_user');

  static Uri list(Uri host)
    => Uri.parse('${root(host)}');

  static Uri userGroup(Uri host, int userID)
    => Uri.parse('${single(host, userID)}/$_group');

  static Uri group(Uri host)
    => Uri.parse('$host/$_group');

  static Uri userGroupByID(Uri host, int userID, int groupID)
      => Uri.parse('$host/user/$userID/$_group/$groupID');

  static Uri userIndentities(Uri host, int userID)
  => Uri.parse('$host/$_user/$userID/$_identity');

  static Uri userIndentity(Uri host, int userID, String identity)
  => Uri.parse('$host/$_user/$userID/$_identity/${identity}');

}
