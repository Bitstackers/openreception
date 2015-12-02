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
 *
 */
class RESTCDRService implements Storage.CDR {
  static final String className = '${libraryName}.RESTCDRStore';

  WebService _backend = null;
  Uri _host;
  String _token = '';

  RESTCDRService(Uri this._host, String this._token, this._backend);

  /**
   *
   */
  Future<Iterable<Model.CDREntry>> listEntries(DateTime from, DateTime to) {
    String fromParameter =
        'date_from=${(from.millisecondsSinceEpoch)}';
    String toParameter = 'date_to=${(to.millisecondsSinceEpoch)}';

    Uri url = Resource.CDR.list(this._host, fromParameter, toParameter);
    url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) {
      Iterable decodedData = JSON.decode(response)['cdr_stats'];

      return decodedData.map((r) => new Model.CDREntry.fromJson(r));
    });
  }

  /**
   *
   */
  Future<Iterable<Model.CDRCheckpoint>> checkpoints() {
    Uri url = Resource.CDR.checkpoint(this._host);
    url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) {
      Iterable decodedData = JSON.decode(response)['checkpoints'];

      return decodedData.map((r) => new Model.CDRCheckpoint.fromMap(r));
    });
  }

  /**
   *
   */

  Future<Model.CDRCheckpoint> createCheckpoint(Model.CDRCheckpoint checkpoint) {
    Uri url = Resource.CDR.checkpoint(this._host);
    url = appendToken(url, this._token);

    return this._backend.post(url, JSON.encode(checkpoint))
      .then((String response) =>
        new Model.CDRCheckpoint.fromMap(JSON.decode(response)));
  }
}
