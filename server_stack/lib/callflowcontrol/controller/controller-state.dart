part of callflowcontrol.controller;

class State {

  final Logger log = new Logger('${libraryName}.State');

  /**
   * Performs a total reload of state.
   */
  Future<shelf.Response> reloadAll (shelf.Request request) =>
    Future.wait([PBX.loadPeers(), PBX.loadChannels()])
      .then((_) => Model.CallList.instance.reloadFromChannels(Model.ChannelList.instance))
      .then((_) => new shelf.Response.ok('{}'));
}
