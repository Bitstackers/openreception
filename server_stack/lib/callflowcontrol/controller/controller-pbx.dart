part of callflowcontrol.controller;

abstract class PBX {

  static const String className       = '${libraryName}.PBX';
  static const String callerID        = '39990141';
  static const int    timeOutSeconds  = 10;
  static const String dialplan        = 'xml default';
  static const String originationChan = 'or_origination_channel';
  /**
   * Starts an origination in the PBX.
   *
   * By first dialing the agent and then the outbound extension.
   */
  static Future originate (String extension, int contactID, int receptionID, SharedModel.User user) {
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
   * Starts an origination in the PBX.
   *
   * By first dialing the agent and then the recordingsmenu.
   */
  static Future originateRecording (int receptionID, String recordExtension, String soundFilePath, SharedModel.User user) {
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
  static Future<String> originateOutboundFirst (String extension, int contactID, int receptionID, SharedModel.User user) {
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
  static Future bridge (Model.Call source, Model.Call destination) {
    Model.TransferRequest.create (source.ID, destination.ID);

    return Model.PBXClient.api ('uuid_bridge ${source.ID} ${destination.ID}')
        .then((ESL.Response response) {

          if (response.status != ESL.Response.OK) {
            throw new StateError('ESL returned ${response.rawBody}');
          }

          return response;
        });
  }

  /**
   * Transfers an active call to a user.
   */
  static Future transfer (Model.Call source, String extension) {

    ESL.Response transferResponse;

    return Model.PBXClient.api ('uuid_transfer ${source.channelID} ${extension}')
                                .then((response) => transferResponse = response)
        .then ((_) => Model.PBXClient.api ('uuid_break ${source.channelID}').then((_) => transferResponse));
  }

  /**
   * Kills the active channel for a call.
   */
  static Future hangup (Model.Call call) {
    return Model.PBXClient.api('uuid_kill ${call.channelID}')
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
  static Future park (Model.Call call, SharedModel.User user) {
    return transfer(call, _parkinglot (user));
  }

  /**
   * Parking lot identifier for a user.
   */
  static String _parkinglot (SharedModel.User user) => 'park+${user.ID}';
}