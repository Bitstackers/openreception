part of callflowcontrol.model;

class ChannelList extends ESL.ChannelList {

  static const String className = '${libraryName}.ChanneList';

  static ChannelList instance = new ChannelList();

  void update (ESL.Channel channel) {
    super.update(channel);
    Notification.broadcast(ClientNotification.channelUpdate (channel));
  }

  void handleEvent(ESL.Event packet) {
    const String context = '${className}._handleEvent';

    void dispatch() {
      switch (packet.eventName) {

        case ('CHANNEL_BRIDGE'):
          this.update(new ESL.Channel.fromPacket(packet));
          break;

        case ('CHANNEL_STATE'):
          this.update(new ESL.Channel.fromPacket(packet));
          break;

        case ('CHANNEL_CREATE'):
          this.update(new ESL.Channel.fromPacket(packet));
          break;

        case ('CHANNEL_DESTROY'):
          this.update(new ESL.Channel.fromPacket(packet));
          break;
      }
    }

    try {
      dispatch();
    } catch (error, stackTrace) {
      logger.errorContext('$error : $stackTrace', context);
    }
  }
}
