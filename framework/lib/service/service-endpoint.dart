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
 * Client for contact service.
 */
class RESTEndpointStore implements Storage.Endpoint {
  static final String className = '${libraryName}.RESTEndpointStore';
  static final Logger log = new Logger(className);

  WebService _backend = null;
  Uri _host;
  String _token = '';

  RESTEndpointStore(Uri this._host, String this._token, this._backend);

  Future<Model.MessageEndpoint> create(int receptionId, int contactId, Model.MessageEndpoint ep) {
    Uri url = Resource.Endpoint.ofContact(this._host, receptionId, contactId);
    url = appendToken(url, this._token);

    return this._backend.post(url, JSON.encode(ep))
        .then(JSON.decode)
        .then(Model.MessageEndpoint.decode);
  }

  Future remove(int endpointId) {
    Uri url = Resource.Endpoint.single(this._host, endpointId);
    url = appendToken(url, this._token);

    return this._backend.delete(url);
  }

  Future<Iterable<Model.MessageEndpoint>> list(int receptionId, int contactId) {
    Uri url = Resource.Endpoint.ofContact(this._host, receptionId, contactId);
    url = appendToken(url, this._token);

    Iterable<Model.MessageEndpoint> castMaps (Iterable maps) =>
        maps.map(Model.MessageEndpoint.decode);

    print(url);

    return this._backend.get(url)
        .then(JSON.decode)
        .then(castMaps);
    }

  Future<Model.MessageEndpoint> update(Model.MessageEndpoint ep) {
    Uri url = Resource.Endpoint.single(this._host, ep.id);
    url = appendToken(url, this._token);

    return this._backend.put(url, JSON.encode(ep))
      .then(JSON.decode)
      .then(Model.MessageEndpoint.decode);

  }

}
