/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.call_flow_control_server.model;

/**
 * Utility function. Returns the name of the peer owning the channel.
 */
String ownedByPeer(ESL.Channel channel) {
  if (!channel.channelName().startsWith('sofia/')) {
    throw new ArgumentError('only sofia channels are supported.');
  }

  return channel.channelName().split('/')[2];
}

/**
 * Utility function. Returns the name of the peer owning the channel
 * (string representation).
 */
String channelOwnedByPeer(String channelName) {
  if (!channelName.startsWith('sofia/')) {
    throw new ArgumentError('only sofia channels are supported.');
  }

  return channelName.split('/')[2];
}

/**
 * Returns the uuid (either leg) owned by [peerName]. Throws [ArgumentError] if
 * the peer has no relation to the channel.
 */
String channelUUIDOfPeer(ESL.Channel channel, String peerName) {
  String channelName = channel.fields['Channel-Name'];
  String otherChannelName = channel.fields['Other-Leg-Channel-Name'];

  if (channelOwnedByPeer(channelName) == peerName) {
    return channel.fields['Channel-UUID'];
  } else if (otherChannelName !=
      null) if (channelOwnedByPeer(otherChannelName) == peerName) {
    return channel.fields['Other-Leg-Channel-UUID'];
  }

  throw new ArgumentError('Peer $peerName has no relation to Channel $channel');
}

/**
 * Strips the sip: and domain part from a sip contact string.
 */
String simplePeerName(String peerName) =>
    peerName.split('@')[0].replaceAll('sip:', '');

/**
 * Channel event name string constants.
 */
abstract class ChannelEventName {
  static const String create = 'chan_create';
  static const String update = 'chan_update';
  static const String destroy = 'chan_destroy';
}

/**
 * Event name constants
 */
abstract class PBXEvent {
  static const String backgroundJob = 'BACKGROUND_JOB';
  static const String custom = 'CUSTOM';
  static const String channelAnswer = 'CHANNEL_ANSWER';
  static const String channelBridge = 'CHANNEL_BRIDGE';
  static const String channelState = 'CHANNEL_STATE';
  static const String channelCreate = 'CHANNEL_CREATE';
  static const String channelDestroy = 'CHANNEL_DESTROY';
  static const String channelOriginate = 'CHANNEL_ORIGINATE';
  static const String recordStart = 'RECORD_START';
  static const String recordStop = 'RECORD_STOP';

  static const String sofiaRegister = 'sofia::register';
  static const String sofiaUnregister = 'sofia::unregister';

  static const List<String> requiredSubscriptions = const [
    channelBridge,
    channelCreate,
    channelDestroy,
    channelState,
    channelOriginate,
    channelAnswer,
    recordStart,
    recordStop,
    backgroundJob,

    /// Custom needs to be at the end of the list of super-events,
    /// but before sub-events.
    custom,
    sofiaRegister,
    sofiaUnregister,
    ORPbxKey.ringingStart,
    ORPbxKey.ringingStop,
    ORPbxKey.parkingLotEnter,
    ORPbxKey.parkingLotLeave,
    ORPbxKey.callNotify,
    ORPbxKey.waitQueueEnter,
    ORPbxKey.callLock,
    ORPbxKey.callUnlock
  ];
}

/**
 * An event that has preparsed useful information for, for example, use of a
 * call-list event listener.
 */
class ChannelEvent {
  final String eventName;
  final ESL.Channel channel;

  ChannelEvent(this.eventName, this.channel);

  @override
  String toString() => this.asMap.toString();

  bool get isExternalChannel => !this.channel.isInternal();

  String get ownerPeer => simplePeerName(ownedByPeer(this.channel));

  Map get asMap => {
        'eventName': this.eventName,
        'channelID': this.channel.uuid,
        'ownerPeer': this.ownerPeer,
        'external': this.isExternalChannel
      };
}

/**
 * The channel list is a replicated view of the channels currently in the PBX.
 * It is maintained in the call-flow-control server to enable detection of
 * duplicate channels for clients.
 */
class ChannelList extends ESL.ChannelList {
  /// Internal logger
  static final Logger _log = new Logger('${libraryName}.ChanneList');

  /// Singleton instance.
  static ChannelList instance = new ChannelList();

  /// Controller for injecting events into [event] stream.
  static StreamController<ChannelEvent> _eventController =
      new StreamController<ChannelEvent>.broadcast();

  /// Broadcast stream for channel events.
  static Stream<ChannelEvent> event = _eventController.stream;

  /**
   *
   */
  bool containsChannel(String uuid) => get(uuid) != null;

  /**
   * Determine if a peer has any active channels.
   */
  bool hasActiveChannels(String peerID) => this.any(
      (ESL.Channel channel) => simplePeerName(ownedByPeer(channel)) == peerID);

  /**
   * Determine the number of active channels a peer has.
   */
  int activeChannelCount(String peerID) => this
      .where((ESL.Channel channel) =>
          simplePeerName(ownedByPeer(channel)) == peerID)
      .length;

  /**
   * Updates, removes or adds a channel, based on the state of [channel].
   */
  void update(ESL.Channel channel) {
    bool newChannel = false;

    _log.finest('Updating:'
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
      _eventController.add(new ChannelEvent(ChannelEventName.destroy, channel));
    } else if (newChannel) {
      _eventController.add(new ChannelEvent(ChannelEventName.create, channel));
    } else {
      _eventController.add(new ChannelEvent(ChannelEventName.update, channel));
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
        case (PBXEvent.channelBridge):
        case (PBXEvent.channelState):
        case (PBXEvent.channelAnswer):
        case (PBXEvent.channelCreate):
        case (PBXEvent.channelDestroy):
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
