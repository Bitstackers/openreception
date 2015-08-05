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

part of openreception.service;

/**
 * Authentication service client.
 */
class Authentication {
  static final String className = '${libraryName}.Authentication';

  WebService _backend = null;
  Uri _host;
  String _token = '';

  /**
   * Default constructor. Needs a host for backend uri, a user token and a
   * webclient for handling the transport.
   */
  Authentication(Uri this._host, String this._token, this._backend);

  /**
   * Performs a lookup of the user on the notification server from the
   * supplied token.
   */
  Future<Model.User> userOf(String token) {
    Uri uri = Resource.Authentication.tokenToUser(this._host, token);

    return this._backend.get(uri).then(
        (String response) => new Model.User.fromMap(JSON.decode(response)));
  }

  /**
   * Validate [token]. Throws [NotFound] exception if the token is not valid.
   */
  Future validate(String token) {
    Uri uri = Resource.Authentication.validate(this._host, token);

    return this._backend.get(uri);
  }
}
