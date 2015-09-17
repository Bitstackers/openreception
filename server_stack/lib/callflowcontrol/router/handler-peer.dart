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

part of openreception.call_flow_control_server.router;

abstract class Peer {

  static shelf.Response list(shelf.Request request) {
    List simplePeerList = Model.PeerList.simplify().toList(growable: false);

    return new shelf.Response.ok(JSON.encode(simplePeerList));
  }

  static shelf.Response get(shelf.Request request) {
    String peerid = shelf_route.getPathParameter(request, 'peerid');

    return new shelf.Response.ok
      (JSON.encode(new Model.Peer.fromESLPeer(Model.PeerList.get(peerid))));
  }

}
