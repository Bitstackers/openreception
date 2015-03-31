part of openreception.service;


/**
 * TODO: Change to reflect the pattern of message.
 */

class NotificationRequest {
  Map    body        = null;
  Uri    resource    = null;
  Completer response = new Completer();
}

/**
 * Client for Notification sending.
 *
 * TODO: Figure out
 */
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
    Uri host = Uri.parse('${this._host}${Resource.Notification.broadcast}?token=${this._token}');

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
        _busy = true;
        return this._performRequest (request);
      } else {
        _requestQueue.add(request);
        return request.response.future;
      }
  }

  /**
   * Performs the actual backend post operation.
   *
   */
  Future _performRequest (NotificationRequest request) {

    void dispatchNext() {
      if (_requestQueue.isNotEmpty) {
        NotificationRequest currentRequest = _requestQueue.removeFirst();

        _performRequest (currentRequest)
          .then((_) => currentRequest.response.complete());
      } else {
        _busy = false;
      }
    }

    return this._backed.post (request.resource, JSON.encode(request.body))
           .whenComplete(dispatchNext);
           //.catchError((error, StackTrace) => print('${error} : ${StackTrace}'))
    }


  /**
   * Factory shortcut for opening a [NotificationSocket] client connection.
   */
  static Future<NotificationSocket> socket(WebSocket notificationBackend, Uri host, String serverToken) {

    return notificationBackend.connect(
        appendToken(Resource.Notification.notifications (host),serverToken))
        .then((WebSocket ws) => new NotificationSocket(ws));
  }


  static bool _UriEndsWithSlash (Uri uri) => uri.toString().endsWith('/');
}

/**
 * Notification listener socket client.
 */
class NotificationSocket {
  static final String className = '${libraryName}.NotificationSocket';

  WebSocket                     _websocket        = null;
  StreamController<Event.Event> _streamController = new StreamController.broadcast();
  Stream<Event.Event> get       eventStream       => this._streamController.stream;
  static Logger                 log               = new Logger (NotificationSocket.className);

  NotificationSocket (this._websocket) {
    log.finest('Created a new WebSocket.');
    this._websocket.onMessage = this._parseAndDispatch;
  }

  Future close() => this._websocket.close();

  void _parseAndDispatch(String buffer) {
    Map map = JSON.decode(buffer);
    Event.Event newEvent = new Event.Event.parse(map);

    if (newEvent != null) {
      this._streamController.add(newEvent);
    } else {
      log.warning('Refusing to inject null objects into event stream');
    }
  }
}
