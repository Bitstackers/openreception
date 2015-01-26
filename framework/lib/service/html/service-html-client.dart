part of openreception.service.html;

class Client extends Service.WebService {

  static final String className = '${libraryName}.Client';

  Logger log = new Logger(Client.className);

  /**
   * Retrives [resource] using HTTP GET.
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
