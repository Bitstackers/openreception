part of callflowcontrol.router;

void handlerPeerList(HttpRequest request) {

  final String context = '${libraryName}.handlerPeerList';

  writeAndClose(request, JSON.encode({'peers' : Model.PeerList.instance}));
}
