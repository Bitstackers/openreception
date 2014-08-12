part of openreception.service;

abstract class AuthProtocol {
  static tokenResource(String token) => 'token/${token}';
  static tokenValidateResource(String token) => 'token/${token}/validate';
}

abstract class Authentication {

  static final String className = '${libraryName}.Authentication';

  static HttpClient client = new HttpClient();

  /**
   * Performs a lookup of the user on the notification server via the supplied token.
   */
  static Future<Model.User> userOf({String token, Uri host}) {
    final String context = '${className}.broadcast';

    Completer<Model.User> completer = new Completer<Model.User>();

    if (!_UriEndsWithSlash(host)) {
      host = Uri.parse (host.toString() + '/');
    }

    Uri url = Uri.parse(host.toString() + AuthProtocol.tokenResource(token));

    client.getUrl(url)
        .then((HttpClientRequest request) => request.close())
        .then((HttpClientResponse response) {
          String buffer = "";
          if (response.statusCode == 200) {
          response.transform(UTF8.decoder).listen((contents) {
            buffer = '${buffer}${contents}';

          }).onDone(() {
            completer.complete(new Model.User.fromMap(JSON.decode(buffer)));
          });
          } else {
            completer.completeError(new StateError('Bad response from server: ${response.statusCode}'));
          }
    });

    return completer.future;

  }

  static bool _UriEndsWithSlash (Uri uri) => uri.toString().endsWith('/');
}
