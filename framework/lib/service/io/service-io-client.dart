part of openreception.service.io;

class Client extends Service.WebService {

  static final String className = '${libraryName}.Client';
  static final Logger log       = new Logger (className);

  final IO.HttpClient client = new IO.HttpClient();

  Future<String> get (Uri resource) {
    final Completer<String> completer = new Completer<String>();

    client.getUrl(resource)
      .then((IO.HttpClientRequest request) =>
        request.close())
      .then((IO.HttpClientResponse response) {
        String buffer = "";
        try {
          this.checkResponseCode(response.statusCode);
          response.transform(UTF8.decoder).listen((contents) {
            buffer = '${buffer}${contents}';
          }).onDone(() {
            completer.complete(buffer);
          });
        } catch (error, stacktrace) {
          if (error is Storage.StorageException) {
            log.severe('$error : $resource');
            completer.completeError(error);
          } else {
            log.shout('$error : $stacktrace');
            completer.completeError(new StateError('Bad response from server: ${response.statusCode}'));
          }
        }
  });

  return completer.future;

  }




  Future<String> put (Uri resource, String payload) {
    final String context = '${className}.put';

  }

  Future<String> post (Uri resource, String payload) {
    final String context = '${className}.get';

    final Completer<String> completer = new Completer<String>();

    client.getUrl(resource)
      .then((IO.HttpClientRequest request) => request.close())
      .then((IO.HttpClientResponse response) {
        String buffer = "";
        if (response.statusCode == 200) {
        response.transform(UTF8.decoder).listen((contents) {
          buffer = '${buffer}${contents}';

        }).onDone(() {
          completer.complete(buffer);
          });
        } else {
          completer.completeError(new StateError('Bad response from server: ${response.statusCode}'));
        }
  });

  return completer.future;
  }

  Future<String> delete (Uri resource) {
    final String context = '${className}.get';

    final Completer<String> completer = new Completer<String>();

    client.getUrl(resource)
      .then((IO.HttpClientRequest request) => request.close())
      .then((IO.HttpClientResponse response) {
        String buffer = "";
        if (response.statusCode == 200) {
        response.transform(UTF8.decoder).listen((contents) {
          buffer = '${buffer}${contents}';

        }).onDone(() {
          completer.complete(buffer);
          });
        } else {
          completer.completeError(new StateError('Bad response from server: ${response.statusCode}'));
        }
  });

  return completer.future;
  }

}
