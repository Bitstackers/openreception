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
 * Client for peer account service.
 */
class PeerAccount {
  WebService _backend = null;
  Uri _host;
  String _token = '';

  /**
   *
   */
  PeerAccount(Uri this._host, String this._token, this._backend);

  /**
   *
   */
  Future<Model.PeerAccount> get(String accountName) {
    Uri url = Resource.PeerAccount.single(_host, accountName);
    url = _appendToken(url, _token);

    return _backend.get(url).then(JSON.decode).then(Model.PeerAccount.decode);
  }

  /**
   *
   */
  Future<Iterable<String>> list() {
    Uri url = Resource.PeerAccount.list(_host);
    url = _appendToken(url, _token);

    return _backend
        .get(url)
        .then(JSON.decode)
        .then((Iterable<String> value) => value);
  }

  /**
   * (Re-)deploys a dialplan for a the reception identified by [receptionId]
   */
  Future deployAccount(Model.PeerAccount account, int userId) {
    Uri url = Resource.PeerAccount.deploy(_host, userId);
    url = _appendToken(url, _token);

    return _backend.post(url, JSON.encode(account));
  }

  /**
   *
   */
  Future remove(String username) {
    Uri url = Resource.PeerAccount.single(_host, username);
    url = _appendToken(url, _token);

    return _backend.delete(url);
  }
}
