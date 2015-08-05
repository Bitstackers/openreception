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
 * Client for configuation service.
 */
class RESTConfiguration {
  static final String className = '${libraryName}.RESTConfiguration';

  WebService _backend = null;
  Uri _host;

  RESTConfiguration(Uri this._host, this._backend);

  /**
   * Returns a [ClientConfiguration] object.
   */
  Future<Model.ClientConfiguration> clientConfig() {
    Uri uri = Resource.Config.get(this._host);

    return this._backend.get(uri).then((String response) =>
        new Model.ClientConfiguration.fromMap(JSON.decode(response)));
  }
}
