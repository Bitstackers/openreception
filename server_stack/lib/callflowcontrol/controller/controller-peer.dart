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

part of openreception.server.controller.call_flow;

class Peer {
  final Model.PeerList _peerlist;

  Peer(this._peerlist);

  shelf.Response list(shelf.Request request) =>
      new shelf.Response.ok(JSON.encode(_peerlist));

  shelf.Response get(shelf.Request request) {
    final String peerName = shelf_route.getPathParameter(request, 'peerid');
    ORModel.Peer peer;

    try {
      peer = _peerlist.get(peerName);
    } on NotFound {
      return new shelf.Response.notFound('No peer with name $peerName');
    }

    return new shelf.Response.ok(JSON.encode(peer));
  }
}
