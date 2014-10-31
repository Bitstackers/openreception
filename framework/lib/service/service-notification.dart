part of openreception.service;

abstract class Resource {
  static final broadcast    = "/broadcast";
  static final message      = "/message";
  static final notification = "/notification";
}

/**
 * TODO: Change to reflect the pattern of message.
 */

abstract class Notification {

  static final String className = '${libraryName}.Notification';

  static HttpClient client = new HttpClient();

  /**
   * Performs a broadcat via the notification server.
   */
  static Future broadcast(Map map, Uri host, String serverToken) {
    final String context = '${className}.broadcast';

    if (!_UriEndsWithSlash(host)) {
      host = Uri.parse (host.toString() + '/');
    }

    host = Uri.parse('${host}${Resource.broadcast}?token=${serverToken}');

    return client.postUrl(host)
      .then(( HttpClientRequest req ) {
        req.headers.contentType = new ContentType( "application", "json", charset: "utf-8" );
        //req.headers.add( HttpHeaders.CONNECTION, "keep-alive");
        req.write( JSON.encode( map ));
        return req.close();
      }).catchError((error, StackTrace) => print('${error} : ${StackTrace}' + context));
  }

  /**
   * Opens a WebSocket connection
   */
  static Future<NotificationSocket> socket(Uri host, String serverToken) {
    if (!_UriEndsWithSlash(host)) {
      host = Uri.parse (host.toString() + '/');
    }

    return WebSocket.connect('${host}${Resource.notification}')
        .then((WebSocket ws) => new NotificationSocket(ws));
  }


  static bool _UriEndsWithSlash (Uri uri) => uri.toString().endsWith('/');
}


class NotificationSocket {

  WebSocket ws = null;

  NotificationSocket (this.ws);
}