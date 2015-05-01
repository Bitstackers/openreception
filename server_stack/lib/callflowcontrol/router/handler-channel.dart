part of callflowcontrol.router;

abstract class Channel {

  static shelf.Response list(shelf.Request request) {
    try {
      List<Map> retval = new List<Map>();
      Model.ChannelList.instance.forEach((channel) {
        retval.add(channel.toMap());
      });

      return new shelf.Response.ok(JSON.encode(retval));
    } catch (error, stacktrace) {
      log.severe(error, stacktrace);
      return new shelf.Response.internalServerError
          (body : 'Failed to retrieve channel list');
    }
  }
}
