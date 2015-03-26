part of callflowcontrol.router;

abstract class Channel {

  static void list(HttpRequest request) {
    try {
      List<Map> retval = new List<Map>();
      Model.ChannelList.instance.forEach((channel) {
        retval.add(channel.toMap());
      });

      writeAndClose(request, JSON.encode(retval));
    } catch (error, stacktrace) {
      serverError(request, error.toString());
      logger.error(stacktrace);
    }
  }
}
