part of openreception.service;

abstract class Resource {
  static final broadcast    = "/broadcast";
  static final message      = "/message";
  static final notification = "/notifications";
}

/**
 * TODO: Change to reflect the pattern of message.
 */

class NotificationRequest {
  Map    body        = null;
  Uri    resource    = null;
  Completer response = new Completer();
}

abstract class Notification {

  static final String className = '${libraryName}.Notification';

  static HttpClient _client = new HttpClient();

  static Queue<NotificationRequest> _requestQueue = new Queue();
  static bool   _busy = false;
  static Logger log   = new Logger (className);

  /**
   * Performs a broadcat via the notification server.
   */
  static Future broadcast(Map map, Uri host, String serverToken) {
    final String context = '${className}.broadcast';

    host = Uri.parse('${host}${Resource.broadcast}?token=${serverToken}');

    log.finest('POST $host');

    return _enqueue (new NotificationRequest()..body     = map
                                              ..resource = host);
  }

  /**
   * Every request sent to the phone is enqueued and executed in-order without
   * the possibility to pipeline requests. The SNOM phones does not take kindly
   * to concurrent requests, and this is a mean to prevent this from happening.
   */
  static Future<String> _enqueue (NotificationRequest request) {
      if (!_busy) {
        log.finest('No requests enqueued. Sending request directly.');
        _busy = true;
        return _performRequest (request);
      } else {
        log.finest('Requests enqueued. Enqueueing this request.');
        _requestQueue.add(request);
        return request.response.future;
      }
  }

  static Future _performRequest (NotificationRequest request) {

    void dispatchNext() {
      log.severe('Dispatching next.');
      if (_requestQueue.isNotEmpty) {
        log.finest('Popping request from queue.');
        NotificationRequest currentRequest = _requestQueue.removeFirst();

        _performRequest (currentRequest)
          .then((_) => currentRequest.response.complete());
      } else {
        log.finest('queue is empty.');
        _busy = false;
      }
    }

    return _client.postUrl(request.resource)
            .then(( HttpClientRequest req ) {
             req.headers.contentType = new ContentType( "application", "json", charset: "utf-8" );
             //req.headers.add( HttpHeaders.CONNECTION, "keep-alive");
             req.write( JSON.encode( request.body ));
             return req.close();
           })
           .whenComplete(dispatchNext);
           //.catchError((error, StackTrace) => print('${error} : ${StackTrace}'))

    }


  /**
   * Opens a WebSocket connection
   */
  static Future<NotificationSocket> socket(Uri host, String serverToken) {

    return WebSocket.connect('${host}${Resource.notification}?token=$serverToken')
        .then((WebSocket ws) => new NotificationSocket(ws));
  }


  static bool _UriEndsWithSlash (Uri uri) => uri.toString().endsWith('/');
}


class NotificationSocket {

  WebSocket                     _websocket        = null;
  StreamController<Model.Event> _streamController = new StreamController.broadcast();
  Stream<Model.Event> get       eventStream       => this._streamController.stream;

  NotificationSocket (this._websocket) {
    print ("created websocket");
    this._websocket.listen (this._parseAndDispatch);
  }

  void _parseAndDispatch(String buffer) {
    print (buffer);
    Map map = JSON.decode(buffer);
    this._streamController.add(new Model.Event.parse(map));
  }

}