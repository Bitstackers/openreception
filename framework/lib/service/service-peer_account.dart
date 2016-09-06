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

/// Peer account service client class.
///
/// The client class wraps REST methods and handles lower-level
/// communication, such as serialization/deserialization, method choice
/// (GET, PUT, POST, DELETE) and resource uri building./
class PeerAccount {
  final WebService _backend;

  /// The uri of the connected backend.
  final Uri host;

  /// The token used for authenticating with the backed.
  final String token;

  PeerAccount(Uri this.host, String this.token, this._backend);

  Future<model.PeerAccount> get(String accountName) {
    Uri url = resource.PeerAccount.single(host, accountName);
    url = _appendToken(url, token);

    return _backend.get(url).then(JSON.decode).then(model.PeerAccount.decode);
  }

  Future<Iterable<String>> list() {
    Uri url = resource.PeerAccount.list(host);
    url = _appendToken(url, token);

    return _backend
        .get(url)
        .then(JSON.decode)
        .then((Iterable<String> value) => value);
  }

  /// (Re-)deploys a [model.PeerAccount] for user with [uid].
  Future<Iterable<String>> deployAccount(model.PeerAccount account, int uid) {
    Uri url = resource.PeerAccount.deploy(host, uid);
    url = _appendToken(url, token);

    return _backend
        .post(url, JSON.encode(account))
        .then(JSON.decode)
        .then((Iterable<String> value) => value);
  }

  Future remove(String username) {
    Uri url = resource.PeerAccount.single(host, username);
    url = _appendToken(url, token);

    return _backend.delete(url);
  }
}
