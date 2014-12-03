part of service;

abstract class MessageResource {

}

abstract class Message {

  static ORStorage.Message _instance = null;


  static ORStorage.Message get instance {
    if (_instance == null) {
      _instance = new ORService.RESTMessageStore
          (Uri.parse('http://localhost:4040'),
           configuration.token,
           new ORServiceHTML.Client());
    }

    return _instance;
  }


  static final String className = '${libraryName}.Message';

  static Future save(model.Message message, [Uri host]) {

    final String context = '${className}.send';

    if (host == null) {
      host = configuration.messageBaseUrl;
    };

    final String base = configuration.messageBaseUrl.toString();
    final Completer completer = new Completer();
    final List<String> fragments = new List<String>();
    final String path = '/message${message.ID != model.Message.noID ? '/${message.ID}' : ''}';

    /* Assemble the initial content for the message. */
    Map payload = message.asMap;

    /*
     * Now we are ready to send the request to the server.
     */

    HttpRequest request;
    String url;
    String method = message.ID == model.Message.noID
                    ? POST
                    : PUT;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    log.debugContext('url: ${url} - payload: ${payload}', context);

    request = new HttpRequest()
        ..open(method, url)
        ..setRequestHeader('Content-Type', 'application/json')
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete ();
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
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send(JSON.encode(payload));

    return completer.future;
  }

  /**
   * Stores and sends a message via the message service.
   */

  static Future send(model.Message message, [Uri host]) {

    final String context = '${className}.send';

    if (host == null) {
      host = configuration.messageBaseUrl;
    };

    final String base = configuration.messageBaseUrl.toString();
    final Completer completer = new Completer();
    final List<String> fragments = new List<String>();
    final String path = '/message/send';

    /* Assemble the initial content for the message. */
    Map payload = message.asMap;

    /*
     * Now we are ready to send the request to the server.
     */

    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    log.debugContext('url: ${url} - payload: ${payload}', context);

    request = new HttpRequest()
        ..open(POST, url)
        ..setRequestHeader('Content-Type', 'application/json')
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete ();
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
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send(JSON.encode(payload));

    return completer.future;
  }

  static Future<model.Message> get(int messageID, [Uri host]) {

    final String context = '${className}.get';

    if (host == null) {
      host = configuration.messageBaseUrl;
    }
    ;

    final String base = configuration.messageBaseUrl.toString();
    final Completer<model.Message> completer = new Completer<model.Message>();
    final List<String> fragments = new List<String>();
    final String path = '/message/${messageID}';

    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(GET, url)
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete(new model.Message.fromMap(JSON.decode(request.responseText)));
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
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send();

    return completer.future;
  }
}
