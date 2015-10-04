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
  static const int    _timeOutSeconds  = 10;
  static const int    _agentChantimeOut= 3;
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
    return apiClient.api(command, timeoutSeconds: 20)
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
    return apiClient.bgapi(command).then((ESL.Reply response) {
      log.finest('bgapi $command => ${response.content}');
      return response;
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

  /**
   * Spawns a channel to an agent.
   *
   * By first dialing the agent, and parking him/her.
   *
   * Returns the UUID of the new channel.
   */
  static Future<String> createAgentChannel (ORModel.User user) =>
    api('create_uuid').then((ESL.Response response) {
      if (response.rawBody.isEmpty || response.status == ESL.Response.ERROR) {
        throw new PBXException(
            'Creation of uuid for uid:${user.ID} failed. '
            'PBX responded: ${response.rawBody}');
      }
      else if (response.rawBody.length != 36) {

      }

      final String new_call_uuid = response.rawBody;
      final String destination = 'user/${user.peer}';

      _log.finest ('New uuid: $new_call_uuid');
      _log.finest ('Dialing receptionist at user/${user.peer}');

      Map variables = {
        'ignore_early_media' : true,
        agentChan : true,
        'park_timeout' : _agentChantimeOut,
        'origination_uuid' : new_call_uuid,
        'originate_timeout' : _agentChantimeOut,
        'origination_caller_id_name' : _callerID,
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
     });


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
   * This method is cleaner than the [originate] method, because this will return the future A-leg as call-id, but
   * will break the protocol as per 2014-06-24.
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

  /**
   * Bridges two active calls.
   */
  static Future bridgeChannel (String uuid, ORModel.Call destination) {

    ESL.Response bridgeResponse;

    return
        api ('uuid_answer ${destination.channel}')
        .then ((_) => api ('uuid_setvar ${destination.channel} hangup_after_bridge true')
          .then((response) => bridgeResponse = response))
        .then ((_) => api ('uuid_setvar ${uuid} hangup_after_bridge true')
          .then((response) => bridgeResponse = response))
        .then ((_) => api ('uuid_bridge ${destination.channel} ${uuid}')
          .then((response) => bridgeResponse = response))
        .then ((_) => api ('uuid_break ${destination.channel}').then((_) => bridgeResponse));
 }

  /**
   * Transfers an active call to a user.
   */
  static Future transfer (ORModel.Call source, String extension) {

    ESL.Response transferResponse;

    return api ('uuid_transfer ${source.channel} ${extension}')
                                .then((response) => transferResponse = response)
        .then ((_) => api ('uuid_break ${source.channel}').then((_) => transferResponse));
  }

  /**
   * Kills the active channel for a call.
   */
  static Future hangup (ORModel.Call call) => killChannel(call.channel);

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
