part of callflowcontrol.controller;



abstract class PBX {
  
  static const String className      = '${libraryName}.PBX';
  static const String callerID       = '39990141';
  static const int    timeOutSeconds = 5;
  static const String dialplan       = 'xml default';
  
  /**
   * Starts an origination in the PBX.
   * 
   * By first dialing the agent and then the outbound extension.
   */
  static Future originate (String extension, int contactID, int receptionID, SharedModel.User user) {
    List<String> variables = ['reception_id=${receptionID}',
                              'owner=${user.ID}',
                              'contact_id=${contactID}'];
    
    return Model.PBXClient.api 
        ('originate {${variables.join(',')}}user/${user.peer} ${extension} ${dialplan} $callerID $callerID $timeOutSeconds')
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
                              'originate_timeout=$timeOutSeconds'];
          
    throw new StateError('Not implemented');
    //Alternate origination:: originate  sofia/gateway/fonet-77344600-outbound/40966024 &bridge(user/1002)
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
        });
  }
  
  /**
   * Transfers an active call to another extension.
   */
  static Future transfer (Model.Call source, String extension) {
    const String context = '${className}.transfer';
    
    
    logger.debugContext('Breaking channel from current audio stream.', context);
    return Model.PBXClient.api ('uuid_break ${source.channel}')
        .then ((ESL.Response reponse) => Model.PBXClient.api ('uuid_transfer ${source.channel} ${extension}').then((response) => response));
  }

  /**
   * Kills the active channel for a call.
   */
  static Future hangup (Model.Call call) {
    return Model.PBXClient.api('uuid_kill ${call.channel}')
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
