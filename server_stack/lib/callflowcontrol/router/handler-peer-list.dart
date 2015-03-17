part of callflowcontrol.router;

void handlerPeerList(HttpRequest request) {
  List simplePeerList = Model.PeerList.simplify().toList(growable: false);

  writeAndClose(request, JSON.encode(simplePeerList));
}
