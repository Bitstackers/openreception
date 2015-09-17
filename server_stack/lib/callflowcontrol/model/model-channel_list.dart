part of callflowcontrol.model;

/**
 * Utility function. Returns the name of the peer owning the channel.
 */
String ownedByPeer (ESL.Channel channel) {

  if (!channel.channelName().startsWith('sofia/')) {
    throw new ArgumentError('only sofia channels are supported.');
  }

  return channel.channelName().split('/')[2];
}

/**
 * Utility function. Returns the name of the peer owning the channel
 * (string representation).
 */
String channelOwnedByPeer (String channelName) {
  if (!channelName.startsWith('sofia/')) {
    throw new ArgumentError('only sofia channels are supported.');
  }

  return channelName.split('/')[2];
}

/**
 * Returns the uuid (either leg) owned by [peerName]. Throws [ArgumentError] if
 * the peer has no relation to the channel.
 */
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

/**
 * Strips the sip: and domain part from a sip contact string.
 */
String simplePeerName (String peerName) =>
  peerName.split('@')[0].replaceAll('sip:', '');

/**
 * Channel event name string constants.
 */
abstract class ChannelEventName {
  static const String CREATE  = 'chan_create';
  static const String UPDATE  = 'chan_update';
  static const String DESTROY = 'chan_destroy';
}

/**
 * Event name constants
 */
abstract class PBXEvent {
  static const String CUSTOM = 'CUSTOM';
  static const String CHANNEL_BRIDGE = 'CHANNEL_BRIDGE';
  static const String CHANNEL_STATE = 'CHANNEL_STATE';
  static const String CHANNEL_CREATE = 'CHANNEL_CREATE';
  static const String CHANNEL_DESTROY = 'CHANNEL_DESTROY';
  static const String CHANNEL_ORIGINATE = 'CHANNEL_ORIGINATE';

  static const String SOFIA_REGISTER = 'sofia::register';
  static const String SOFIA_UNREGISTER = 'sofia::unregister';

  static const String _OR_PRE_QUEUE_ENTER = 'openreception::pre-queue-enter';
  static const String _OR_PRE_QUEUE_LEAVE = 'openreception::pre-queue-leave';

  static const String _OR_WAIT_QUEUE_ENTER = 'openreception::wait-queue-enter';
  static const String _OR_PARKING_LOT_ENTER = 'openreception::parking-lot-enter';
  static const String _OR_PARKING_LOT_LEAVE = 'openreception::parking-lot-leave';

  static const List<String> requiredSubscriptions = const
      [CHANNEL_BRIDGE, CHANNEL_CREATE, CHANNEL_DESTROY, CHANNEL_STATE,
        CHANNEL_ORIGINATE, CUSTOM, SOFIA_REGISTER, SOFIA_UNREGISTER,
        _OR_PARKING_LOT_ENTER, _OR_PARKING_LOT_LEAVE,
        _OR_PRE_QUEUE_ENTER, _OR_PRE_QUEUE_LEAVE, _OR_WAIT_QUEUE_ENTER];
}

/**
 * An event that has preparsed useful information for, for example, use of a
 * call-list event listener.
 */
class ChannelEvent {
  final String      eventName;
  final ESL.Channel channel;

  ChannelEvent (this.eventName, this.channel);

  @override
  String toString () => this.asMap.toString();

  bool   get isExternalChannel => !this.channel.isInternal();

  String get ownerPeer         => simplePeerName (ownedByPeer (this.channel));


  Map get asMap => {
     'eventName' : this.eventName,
     'channelID' : this.channel.UUID,
     'ownerPeer' : this.ownerPeer,
     'external'  : this.isExternalChannel
  };
}

/**
 * The channel list is a replicated view of the channels currently in the PBX.
 * It is maintained in the call-flow-control server to enable detection of
 * duplicate channels for clients.
 */
class ChannelList extends ESL.ChannelList {

  /// Internal logger
  static final Logger _log       = new Logger('${libraryName}.ChanneList');

  /// Singleton instance.
  static ChannelList instance = new ChannelList();

  /// Controller for injecting events into [event] stream.
  static StreamController<ChannelEvent> _eventController
    = new StreamController<ChannelEvent>.broadcast();

  /// Broadcast stream for channel events.
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

  /**
   * Updates, removes or adds a channel, based on the state of [channel].
   */
  void update (ESL.Channel channel) {
    bool newChannel = false;

    _log.finest ('Updating:'
        ' channelName:${channel.channelName ()}'
        ' internal:${channel.isInternal ()}, '
        ' state:${channel.state}, '
        ' callstate:${channel.fields['Answer-State']}, '
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

  /**
   * Handle an incoming [ESL.Event] packet
   */
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
      _log.severe('Failed to dispatch ${packet.eventName}');
      _log.severe(error, stackTrace);
    }
  }
}
