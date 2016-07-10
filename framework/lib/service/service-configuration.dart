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

part of openreception.framework.service;

/// Configuration service client class.
///
/// The client class wraps REST methods and handles lower-level
/// communication, such as serialization/deserialization, method choice
/// (GET, PUT, POST, DELETE) and resource uri building.
class RESTConfiguration {
  final WebService _backend;

  /// The uri of the connected backend.
  final Uri host;

  RESTConfiguration(Uri this.host, this._backend);

  /**
   * Returns a [ClientConfiguration] object.
   */
  Future<model.ClientConfiguration> clientConfig() {
    Uri uri = resource.Config.get(this.host);

    return _backend.get(uri).then((String response) =>
        new model.ClientConfiguration.fromMap(JSON.decode(response)));
  }

  /**
   * Registers a server in the config server registry.
   */
  Future register(String type, Uri registerUri) {
    Uri uri = resource.Config.register(this.host);
    final Map body = {'type': type, 'uri': registerUri.toString()};

    return _backend.post(uri, JSON.encode(body));
  }
}
