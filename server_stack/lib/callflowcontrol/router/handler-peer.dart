part of callflowcontrol.router;

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
