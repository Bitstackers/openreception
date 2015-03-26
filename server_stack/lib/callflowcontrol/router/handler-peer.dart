part of callflowcontrol.router;

abstract class Peer {
  static void list(HttpRequest request) {
    List simplePeerList = Model.PeerList.simplify().toList(growable: false);

    writeAndClose(request, JSON.encode(simplePeerList));
  }
}
