part of callflowcontrol.model;

abstract class PBXClient {
  
  static const String className = '${libraryName}.PBXClient'; 

   static ESL.Connection instance = null;
   
   static Future<ESL.Response> api (String command) {
     const String context = '${className}.api';
     
     
     return instance.api(command).then((ESL.Response response) {
       logger.debugContext('$command => ${response.rawBody}' , context);
       return response;
     });
   }
   
}