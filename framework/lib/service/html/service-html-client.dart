part of openreception.service.html;

class Client extends Service.WebService {

  static final String className = '${libraryName}.IOWebService';

  Future<String> get (Uri resource) {
    final Completer<String> completer = new Completer<String>();

    final String context = '${className}.send';

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
          ..onError.listen((e) {
            completer.completeError(e);
          });

      return completer.future;
    }


  Future<String> put (Uri resource, String payload) {
    final String context = '${className}.get';

  }

  Future<String> post (Uri resource, String payload) {
  }

  Future<String> delete (Uri resource) {
  }

}
