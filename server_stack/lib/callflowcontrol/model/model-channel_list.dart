part of callflowcontrol.model;

String channelName(ESL.Channel channel) => channel.fields['Channel-Name'];


bool isInbound (ESL.Channel channel)
  => channel.fields['Call-Direction'] == 'inbound' ? true : false;


bool isInternal (ESL.Channel channel) {
  String cName = channelName (channel);

  if (!cName.startsWith('sofia/')) {
    throw new ArgumentError('only sofia channels are supported. Got: $cName');
  }

  String profile = cName.split('/')[1];

  if (profile == 'internal') {
    return true;
  }
  else if (profile == 'external') {
    return false;
  }

  throw new ArgumentError('Failed to detect profile in channel name \'$cName\'.');
}

String ownedByPeer (ESL.Channel channel) {
  String cName = channelName (channel);

  if (!cName.startsWith('sofia/')) {
    throw new ArgumentError('only sofia channels are supported.');
  }

  return cName.split('/')[2];
}

String channelOwnedByPeer (String channelName) {
  if (!channelName.startsWith('sofia/')) {
    throw new ArgumentError('only sofia channels are supported.');
  }

  return channelName.split('/')[2];
}

String channelUUIDOfPeer (ESL.Channel channel, String peerName) {
  String channelName = channel.fields['Channel-Name'];
  String otherChannelName = channel.fields['Other-Leg-Channel-Name'];

  if (channelOwnedByPeer (channelName) == peerName) {
    return channel.fields['Channel-UUID'];
  } else if (otherChannelName != null)
    if (channelOwnedByPeer (otherChannelName) == peerName) {
      return channel.fields['Other-Leg-Channel-UUID'];
  }

  throw new ArgumentError('Peer $peerName has no relation to Channel $channel');
}

String simplePeerName (String peerName) =>
  peerName.split('@')[0].replaceAll('sip:', '');


class ChannelEventName {
  static const String CREATE  = 'chan_create';
  static const String UPDATE  = 'chan_update';
  static const String DESTROY = 'chan_destroy';
}

abstract class PBXEvent {
  static const String CUSTOM = 'CUSTOM';
  static const String CHANNEL_BRIDGE = 'CHANNEL_BRIDGE';
  static const String CHANNEL_STATE = 'CHANNEL_STATE';
  static const String CHANNEL_CREATE = 'CHANNEL_CREATE';
  static const String CHANNEL_DESTROY = 'CHANNEL_DESTROY';

  static const List<String> requiredSubscriptions = const
      [CUSTOM, CHANNEL_BRIDGE, CHANNEL_CREATE, CHANNEL_DESTROY, CHANNEL_STATE];
}

class ChannelEvent {
  final String      eventName;
  final ESL.Channel channel;

  ChannelEvent (this.eventName, this.channel);

  @override
  String toString () => this.asMap.toString();

  bool   get isExternalChannel => !isInternal(this.channel);

  String get ownerPeer         => simplePeerName (ownedByPeer (this.channel));


  Map get asMap => {
     'eventName' : this.eventName,
     'channelID' : this.channel.UUID,
     'ownerPeer' : this.ownerPeer,
     'external'  : this.isExternalChannel
  };
}


class ChannelList extends ESL.ChannelList {

  static final Logger log       = new Logger('${libraryName}.ChanneList');

  static ChannelList instance = new ChannelList();

  static StreamController<ChannelEvent> _eventController
    = new StreamController<ChannelEvent>.broadcast();

  static Stream<ChannelEvent> event = _eventController.stream;


  /**
   * Determine if a peer has any active channels.
   */
  bool hasActiveChannels (String peerID) =>
      this.any((ESL.Channel channel) => simplePeerName(ownedByPeer(channel)) == peerID);

  /**
   * Determine the number of active channels a peer has.
   */
  int activeChannelCount (String peerID) =>
      this.where((ESL.Channel channel) => simplePeerName(ownedByPeer(channel)) == peerID).length;


  void update (ESL.Channel channel) {
    bool newChannel = false;

    log.finest ('Updating:'
        ' channelName:${channelName (channel)}'
        ' internal:${isInternal (channel)}, '
        ' ownedby :${ownedByPeer (channel)}'
        ' simplePeerName  :${simplePeerName (ownedByPeer (channel))}');

    if (!this.contains(channel)) {
      newChannel = true;
    }

    super.update(channel);

    /// If the UUID has been removed, send remove notification.
    if (!this.contains(channel)) {
      _eventController.add(new ChannelEvent(ChannelEventName.DESTROY, channel));
    }
    else if (newChannel) {
      _eventController.add(new ChannelEvent(ChannelEventName.CREATE, channel));
    } else {
      _eventController.add(new ChannelEvent(ChannelEventName.UPDATE,channel));
    }
    ///FIXME Disabled channel notifications for now. Should probably go into a
    /// Separate websocket stream or be a config option.
    //Notification.broadcast(ClientNotification.channelUpdate (channel));
  }

  void handleEvent(ESL.Event packet) {

    void dispatch() {
      switch (packet.eventName) {

        case (PBXEvent.CHANNEL_BRIDGE):
          this.update(new ESL.Channel.fromPacket(packet));
          break;

        case (PBXEvent.CHANNEL_STATE):
          this.update(new ESL.Channel.fromPacket(packet));
          break;

        case (PBXEvent.CHANNEL_CREATE):
          this.update(new ESL.Channel.fromPacket(packet));
          break;

        case (PBXEvent.CHANNEL_DESTROY):
          this.update(new ESL.Channel.fromPacket(packet));
          break;
      }
    }

    try {
      dispatch();
    } catch (error, stackTrace) {
      log.severe('Failed to dispatch ${packet.eventName}');
      log.severe(error, stackTrace);
    }
  }
}
