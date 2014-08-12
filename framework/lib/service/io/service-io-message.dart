part of openreception.io.service;

class IOWebService extends WebService {

  static final String className = '${libraryName}.IOWebService';

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
            logger.error('$error : $stacktrace');
            completer.completeError(error);
          } else {
            logger.critical('$error : $stacktrace');
            completer.completeError(new StateError('Bad response from server: ${response.statusCode}'));
          }
        }
  });

  return completer.future;

  }




  Future<String> put (Uri resource, String payload) {
    final String context = '${className}.get';

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

class BrowserWebService implements WebService {

  static final String className = '${libraryName}.BrowserWebService';

  Future<Response> get (Uri path) {

    final String context = '${className}.get';
    final Completer<Response> completer = new Completer<Response>();

    HTML.HttpRequest request;
    request = new HTML.HttpRequest()
        ..open('GET', path.toString())
        ..setRequestHeader('Content-Type', 'application/json')
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete(new Response()..responseBody = request.responseText
                                               ..StatusCode   = request.status);
              break;
            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

           case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          completer.completeError(e);
        });

    return completer.future;
  }
}


class RESTMessageStore implements Storage.Message {

  static final String className = '${libraryName}.Message';

  IOWebService _backed = new IOWebService();

  Uri    _host;
  String _token = '';

  Uri appendToken (Uri uri) =>
      Uri.parse('${uri}${uri.queryParameters.isEmpty ? '?' : '&'}token=${this._token}');

  RESTMessageStore (Uri this._host, String this._token);

  Future<Model.Message> get(int messageID) =>
      this._backed.get (appendToken(MessageResource.single(this._host, messageID)))
      .then((String response)
        => new Model.Message.fromMap (JSON.decode(response)));

  Future<Model.Message> enqueue(Model.Message message) =>
      this._backed.post (appendToken(MessageResource.send(this._host, message.ID)))
      .then((String response)
        => new Model.Message.fromMap (JSON.decode(response)));

  Future<Model.Message> create(Model.Message message) =>
      this._backed.post (appendToken(MessageResource.root(this._host)), JSON.encode(message.asMap))
      .then((String response)
        => new Model.Message.fromMap (JSON.decode(response)));

  Future<Model.Message> update(Model.Message message) =>
      this._backed.put (appendToken(MessageResource.single(this._host, messageID)))
      .then((String response)
        => new Model.Message.fromMap (JSON.decode(response)));

  Future<List<Model.Message>> list() =>
      this._backed.get (appendToken(MessageResource.list(this._host)))
      .then((String response)
        => new Model.MessageList.fromMap (JSON.decode(response)));

  Future<List<Model.Message>> subset(int upperMessageID, int count) =>
      this._backed.get (appendToken(MessageResource.subset(this._host, upperMessageID, count)))
      .then((String response)
        => new Model.MessageList.fromMap (JSON.decode(response)));
}
