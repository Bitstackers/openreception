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

part of ors.model;

/// Utility function that extracts and returns the name of the peer owning
/// the [channel].
///
/// Only "sofia" channels are supported at the moment and other any channel
/// types will throw an [ArgumentError].
String ownedByPeer(esl.Channel channel) {
  if (!channel.channelName().startsWith('sofia/')) {
    throw new ArgumentError('only sofia channels are supported.');
  }

  return channel.channelName().split('/')[2];
}

/// Utility function that extracts and returns the name of the peer
/// owning the channel with [channelName].
///
/// The peer name is returned as a String.
/// Only "sofia" channels are supported at the moment and other any channel
/// types will throw an [ArgumentError].
String channelOwnedByPeer(String channelName) {
  if (!channelName.startsWith('sofia/')) {
    throw new ArgumentError('only sofia channels are supported.');
  }

  return channelName.split('/')[2];
}

// /Returns the uuid (either leg) owned by [peerName].
///
/// Throws [ArgumentError] if he peer has no relation to the channel.
String channelUUIDOfPeer(esl.Channel channel, String peerName) {
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

/// Strips the sip: and domain part from a sip contact string.
String simplePeerName(String peerName) =>
    peerName.split('@')[0].replaceAll('sip:', '');

/// Channel event name string constants.
abstract class ChannelEventName {
  /// Channel create.
  static const String create = 'chan_create';

  /// Channel update.
  static const String update = 'chan_update';

  /// Channel destroy.
  static const String destroy = 'chan_destroy';
}

///Event name constants
abstract class PBXEvent {
  static const String backgroundJob = esl_const.EventType.backgroundJob;
  static const String custom = esl_const.EventType.custom;
  static const String channelAnswer = esl_const.EventType.channelAnswer;
  static const String channelBridge = esl_const.EventType.channelBridge;
  static const String channelState = esl_const.EventType.channelState;
  static const String channelCreate = esl_const.EventType.channelCreate;
  static const String channelDestroy = esl_const.EventType.channelDestroy;
  static const String channelOriginate = esl_const.EventType.channelOriginate;
  static const String recordStart = esl_const.EventType.recordStart;
  static const String recordStop = esl_const.EventType.recordStop;

  static const String sofiaRegister = 'sofia::register';
  static const String sofiaUnregister = 'sofia::unregister';

  /// Subscriptions required by the call-flow-control service to be able
  /// to function.
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

/// An event that has preparsed useful information for, for example, use of
/// a call-list event listener.
class ChannelEvent {
  final String eventName;
  final esl.Channel channel;

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

/// The channel list is a replicated view of the channels currently in the
/// PBX.
///
/// It is maintained in the call-flow-control server primarily to enable
/// detection of duplicate channels for clients.
class ChannelList extends esl.ChannelList {
  /// Internal logger
  static final Logger _log = new Logger('ors.model.ChanneList');

  /// Controller for injecting events into [event] stream.
  static StreamController<ChannelEvent> _eventController =
      new StreamController<ChannelEvent>.broadcast();

  /// Broadcast stream for channel events.
  static Stream<ChannelEvent> event = _eventController.stream;

  /// Returns true if channel with [uuid] is in the channel list
  bool containsChannel(String uuid) => get(uuid) != null;

  /// Determine if the peer with [peerId] has any active channels.
  bool hasActiveChannels(String peerId) => this.any(
      (esl.Channel channel) => simplePeerName(ownedByPeer(channel)) == peerId);

  /// Determine the number of active channels the peer with [peerId] has.
  int activeChannelCount(String peerID) => this
      .where((esl.Channel channel) =>
          simplePeerName(ownedByPeer(channel)) == peerID)
      .length;

  /// Updates, removes or adds a channel, based on the state of [channel].
  void update(esl.Channel channel) {
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

    // If the UUID has been removed, send remove notification.
    if (!this.contains(channel)) {
      _eventController.add(new ChannelEvent(ChannelEventName.destroy, channel));
    } else if (newChannel) {
      _eventController.add(new ChannelEvent(ChannelEventName.create, channel));
    } else {
      _eventController.add(new ChannelEvent(ChannelEventName.update, channel));
    }

    // NOTE: Disabled channel notifications for now (it is the last
    // statement in this comment block).
    //
    // These notifications should probably go into a eparate websocket
    // stream or be a config option as they are only really useful for
    // websocket client for debugging purposes.
    //
    // Notification.broadcast(ClientNotification.channelUpdate (channel));
  }

  /// Handle an incoming [esl.Event] packet and update the channel list
  /// accordingly.
  void handleEvent(esl.Event event) {
    void dispatch() {
      switch (event.eventName) {
        case (PBXEvent.channelBridge):
        case (PBXEvent.channelState):
        case (PBXEvent.channelAnswer):
        case (PBXEvent.channelCreate):
        case (PBXEvent.channelDestroy):
          this.update(new esl.Channel.fromEvent(event));
          break;
      }
    }

    try {
      dispatch();
    } catch (error, stackTrace) {
      _log.severe('Failed to dispatch ${event.eventName}');
      _log.severe(error, stackTrace);
    }
  }
}
