part of callflowcontrol.router;

void handlerChannelList(HttpRequest request) {

  try {
    List<Map> retval = new List<Map>();
    Model.ChannelList.instance.forEach ((channel) {
      retval.add(channel.toMap());
    });

    writeAndClose(request, JSON.encode( { "channels" : retval}));
  } catch (error, stacktrace) {
    serverError(request, error.toString());
    logger.error(stacktrace);
  }

}
