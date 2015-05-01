part of callflowcontrol.router;

abstract class Peer {

  static shelf.Response list(shelf.Request request) {
    List simplePeerList = Model.PeerList.simplify().toList(growable: false);

    return new shelf.Response.ok(JSON.encode(simplePeerList));
  }
}
