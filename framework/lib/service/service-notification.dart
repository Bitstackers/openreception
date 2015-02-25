part of openreception.service;

abstract class NotificationResource {
  static final broadcast    = "/broadcast";
  static final message      = "/message";

  static Uri notifications(Uri host)
      => Uri.parse('${host}/notifications');

  static Uri notification(Uri host)
      => Uri.parse('${host}/notification');
}

/**
 * TODO: Change to reflect the pattern of message.
 */

class NotificationRequest {
  Map    body        = null;
  Uri    resource    = null;
  Completer response = new Completer();
}

class NotificationService {

  static final String className = '${libraryName}.Notification';

  static Queue<NotificationRequest> _requestQueue = new Queue();
  static bool   _busy = false;
  static Logger log   = new Logger (className);


  WebService _backed = null;
  Uri        _host;
  String     _token = '';

  NotificationService (Uri this._host, String this._token, this._backed);

  /**
   * Performs a broadcat via the notification server.
   */
  Future broadcast(Map map) {
    final String context = '${className}.broadcast';
    Uri host = Uri.parse('${this._host}${NotificationResource.broadcast}?token=${this._token}');

    log.finest('POST $host $map');

    return _enqueue (new NotificationRequest()..body     = map
                                              ..resource = host);
  }

  /**
   * Every request sent to the phone is enqueued and executed in-order without
   * the possibility to pipeline requests. This is done to enforce strict
   * ordering of notifications, so that they are received in-order.
   */
  Future<String> _enqueue (NotificationRequest request) {
      if (!_busy) {
        log.finest('No requests enqueued. Sending request directly.');
        _busy = true;
        return this._performRequest (request);
      } else {
        log.finest('Requests enqueued. Enqueueing this request.');
        _requestQueue.add(request);
        return request.response.future;
      }
  }

  Future _performRequest (NotificationRequest request) {

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

    return this._backed.post (request.resource, JSON.encode(request.body))
           .whenComplete(dispatchNext);
           //.catchError((error, StackTrace) => print('${error} : ${StackTrace}'))
    }


  /**
   * Opens a WebSocket connection
   */
  static Future<NotificationSocket> socket(WebSocket notificationBackend, Uri host, String serverToken) {

    return notificationBackend.connect(
        appendToken(NotificationResource.notifications (host),serverToken))
        .then((WebSocket ws) => new NotificationSocket(ws));
  }


  static bool _UriEndsWithSlash (Uri uri) => uri.toString().endsWith('/');
}

class NotificationSocket {
  static final String className = '${libraryName}.NotificationSocket';

  WebSocket                     _websocket        = null;
  StreamController<Model.Event> _streamController = new StreamController.broadcast();
  Stream<Model.Event> get       eventStream       => this._streamController.stream;
  static Logger                 log               = new Logger (NotificationSocket.className);

  NotificationSocket (this._websocket) {
    log.finest('Created a new WebSocket.');
    this._websocket.onMessage = this._parseAndDispatch;
  }

  void _parseAndDispatch(String buffer) {
    Map map = JSON.decode(buffer);
    log.finest('Sending object: $map');
    this._streamController.add(new Model.Event.parse(map));
  }

}
