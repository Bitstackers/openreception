part of openreception.service.html;

class Client extends Service.WebService {

  static final String className = '${libraryName}.Client';

  Logger log = new Logger(Client.className);

  Future<String> get (Uri resource) {
    final Completer<String> completer = new Completer<String>();

    log.finest("GET $resource");

    HTML.HttpRequest request;
    request = new HTML.HttpRequest()
          ..open('GET', resource.toString())
          ..onLoad.listen((_) {
            try {
              this.checkResponseCode  (request.status);
              completer.complete(request.responseText);
            } catch (error) {
              completer.completeError (error);
            }
          })
          ..send()
          ..onError.listen((e) {
            completer.completeError(e);
          });

      return completer.future;
    }


  Future<String> put (Uri resource, String payload) {
    throw new UnimplementedError();
  }

  Future<String> post (Uri resource, String payload) {
    throw new UnimplementedError();
  }

  Future<String> delete (Uri resource) {
    throw new UnimplementedError();
  }

}
