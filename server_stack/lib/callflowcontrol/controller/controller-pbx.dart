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

part of openreception.server.controller.call_flow;

class PBXException implements Exception {
  final String message;
  const PBXException([this.message = ""]);

  @override
  String toString() => "PBXException: $message";
}

class NoAnswer extends PBXException {
  const NoAnswer([message = ""]);

  @override
  String toString() => "NoAnswer: $message";
}

class CallRejected extends PBXException {
  const CallRejected([message = ""]);

  @override
  String toString() => "CallRejected: $message";
}

abstract class PBX {
  static final Logger _log = new Logger('${libraryName}.PBX');
  static const String _dialplan = 'xml receptions';

  static final Logger log = new Logger('${libraryName}.PBX');

  static ESL.Connection apiClient;
  static ESL.Connection eventClient;

  static Future<ESL.Response> api(String command) async {
    final ESL.Response response =
        await apiClient.api(command, timeoutSeconds: 30);

    final int maxLen = 200;
    final truncated = response.rawBody.length > maxLen
        ? '${response.rawBody.substring(0, maxLen)}...'
        : response.rawBody;

    log.finest('api $command => $truncated');
    return response;
  }

  static Future<ESL.Reply> bgapi(String command, {String jobUuid: ''}) async {
    final ESL.Reply reply = await apiClient.bgapi(command, jobUuid: jobUuid);
    log.finest('bgapi $command => ${reply.content}');
    return reply;
  }

  /**
   * Starts an origination in the PBX.
   *
   * By first dialing the agent and then the outbound extension.
   *
   * Returns the UUID of the call.
   */
  static Future<String> originate(String extension, int contactID,
      int receptionID, ORModel.User user) async {
    /// Tag the A-leg as a primitive origination channel.
    List<String> aLegvariables = ['${ORPbxKey.agentChannel}=true'];

    List<String> bLegvariables = [
      '${ORPbxKey.receptionId}=${receptionID}',
      '${ORPbxKey.userId}=${user.id}',
      '${ORPbxKey.contactId}=${contactID}'
    ];

    final String callerIdName = config.callFlowControl.callerIdName;
    final String callerIdNumber = config.callFlowControl.callerIdNumber;
    final int timeout = config.callFlowControl.originateTimeout;

    ESL.Response response = await api(
        'originate {${aLegvariables.join(',')}}user/${user.extension} '
        '&bridge([${bLegvariables.join(',')}]sofia/external/${extension}) '
        '${_dialplan} $callerIdName $callerIdNumber $timeout');

    if (response.status != ESL.Response.ok) {
      throw new StateError('ESL returned ${response.rawBody}');
    }

    return response.channelUUID;
  }

  static Future _cleanupChannel(String uuid) =>
      killChannel(uuid).catchError((error, stackTrace) =>
          log.severe('Failed to close agent channel', error, stackTrace));

  /**
   * Spawns a channel to an agent.
   *
   * By first dialing the agent, and parking him/her.
   *
   * Returns the UUID of the new channel.
   */
  static Future<String> createAgentChannel(ORModel.User user,
      {Map<String, String> extravars: const {}}) async {
    final int msecs = new DateTime.now().millisecondsSinceEpoch;
    final String newCallUuid = 'agent-${user.id}-${msecs}';
    final String destination = 'user/${user.extension}';

    _log.finest('New uuid: $newCallUuid');
    _log.finest('Dialing receptionist at user/${user.extension}');

    final String callerIdNumber = config.callFlowControl.callerIdNumber;

    Map variables = {
      'ignore_early_media': true,
      ORPbxKey.agentChannel: true,
      'park_timeout': config.callFlowControl.agentChantimeOut,
      'hangup_after_bridge': true,
      'origination_uuid': newCallUuid,
      'originate_timeout': config.callFlowControl.agentChantimeOut,
      'origination_caller_id_name': 'Connecting...',
      'origination_caller_id_number': callerIdNumber
    }..addAll(extravars);

    final String variableString =
        variables.keys.map((String key) => '$key=${variables[key]}').join(',');

    /// Create a subscription
    bool jobUuidMatches(ESL.Event event) =>
        event.eventName == Model.PBXEvent.backgroundJob &&
        event.field('Job-UUID') == newCallUuid;

    final Future<ESL.Event> subscription = eventClient.eventStream
            .firstWhere(jobUuidMatches)
            .timeout(
                new Duration(seconds: config.callFlowControl.agentChantimeOut))
        as Future<ESL.Event>;

    await bgapi('originate {$variableString}${destination} &park()',
        jobUuid: newCallUuid);

    final ESL.Response response = new ESL.Response.fromPacketBody(
        (await subscription).field('_body').trim());

    if (response.status == ESL.Response.ok) {
      return newCallUuid;
    } else {
      _log.warning('Bad reply from PBX: ${response.status}');

      /// Call is rejected by peer
      if (response.rawBody.contains('CALL_REJECTED')) {
        throw new CallRejected('destination: $destination');

        /// Call is not answered by peer.
      } else if (response.rawBody.contains('NO_ANSWER')) {
        throw new NoAnswer('destination: $destination');

        /// Call did not succeed for reasons beyond our comprehension.
      } else {
        throw new PBXException('Creation of agent channel for '
            'uid:${user.id} failed. Destination:$destination. '
            'PBX responded: ${response.rawBody}');
      }
    }
  }

  /**
   * Spawns a channel to an agent.
   *
   * By first dialing the agent, and parking him/her.
   *
   * Returns the UUID of the new channel.
   */
  static Future<String> createAgentChannelBg(ORModel.User user) async {
    final int msecs = new DateTime.now().millisecondsSinceEpoch;
    final String newCallUuid = 'agent-${user.id}-${msecs}';
    final String destination = 'user/${user.extension}';

    _log.finest('New uuid: $newCallUuid');
    _log.finest('Dialing receptionist at user/${user.extension}');

    final String callerIdNumber = config.callFlowControl.callerIdNumber;

    Map variables = {
      'ignore_early_media': true,
      ORPbxKey.agentChannel: true,
      'park_timeout': config.callFlowControl.agentChantimeOut,
      'hangup_after_bridge': true,
      'origination_uuid': newCallUuid,
      'originate_timeout': config.callFlowControl.agentChantimeOut,
      'origination_caller_id_name': 'Connecting...',
      'origination_caller_id_number': callerIdNumber
    };

    String variableString =
        variables.keys.map((String key) => '$key=${variables[key]}').join(',');

    ESL.Reply reply = await bgapi(
        'originate {$variableString}${destination} &park()',
        jobUuid: newCallUuid);

    if (reply.status != ESL.Response.ok) {
      throw new PBXException('Creation of agent channel for '
          'uid:${user.id} failed. Destination:$destination. '
          'PBX responded: ${reply.content}');
    }

    /// Create a subscription that looks for the outbound channel.
    bool outboundCallWithUuid(ESL.Event event) =>
        event.eventName == 'CHANNEL_ORIGINATE' &&
        event.channel.fields['Unique-ID'] == newCallUuid;

    await eventClient.eventStream
        .firstWhere(outboundCallWithUuid, defaultValue: () => null);

    bool inviteClosed(ESL.Event event) =>
        event.channel.fields['Unique-ID'] == newCallUuid &&
        (event.eventName == 'CHANNEL_ANSWER' ||
            event.eventName == 'CHANNEL_HANGUP');

    ESL.Event event;
    try {
      event = await eventClient.eventStream
          .firstWhere(inviteClosed, defaultValue: () => null)
          .timeout(
              new Duration(seconds: config.callFlowControl.agentChantimeOut));
    } on TimeoutException {
      _cleanupChannel(ORPbxKey.agentChannel);

      throw new NoAnswer('destination: $destination');
    }

    if (event.eventName == 'CHANNEL_HANGUP') {
      throw new CallRejected('destination: $destination');
    } else if (event.eventName == 'CHANNEL_ANSWER') {
      return newCallUuid;
    } else {
      throw new PBXException('Creation of agent channel for '
          'uid:${user.id} failed. Destination:$destination. '
          'Got event type: ${event.eventType}');
    }
  }

  static Future transferUUIDToExtension(
      String uuid, String extension, ORModel.User user, String context) async {
    await api('uuid_setvar $uuid effective_caller_id_number ${user.extension}');
    await api('uuid_setvar $uuid effective_caller_id_name ${user.address}');
    final ESL.Reply reply = await bgapi(
        'uuid_transfer $uuid external_transfer_$extension xml reception-$context');

    if (reply.status != ESL.Reply.ok) {
      throw new PBXException(reply.replyRaw);
    }
  }

  /**
   * Starts an origination in the PBX.
   *
   * By first dialing the agent and then the recordingsmenu.
   */
  static Future recordChannel(String uuid, String filename) {
    final String command = 'uuid_record $uuid start $filename';
    return _runAndCheck(command).then((ESL.Response response) => filename);
  }

  /**
   * Starts an origination in the PBX.
   *
   * By first dialing the agent and then the recordingsmenu.
   */
  static Future originateRecording(int receptionID, String recordExtension,
      String soundFilePath, ORModel.User user) {
    List<String> variables = [
      '${ORPbxKey.receptionId}=${receptionID}',
      '${ORPbxKey.userId}=${user.id}',
      'recordpath=${soundFilePath}'
    ];
    final String callerIdName = config.callFlowControl.callerIdName;
    final String callerIdNumber = config.callFlowControl.callerIdNumber;
    final int timeout = config.callFlowControl.originateTimeout;

    final String command =
        'originate {${variables.join(',')}}user/${user.extension} ${recordExtension} ${_dialplan} $callerIdName $callerIdNumber $timeout';
    return api(command).then((ESL.Response response) {
      if (response.status != ESL.Response.ok) {
        throw new StateError('ESL returned ${response.rawBody}');
      }

      return response.channelUUID;
    });
  }

  /**
   * Bridges two active calls.
   */
  static Future bridge(ORModel.Call source, ORModel.Call destination) {
    return api('uuid_bridge ${source.id} ${destination.id}')
        .then((ESL.Response response) {
      if (response.status != ESL.Response.ok) {
        throw new StateError('ESL returned ${response.rawBody}');
      }

      return response;
    });
  }

  /**
   * Writes [msg] to log and throws a [PBXException].
   */
  static void _logAndFail(String msg) {
    log.severe(msg);
    throw new PBXException(msg);
  }

  /**
   * Run a [command] checked. This implies that the return values is checked
   * for errors and throw a [PBXException] if that is the case. The command
   * failure will be logged prior.
   */
  static Future<ESL.Response> _runAndCheck(String command) async {
    ESL.Response response;
    try {
      response = await api(command);
    } catch (error, stackTrace) {
      log.shout('Failed to send command $command', error, stackTrace);
    }

    if (response.status != ESL.Response.ok) {
      _logAndFail('"$command" failed with response ${response.rawBody}');
    }
    return response;
  }

  /**
   *
   */
  static Future pickupCall(String agentChannel, String uuid) =>
      api('uuid_transfer $agentChannel pickup-call-$uuid $_dialplan');

  /**
   * Bridges two active calls.
   */
  static Future bridgeChannel(String uuid, ORModel.Call destination) async {
    await _runAndCheck('uuid_answer ${destination.channel}');

    try {
      await setVariable(uuid, 'hangup_after_bridge', 'true');
    } catch (e) {
      final String msg = 'Failed to set variable on channel';
      log.severe(msg);

      throw new PBXException(msg);
    }

    final bridgeUuid =
        'uuid_transfer $uuid pickup-call-${destination.channel} $_dialplan';
    ESL.Response response = await _runAndCheck(bridgeUuid);

    await api('uuid_break ${destination.channel}');

    return response;
  }

  /**
   * Transfers an active call to a user.
   */
  static Future transfer(ORModel.Call source, String extension) async {
    final command = 'uuid_transfer ${source.channel} ${extension}';

    ESL.Response xfrResponse = await api(command);

    await api('uuid_break ${source.channel}');

    if (xfrResponse.status != ESL.Response.ok) {
      final String msg =
          '"$command" failed with reponse ${xfrResponse.rawBody}';
      log.severe(msg);
      throw new PBXException(msg);
    }

    return xfrResponse;
  }

  /**
   * Check if the agent channel is still active and if it is, kill it.
   */
  static Future _checkAgentChannel(String uuid) =>
      new Future.delayed(new Duration(milliseconds: 100)).then((_) => Model
          .ChannelList.instance
          .containsChannel(uuid) ? _cleanupChannel(uuid) : null);

  /**
   * Kills the active channel for a call.
   */
  static Future hangup(ORModel.Call call) =>
      killChannel(call.channel).then((_) => _checkAgentChannel(call.bLeg));

  /**
   * Kills the active channel for a call.
   */
  static Future killChannel(String uuid) =>
      api('uuid_kill $uuid').then((ESL.Response response) {
        if (response.status != ESL.Response.ok) {
          throw new StateError('ESL returned ${response.rawBody}');
        }
      });

  /**
   * Parks a call in the parking lot for the user.
   * TODO: Log NO_ANSWER events and figure out why they are coming.
   */
  static Future park(ORModel.Call call, ORModel.User user) {
    return transfer(call, 'park XML receptions');
  }

  /**
   * Loads the peer list from an [ESL.Response].
   */
  static void _loadPeerListFromPacket(ESL.Response response) {
    final ESL.PeerList loadedList =
        new ESL.PeerList.fromMultilineBuffer(response.rawBody);

    loadedList.where(Model.peerIsInAcceptedContext).forEach((ESL.Peer eslPeer) {
      final ORModel.Peer peer = new ORModel.Peer(eslPeer.id)
        ..registered = eslPeer.registered;
      Model.peerlist.add(peer);
    });

    _log.info('Loaded ${Model.peerlist.length} of ${loadedList.length} '
        'peers from FreeSWITCH');
  }

  /**
   * Request a reload of peers.
   */
  static Future loadPeers() => api('list_users').then(_loadPeerListFromPacket);

  /**
   * Request a reload of channels
   */
  static Future loadChannels() =>
      api('show channels as json').then(_loadChannelListFromPacket);

  /**
   * Loads the channel list from an [ESL.Response].
   */
  static Future _loadChannelListFromPacket(ESL.Response response) {
    Map responseBody = JSON.decode(response.rawBody);
    Iterable<String> channelUUIDs = responseBody.containsKey('rows')
        ? new List.from(
            JSON.decode(response.rawBody)['rows'].map((Map m) => m['uuid']))
        : [];

    return Future.forEach(channelUUIDs, (String channelUUID) {
      return api('uuid_dump $channelUUID json').then((ESL.Response response) {
        if (response.status != ESL.Response.error) {
          Map<String, dynamic> value =
              JSON.decode(response.rawBody) as Map<String, dynamic>;

          Map<String, String> fields = {};
          Map<String, dynamic> variables = {};

          value.keys.forEach((String key) {
            if (key.startsWith("variable_")) {
              String keyNoPrefix = (key.split("variable_")[1]);
              variables[keyNoPrefix] = value[key];
            }
            fields[key] = value[key];
          });

          Model.ChannelList.instance
              .update(new ESL.Channel.assemble(fields, variables));
        } else {
          _log.info('Skipping channel loading. Reason: ${response.rawBody}');
        }
      });
    }).then((_) {
      _log.info('Loaded information about '
          '${Model.ChannelList.instance.length} active channels into channel list');
    });
  }

  /**
   * Attach a variable to a channel.
   */
  static Future setVariable(String uuid, String identifier, String value) =>
      api('uuid_setvar $uuid $identifier $value');
}
