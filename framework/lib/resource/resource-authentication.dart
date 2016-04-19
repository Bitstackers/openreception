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
abstract class Authentication {

  /// The intial component of the Uri.
  static String nameSpace = 'token';

  /**
   * Resource that returns the user currently associated with a token.
   * Has the format http:/<host>/token/<requestedToken>
   */
  static Uri tokenToUser(Uri host, String requestedToken)
    => Uri.parse('${Util.removeTailingSlashes(host)}'
                 '/${nameSpace}'
                 '/${requestedToken}');

  /**
   * Resource that checks if a is user currently associated with a token.
   * Has the format http:/<host>/token/<requestedToken>/validate
   */
  static Uri validate(Uri host, String requestedToken)
    => Uri.parse('${Util.removeTailingSlashes(host)}'
                 '/${nameSpace}'
                 '/${requestedToken}'
                 '/validate');

}

