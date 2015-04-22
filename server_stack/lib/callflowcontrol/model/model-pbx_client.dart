part of callflowcontrol.model;

abstract class PBXClient {

  static final Logger log = new Logger ('${libraryName}.PBXClient');

  static ESL.Connection instance = null;

  static Future<ESL.Response> api (String command) {
    return instance.api(command).then((ESL.Response response) {
      log.finest('$command => ${response.rawBody}');
      return response;
    });
  }
}