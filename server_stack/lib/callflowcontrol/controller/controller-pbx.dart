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

part of openreception.call_flow_control_server.controller;

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

  static final Logger _log             = new Logger('${libraryName}.PBX');
  static const String _callerID        = '39990141';
  static const int    _timeOutSeconds  = 20;
  static const int    _agentChantimeOut= 20;
  static const String _dialplan        = 'xml receptions';

  static const String _namespace = 'openreception::';
  static const String agentChan = '${_namespace}agent_chan';
  static const String ownerUid = '${_namespace}owner_uid';
  static const String locked = '${_namespace}locked';
  static const String greetingPlayed = '${_namespace}greeting-played';

  static final Logger log = new Logger ('${libraryName}.PBX');

  static ESL.Connection apiClient;
  static ESL.Connection eventClient;

  static Future<ESL.Response> api (String command) {
    return apiClient.api(command, timeoutSeconds: 30)
        .then((ESL.Response response) {

      final int maxLen = 200;
      final truncated = response.rawBody.length > maxLen
          ?'${response.rawBody.substring(0, maxLen)}...'
          : response.rawBody;

      log.finest('api $command => $truncated');
      return response;
    });
  }

  static Future<ESL.Reply> bgapi (String command) {
    return apiClient.bgapi(command).then((ESL.Reply reply) {
      log.finest('bgapi $command => ${reply.content}');
      return reply;
    });
  }
  /**
   * Starts an origination in the PBX.
   *
   * By first dialing the agent and then the outbound extension.
   *
   * Returns the UUID of the call.
   */
  static Future<String> originate (String extension, int contactID, int receptionID, ORModel.User user) {
    /// Tag the A-leg as a primitive origination channel.
    List<String> a_legvariables = ['${agentChan}=true'];

    List<String> b_legvariables = ['reception_id=${receptionID}',
                                   'owner=${user.ID}',
                                   'contact_id=${contactID}'];

    return api
        ('originate {${a_legvariables.join(',')}}user/${user.peer} '
         '&bridge([${b_legvariables.join(',')}]sofia/external/${extension}) '
         '${_dialplan} $_callerID $_callerID $_timeOutSeconds')
        .then((ESL.Response response) {
          if (response.status != ESL.Response.OK) {
            throw new StateError('ESL returned ${response.rawBody}');
          }

          return response.channelUUID;
        });
  }

  static Future _cleanupChannel (String uuid) =>
    killChannel(uuid)
      .catchError((error, stackTrace) =>
        log.severe('Failed to close agent channel', error, stackTrace));


  /**
   * Spawns a channel to an agent.
   *
   * By first dialing the agent, and parking him/her.
   *
   * Returns the UUID of the new channel.
   */
  static Future<String> createAgentChannel (ORModel.User user) {
    final int msecs = new DateTime.now().millisecondsSinceEpoch;
    final String new_call_uuid = 'agent-${user.ID}-${msecs}';
    final String destination = 'user/${user.peer}';

    _log.finest ('New uuid: $new_call_uuid');
    _log.finest ('Dialing receptionist at user/${user.peer}');

    Map variables = {
      'ignore_early_media' : true,
      agentChan : true,
      'park_timeout' : _agentChantimeOut,
      'hangup_after_bridge' : true,
      'origination_uuid' : new_call_uuid,
      'originate_timeout' : _agentChantimeOut,
      'origination_caller_id_name' : 'Connecting...',
      'origination_caller_id_number' : _callerID};

    String variableString = variables.keys.map((String key) =>
        '$key=${variables[key]}').join(',');

    return api('originate {$variableString}${destination} &park()')
     .then((ESL.Response response) {
       var error;

       if (response.status == ESL.Response.OK) {
         return new_call_uuid;
       }

       else if (response.rawBody.contains('CALL_REJECTED')) {
         error = new CallRejected('destination: $destination');
       }

       else if (response.rawBody.contains('NO_ANSWER')) {
         error = new NoAnswer('destination: $destination');
       }

       else {
         error = new PBXException('Creation of agent channel for '
             'uid:${user.ID} failed. Destination:$destination. '
             'PBX responded: ${response.rawBody}');
       }

       _log.warning('Bad reply from PBX', error);

       return new Future.error(error);

     });
   }

  /**
   * Spawns a channel to an agent.
   *
   * By first dialing the agent, and parking him/her.
   *
   * Returns the UUID of the new channel.
   */
  static Future<String> createAgentChannelBg (ORModel.User user) async {

    final int msecs = new DateTime.now().millisecondsSinceEpoch;
    final String new_call_uuid = 'agent-${user.ID}-${msecs}';
    final String destination = 'user/${user.peer}';

    _log.finest ('New uuid: $new_call_uuid');
    _log.finest ('Dialing receptionist at user/${user.peer}');

    Map variables = {
      'ignore_early_media' : true,
      agentChan : true,
      'park_timeout' : _agentChantimeOut,
      'hangup_after_bridge' : true,
      'origination_uuid' : new_call_uuid,
      'originate_timeout' : _agentChantimeOut,
      'origination_caller_id_name' : 'Connecting...',
      'origination_caller_id_number' : _callerID};

    String variableString = variables.keys.map((String key) =>
        '$key=${variables[key]}').join(',');

    ESL.Reply reply =
        await bgapi('originate {$variableString}${destination} &park()');

     if (reply.status != ESL.Response.OK) {
       throw new PBXException('Creation of agent channel for '
                    'uid:${user.ID} failed. Destination:$destination. '
                    'PBX responded: ${reply.content}');
     }

     /// Create a subscription that looks for the outbound channel.
     bool outboundCallWithUuid (ESL.Event event) =>
         event.eventName == 'CHANNEL_ORIGINATE' &&
         event.channel.fields['Unique-ID'] == new_call_uuid;

     await eventClient.eventStream.firstWhere
         (outboundCallWithUuid, defaultValue : () => null);

     bool inviteClosed (ESL.Event event) =>
         event.channel.fields['Unique-ID'] == new_call_uuid
         && (event.eventName == 'CHANNEL_ANSWER' ||
         event.eventName == 'CHANNEL_HANGUP');

     ESL.Event event;
     try {
      event = await eventClient.eventStream.firstWhere
        (inviteClosed, defaultValue : () => null)
        .timeout(new Duration (seconds : _agentChantimeOut));
     }
     on TimeoutException {
       _cleanupChannel(agentChan);

       throw new NoAnswer('destination: $destination');
     }

     if (event.eventName == 'CHANNEL_HANGUP') {
       throw new CallRejected('destination: $destination');
     }
     else if (event.eventName == 'CHANNEL_ANSWER') {
       return new_call_uuid;
     }
     else {
       throw new PBXException('Creation of agent channel for '
           'uid:${user.ID} failed. Destination:$destination. '
           'Got event type: ${event.eventType}');

     }
  }

  static Future transferUUIDToExtension
    (String uuid, String extension, ORModel.User user) {
    return
      api
        ('uuid_setvar $uuid effective_caller_id_number ${user.peer}')
        .then((_) => api
          ('uuid_setvar $uuid effective_caller_id_name ${user.name}'))
        .then((_) => bgapi
          ('uuid_transfer $uuid $extension ${_dialplan}'))
        .then((ESL.Reply reply) =>
            reply.status != ESL.Reply.OK
              ? new Future.error(new PBXException(reply.replyRaw))
              : null);
  }

  /**
   * Starts an origination in the PBX.
   *
   * By first dialing the agent and then the recordingsmenu.
   */
  static Future originateRecording (int receptionID, String recordExtension, String soundFilePath, ORModel.User user) {
    List<String> variables = ['reception_id=${receptionID}',
                              'owner=${user.ID}',
                              'recordpath=${soundFilePath}'];

    String command = 'originate {${variables.join(',')}}user/${user.peer} ${recordExtension} ${_dialplan} $_callerID $_callerID $_timeOutSeconds';
    return api(command)
        .then((ESL.Response response) {
          if (response.status != ESL.Response.OK) {
            throw new StateError('ESL returned ${response.rawBody}');
          }

          return response.channelUUID;
        });
  }

  /**
   * Starts an origination in the PBX.
   *
   * By first dialing the outbound extension and then the agent.
   * This method is cleaner than the [originate] method, because this will
   * return the future A-leg as call-id, but will break the protocol as
   * per 2014-06-24.
   *
   * Currently unused.
   */
  static Future<String> originateOutboundFirst (String extension, int contactID, int receptionID, ORModel.User user) {
    List<String> variables = ['reception_id=${receptionID}',
                              'owner=${user.ID}',
                              'contact_id=${contactID}',
                              'origination_caller_id_name=$_callerID',
                              'origination_caller_id_number=$_callerID',
                              'originate_timeout=$_timeOutSeconds',
                              'return_ring_ready=true'];

    return api
        ('originate {${variables.join(',')}}sofia/external/${extension}@${config.callFlowControl.dialoutGateway} &bridge(user/${user.peer}) ${_dialplan} $_callerID $_callerID $_timeOutSeconds')
        .then((ESL.Response response) {
          if (response.status != ESL.Response.OK) {
            throw new StateError('ESL returned ${response.rawBody}');
          }

          return response.channelUUID;
        });
    //Alternate origination:: originate sofia/gateway/fonet-77344600-outbound/40966024 &bridge(user/1002)
  }

  /**
   * Bridges two active calls.
   */
  static Future bridge (ORModel.Call source, ORModel.Call destination) {
    return api ('uuid_bridge ${source.ID} ${destination.ID}')
        .then((ESL.Response response) {

          if (response.status != ESL.Response.OK) {
            throw new StateError('ESL returned ${response.rawBody}');
          }

          return response;
        });
  }

  static void _logAndFail(String msg) {
    log.severe(msg);
    throw new PBXException (msg);
  }

  static Future<ESL.Response> _runAndCheck(String command) =>
    api (command).then((response) =>
      response.status != ESL.Response.OK
        ? _logAndFail('"$command" failed with response ${response.rawBody}')
        : response);


  /**
   * Bridges two active calls.
   */
  static Future bridgeChannel (String uuid, ORModel.Call destination) async {

    await _runAndCheck ('uuid_answer ${destination.channel}');

    try {
      await setVariable(uuid, 'hangup_after_bridge', 'true');
    } catch (e) {
      final String msg = 'Failed to set variable on channel';
      log.severe(msg);

      throw new PBXException(msg);
    }

    final bridgeUuid = 'uuid_bridge ${destination.channel} ${uuid}';
    ESL.Response response = await _runAndCheck (bridgeUuid);

    await api ('uuid_break ${destination.channel}');

    return response;
 }

  /**
   * Transfers an active call to a user.
   */
  static Future transfer (ORModel.Call source, String extension) async {
    final command = 'uuid_transfer ${source.channel} ${extension}';

    ESL.Response xfrResponse = await api (command);

    await api ('uuid_break ${source.channel}');

    if(xfrResponse.status != ESL.Response.OK) {
      final String msg = '"$command" failed with reponse ${xfrResponse.rawBody}';
      log.severe(msg);
      throw new PBXException (msg);
    }

    return xfrResponse;
  }

  /**
   * Check if the agent channel is still active and if it is, kill it.
   */
  static Future _checkAgentChannel(String uuid) =>
    new Future.delayed(new Duration (milliseconds : 100))
      .then((_) =>
        Model.ChannelList.instance.containsChannel(uuid)
        ? _cleanupChannel(uuid)
        : null);


  /**
   * Kills the active channel for a call.
   */
  static Future hangup (ORModel.Call call) => killChannel(call.channel)
    .then((_) => _checkAgentChannel(call.b_Leg));

  /**
   * Kills the active channel for a call.
   */
  static Future killChannel (String uuid) =>
    api('uuid_kill $uuid')
        .then((ESL.Response response) {
          if (response.status != ESL.Response.OK) {
            throw new StateError('ESL returned ${response.rawBody}');
          }
    });

  /**
   * Parks a call in the parking lot for the user.
   * TODO: Log NO_ANSWER events and figure out why they are coming.
   */
  static Future park (ORModel.Call call, ORModel.User user) {
    return transfer(call, 'park');
  }

  /**
   * Loads the peer list from an [ESL.Response].
   */
  static void _loadPeerListFromPacket (ESL.Response response) {

    bool peerIsInAcceptedContext(ESL.Peer peer) =>
      config.callFlowControl.peerContexts.contains(peer.context);

    ESL.PeerList loadedList = new ESL.PeerList.fromMultilineBuffer(response.rawBody);

    loadedList.where(peerIsInAcceptedContext).forEach((ESL.Peer peer) {
      Model.PeerList.instance.add(peer);
    });

    _log.info('Loaded ${Model.PeerList.instance.length} of ${loadedList.length} '
             'peers from FreeSWITCH');
  }

  /**
   * Request a reload of peers.
   */
  static Future loadPeers () => api('list_users')
    .then(_loadPeerListFromPacket);

  /**
   * Request a reload of channels
   */
  static Future loadChannels() => api('show channels as json')
      .then(_loadChannelListFromPacket);

  /**
   * Loads the channel list from an [ESL.Response].
   */
  static Future _loadChannelListFromPacket (ESL.Response response) {
    Map responseBody = JSON.decode(response.rawBody);
    Iterable<String> channelUUIDs =
        responseBody.containsKey('rows')
        ? JSON.decode(response.rawBody)['rows'].map((Map m) => m['uuid'])
        : [];

    return Future.forEach(channelUUIDs, (String channelUUID) {
      return api('uuid_dump $channelUUID json')
          .then((ESL.Response response) {
        if(response.status != ESL.Response.ERROR) {
          Map<String, dynamic> value = JSON.decode(response.rawBody);

          Map<String, String> fields= {};
          Map<String, dynamic> variables= {};

          value.keys.forEach((String key) {
              if (key.startsWith("variable_")) {

                String keyNoPrefix = (key.split("variable_")[1]);
                variables[keyNoPrefix] = value[key];
              }
              fields[key] = value[key];
          });

          Model.ChannelList.instance.update
            (new ESL.Channel.assemble(fields, variables));

        } else {
          _log.info('Skipping channel loading. Reason: ${response.rawBody}');
        }
      });

    })
    .then((_) {
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
