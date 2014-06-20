part of callflowcontrol.controller;

abstract class PBX {
  
  static const String className      = '${libraryName}.PBX';
  static const String callerID       = '39990141';
  static const int    timeOutSeconds = 5;
  static const String dialplan       = 'xml default';
  
  static Future originate (String extension, int contactID, int receptionID, SharedModel.User user) {
    List<String> variables = ['reception_id=${receptionID}',
                              'owner=${user.ID}',
                              'contact_id=${contactID}',
                              'origination_caller_id_name=$callerID',
                              'origination_caller_id_number=$callerID',
                              'originate_timeout=$timeOutSeconds'];
    
    return Model.PBXClient.instance.api 
        ('originate {${variables.join(',')}}user/${user.peer} ${extension} ${dialplan}')
        .then((ESL.Response response) => response.channelUUID); 
      
    //Alternate: originate  sofia/gateway/fonet-77344600-outbound/40966024 &bridge(user/1002)
  }
  
  static Future bridge (Model.Call source, Model.Call destination) {
    Model.TransferRequest.create (source.ID, destination.ID);
    
    return Model.PBXClient.instance.api ('uuid_bridge ${source.ID} ${destination.ID}');
  }
  
  static Future transfer (Model.Call source, String extension) {
    const String context = '${className}.transfer';
    
    
    logger.debugContext('Breaking channel from current audio stream.', context);
    return           Model.PBXClient.instance.api ('uuid_break ${source.channel}')
      ..then ((_) => Model.PBXClient.instance.api ('uuid_transfer ${source.channel} ${extension}'));  
  }

  static Future hangup (Model.Call call) {
    //TODO: Check packet.
    return Model.PBXClient.instance.api('uuid_kill ${call.channel}');
  }

  static Future park (Model.Call call, SharedModel.User user) {
    return transfer(call, _parkinglot (user));
  }
  
  static String _parkinglot (SharedModel.User user) => 'park+${user.ID}';
}


/*
--  The reception ID is used for tracking the call later on.
Originate_Action.Add_Option
  (Option => ESL.Command.Option.Create
     (Key   => Constants.Reception_ID,
      Value => Util.Image.Image (Reception_ID)));

--  The user ID is used for .
Originate_Action.Add_Option
  (Option => ESL.Command.Option.Create
     (Key   => Constants.Owner,
      Value => Util.Image.Image (User.Identification)));

--  The reception ID is used for tracking the call later on.
Originate_Action.Add_Option
     (Option => ESL.Command.Option.Create
        (Key   => Constants.Contact_ID,
         Value => Util.Image.Image (Contact_ID)));

--  Adding the caller ID name and number prevents the display on the
--  phone from showing all zeros.
Originate_Action.Add_Option
  (Option => ESL.Command.Option.Create
     (Key   => Constants.Origination_Caller_Id_Name,
      Value => Extension));

Originate_Action.Add_Option
  (Option => ESL.Command.Option.Create
     (Key   => Constants.Origination_Caller_Id_Number,
      Value => Extension));

--  Wait for maximum 5 seconds for the local peer to pickup the phone.
--  This timeout should never be reached, as our phones are expected
--  to be in auto-answer mode.
Originate_Action.Add_Option
  (Option => ESL.Command.Option.Create
     (Key   => Constants.Originate_Timeout,
      Value => "5"));

--  Perform the request.
PBX.Client.API (Originate_Action, Reply);

--  TODO: Add more elaborate parsing here to determine if the call
--  really _isn't_ found.
if Reply.Response /= ESL.Reply.OK then
   PBX.Trace.Error
     (Message => "Originate request to extension " & Extension &
        " returned error " & Reply.Error_Type'Img,
      Context => Context);
   raise Error;
end if;

PBX.Trace.Debug
  (Message => "Originate request to extension " & Extension &
     " contact:" & Contact_ID'Img &
     " reception:" & Reception_ID'Img &
     " returned channel: """ & ESL.UUID.Image
     (Reply.Channel_UUID) & """",
   Context => Context);

*/
