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

part of orf.service;

/// Authentication service client.
///
/// The client class wraps REST methods and handles lower-level
/// communication, such as serialization/deserialization, method choice
/// (GET, PUT, POST, DELETE) and resource uri building.
class Authentication {
  final WebService _httpClient;

  /// The uri of the connected backend.
  final Uri host;

  /// The token used for authenticating with the backed.
  final String token;

  /// Default constructor. Needs a [host] for backend uri, a user [token]
  /// and a [WebService] HTTP client for handling the transport.
  Authentication(Uri this.host, String this.token, this._httpClient);

  /// Performs a lookup of the user on the notification server from the
  /// supplied [token].
  Future<model.User> userOf(String token) {
    Uri uri = resource.Authentication.tokenToUser(this.host, token);

    return this._httpClient.get(uri).then((String response) =>
        new model.User.fromMap(JSON.decode(response) as Map<String, dynamic>));
  }

  /// Validate [token]. Throws [NotFound] exception if the token is not
  /// valid.
  Future<Null> validate(String token) async {
    Uri uri = resource.Authentication.validate(this.host, token);

    await _httpClient.get(uri);
  }
}
