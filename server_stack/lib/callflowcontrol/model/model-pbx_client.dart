part of callflowcontrol.model;

abstract class PBXClient {

  static final Logger log = new Logger ('${libraryName}.PBXClient');

  static ESL.Connection instance = null;

  static Future<ESL.Response> api (String command) {
    return instance.api(command).then((ESL.Response response) {
      log.finest('api $command => ${response.rawBody}');
      return response;
    });
  }

  static Future<ESL.Reply> bgapi (String command) {
    return instance.bgapi(command).then((ESL.Reply response) {
      log.finest('bgapi $command => ${response.content}');
      return response;
    });
  }

}