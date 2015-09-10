part of callflowcontrol.controller;

class State {

  final Logger log = new Logger('${libraryName}.State');

  /**
   * Performs a total reload of state.
   */
  Future<shelf.Response> reloadAll (shelf.Request request) =>
    Future.wait([PBX.loadPeers(), PBX.loadChannels()])
      .then((_) => new shelf.Response.ok('{}'));
}
