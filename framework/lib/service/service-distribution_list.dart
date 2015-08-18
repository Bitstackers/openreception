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
class RESTDistributionListStore implements Storage.DistributionList {
  static final String className = '${libraryName}.RESTDistributionListStore';
  static final Logger log = new Logger(className);

  WebService _backend = null;
  Uri _host;
  String _token = '';

  RESTDistributionListStore(Uri this._host, String this._token, this._backend);

  Future<Model.DistributionList> list(int receptionId, int contactId) {
    Uri url = Resource.DistributionList.ofContact(this._host, receptionId, contactId);
    url = appendToken(url, this._token);

    return this._backend.get(url)
        .then(JSON.decode)
        .then(Model.DistributionList.decode);
  }

  Future<Model.MessageRecipient> addRecipient(int receptionId, int contactId,
      Model.MessageRecipient recipient) {
    Uri url = Resource.DistributionList.ofContact(this._host, receptionId, contactId);
    url = appendToken(url, this._token);

    return this._backend.post(url, JSON.encode(recipient))
        .then(JSON.decode)
        .then(Model.MessageRecipient.decode);
  }

  Future removeRecipient(int entryId) {
    Uri url = Resource.DistributionList.single(this._host, entryId);
    url = appendToken(url, this._token);

    return this._backend.delete(url);
  }
}
