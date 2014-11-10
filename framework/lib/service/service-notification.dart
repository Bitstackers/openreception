part of openreception.service;

abstract class Resource {
  static final broadcast    = "/broadcast";
  static final message      = "/message";
  static final notification = "/notification";
}

/**
 * TODO: Change to reflect the pattern of message.
 */

class NotificationRequest {
  String body     = null;
  Uri    resource = null;
  Completer<String> response = new Completer();
}

abstract class Notification {

  static final String className = '${libraryName}.Notification';

  static HttpClient _client = new HttpClient();

  static Queue<NotificationRequest> _requestQueue = new Queue();
  static bool   _busy = false;

  /**
   * Performs a broadcat via the notification server.
   */
  static Future broadcast(Map map, Uri host, String serverToken) {
    final String context = '${className}.broadcast';

    if (!_UriEndsWithSlash(host)) {
      host = Uri.parse (host.toString() + '/');
    }

    host = Uri.parse('${host}${Resource.broadcast}?token=${serverToken}');

    return _enqueue (new NotificationRequest()..body     = map.toString()
                                              ..resource = host);
  }

  /**
   * Every request sent to the phone is enqueued and executed in-order without
   * the possibility to pipeline requests. The SNOM phones does not take kindly
   * to concurrent requests, and this is a mean to prevent this from happening.
   */
  static Future<String> _enqueue (NotificationRequest request) {
      if (!_busy) {
        _busy = true;
        return _performRequest (request);
      } else {
        _requestQueue.add(request);
        return request.response.future;
      }
  }

  static Future <String> _performRequest (NotificationRequest request) {

    void dispatchNext() {
      if (_requestQueue.isNotEmpty) {
        NotificationRequest currentRequest = _requestQueue.removeFirst();

        _performRequest (currentRequest)
          .then((String response) => currentRequest.response.complete(response));
      } else {
        _busy = false;
      }
    }

    return _client.postUrl(request.resource)
            .then(( HttpClientRequest req ) {
             req.headers.contentType = new ContentType( "application", "json", charset: "utf-8" );
             req.headers.add( HttpHeaders.CONNECTION, "keep-alive");
             req.write( JSON.encode( request.body ));
             return req.close();
           }).catchError((error, StackTrace) => print('${error} : ${StackTrace}'))
           ..whenComplete(() => new Future(dispatchNext));
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