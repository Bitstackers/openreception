part of callflowcontrol.controller;

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

  static final Logger log             = new Logger('${libraryName}.PBX');
  static const String callerID        = '39990141';
  static const int    timeOutSeconds  = 10;
  static const String dialplan        = 'xml receptions';
  static const String originationChan = 'or_origination_channel';

  /**
   * Starts an origination in the PBX.
   *
   * By first dialing the agent and then the outbound extension.
   *
   * Returns the UUID of the call.
   */
  static Future<String> originate (String extension, int contactID, int receptionID, ORModel.User user) {
    /// Tag the A-leg as a primitive origination channel.
    List<String> a_legvariables = ['${originationChan}=true'];

    List<String> b_legvariables = ['reception_id=${receptionID}',
                                   'owner=${user.ID}',
                                   'contact_id=${contactID}'];

    return Model.PBXClient.api
        ('originate {${a_legvariables.join(',')}}user/${user.peer} '
         '&bridge([${b_legvariables.join(',')}]sofia/external/${extension}) '
         '${dialplan} $callerID $callerID $timeOutSeconds')
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
  static Future<String> createAgentChannel (ORModel.User user) {
    return Model.PBXClient.api('create_uuid').then((ESL.Response response) {
      final String new_call_uuid = response.rawBody;
      final String destination = 'user/${user.peer}';

      log.finest ('New uuid: $new_call_uuid');
      log.finest ('Dialing receptionist at user/${user.peer}');

      return Model.PBXClient.api('originate '
                                  '{ignore_early_media=true,'
                                  '${originationChan}=true,'
                                  'origination_uuid=$new_call_uuid,'
                                  'originate_timeout=$timeOutSeconds,'
                                  'origination_caller_id_name=$callerID,'
                                  'origination_caller_id_number=$callerID}'
                                  '${destination}'
                                  ' &park()')
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
           error = new PBXException('Creation of agent channel failed '
               '($destination). PBX responded: ${response.status}');
         }

         log.warning('Bad reply from PBX', error);

         return new Future.error(error);

       });
     });
  }

  static Future transferUUIDToExtension
    (String uuid, String extension, ORModel.User user) {
    return
      Model.PBXClient.api
        ('uuid_setvar $uuid effective_caller_id_number test')
        .then((_) => Model.PBXClient.api
          ('uuid_setvar $uuid effective_caller_id_name testname'))
        .then((_) => Model.PBXClient.bgapi
          ('uuid_transfer $uuid $extension ${dialplan}'))
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

    String command = 'originate {${variables.join(',')}}user/${user.peer} ${recordExtension} ${dialplan} $callerID $callerID $timeOutSeconds';
    return Model.PBXClient.api(command)
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
                              'origination_caller_id_name=$callerID',
                              'origination_caller_id_number=$callerID',
                              'originate_timeout=$timeOutSeconds',
                              'return_ring_ready=true'];

    return Model.PBXClient.api
        ('originate {${variables.join(',')}}sofia/external/${extension}@${config.dialoutgateway} &bridge(user/${user.peer}) ${dialplan} $callerID $callerID $timeOutSeconds')
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
    return Model.PBXClient.api ('uuid_bridge ${source.ID} ${destination.ID}')
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
        Model.PBXClient.api ('uuid_answer ${destination.channel}')
        .then ((_) => Model.PBXClient.api ('uuid_setvar ${destination.channel} hangup_after_bridge true')
          .then((response) => bridgeResponse = response))
        .then ((_) => Model.PBXClient.api ('uuid_setvar ${uuid} hangup_after_bridge true')
          .then((response) => bridgeResponse = response))
        .then ((_) => Model.PBXClient.api ('uuid_bridge ${destination.channel} ${uuid}')
          .then((response) => bridgeResponse = response))
        .then ((_) => Model.PBXClient.api ('uuid_break ${destination.channel}').then((_) => bridgeResponse));
 }

  /**
   * Transfers an active call to a user.
   */
  static Future transfer (ORModel.Call source, String extension) {

    ESL.Response transferResponse;

    return Model.PBXClient.api ('uuid_transfer ${source.channel} ${extension}')
                                .then((response) => transferResponse = response)
        .then ((_) => Model.PBXClient.api ('uuid_break ${source.channel}').then((_) => transferResponse));
  }

  /**
   * Kills the active channel for a call.
   */
  static Future hangup (ORModel.Call call) {
    return Model.PBXClient.api('uuid_kill ${call.channel}')
        .then((ESL.Response response) {
          if (response.status != ESL.Response.OK) {
            throw new StateError('ESL returned ${response.rawBody}');
          }
        });
  }

  /**
   * Kills the active channel for a call.
   */
  static Future hangupCommand (ESL.Peer peer) {
/*    if (Conf.config.phoneType != Conf.PhoneType.SNOM) {
      return new Future.error(new StateError ("Sending hangup commands is only supported for SNOM phones."));
    }
*/
    return Model.PBXClient.api('snom_command */${peer.ID} key cancel')
        .then((ESL.Response response) {
          if (response.status != ESL.Response.OK) {
            throw new StateError('ESL returned ${response.rawBody}');
          }
        });
  }

  /**
   * Parks a call in the parking lot for the user.
   * TODO: Log NO_ANSWER events and figure out why they are coming.
   */
  static Future park (ORModel.Call call, ORModel.User user) {
    return transfer(call, 'park');
  }
}
