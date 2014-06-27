part of callflowcontrol.model;

abstract class PBXClient {
  
  static const String className = '${libraryName}.PBXClient'; 

   static ESL.Connection instance = null;
   
   static Future transfer (Call call, SharedModel.User user) {
     
     const String context = '${className}.transfer';
     
     //TODO:
     logger.debugContext("Trasferring call ${call.ID} to ${user.ID}", context);
     
     return new Future(() => true);
   }
   
   static Future<ESL.Response> api (String command) {
     const String context = '${className}.api';
     
     
     return instance.api(command).then((ESL.Response response) {
       logger.debugContext('$command => ${response.rawBody}' , context);
       return response;
     });
   }
   
}