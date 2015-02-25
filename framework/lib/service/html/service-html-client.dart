part of openreception.service.html;

/**
 * HTTP Client for use with dart:html.
 */
class Client extends Service.WebService {

  static final String className = '${libraryName}.Client';

  Logger log = new Logger(Client.className);

  /**
   * Retrives [resource] using HTTP GET.
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> get (Uri resource) {
    final Completer<String> completer = new Completer<String>();

    log.finest("GET $resource");

    HTML.HttpRequest request;
    request = new HTML.HttpRequest()
          ..open('GET', resource.toString())
          ..onLoad.listen((_) {
            try {
              Service.WebService.checkResponseCode(request.status);
              completer.complete(request.responseText);
            } catch (error) {
              completer.completeError (error);
            }
          })
          ..onError.listen((e) => completer.completeError(e))
          ..send();

    return completer.future;
  }

  /**
   * Retrives [resource] using HTTP PUT, sending [payload].
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> put (Uri resource, String payload) {
    final Completer<String> completer = new Completer<String>();

    log.finest("PUT $resource");

    HTML.HttpRequest request;
    request = new HTML.HttpRequest()
          ..open('PUT', resource.toString())
          ..onLoad.listen((_) {
            try {
              Service.WebService.checkResponseCode(request.status);
              completer.complete(request.responseText);
            } catch (error) {
              completer.completeError (error);
            }
          })
          ..onError.listen((e) => completer.completeError(e))
          ..send(payload);

    return completer.future;
  }

  /**
   * Retrives [resource] using HTTP POST, sending [payload].
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> post (Uri resource, String payload) {
    final Completer<String> completer = new Completer<String>();

    log.finest("POST $resource");

    HTML.HttpRequest request;
    request = new HTML.HttpRequest()
          ..open('POST', resource.toString())
          ..onLoad.listen((_) {
            try {
              Service.WebService.checkResponseCode(request.status);
              completer.complete(request.responseText);
            } catch (error) {
              completer.completeError (error);
            }
          })
          ..onError.listen((e) => completer.completeError(e))
          ..send(payload);

    return completer.future;
  }

  /**
   * Retrives [resource] using HTTP DELETE.
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> delete (Uri resource) {
    final Completer<String> completer = new Completer<String>();

    log.finest("DELETE $resource");

    HTML.HttpRequest request;
    request = new HTML.HttpRequest()
          ..open('DELETE', resource.toString())
          ..onLoad.listen((_) {
            try {
              Service.WebService.checkResponseCode(request.status);
              completer.complete(request.responseText);
            } catch (error) {
              completer.completeError (error);
            }
          })
          ..onError.listen((e) => completer.completeError(e))
          ..send();

    return completer.future;
  }
}
