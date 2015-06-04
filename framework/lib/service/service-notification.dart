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
 */
class NotificationService {

  static final String className = '${libraryName}.Notification';

  static Queue<NotificationRequest> _requestQueue = new Queue();
  static bool   _busy = false;
  static Logger log   = new Logger (className);


  WebService _backend = null;
  Uri        _host;
  String     _token = '';

  NotificationService (Uri this._host, String this._token, this._backend);

  /**
   * Performs a broadcast via the notification server.
   */
  Future broadcastEvent(Event.Event event) {
    Uri uri = Resource.Notification.broadcast(this._host);
        uri = appendToken(uri, this._token);

    log.finest('POST $uri body:${event.asMap}');

    return _enqueue (new NotificationRequest()..body     = event.asMap
                                              ..resource = uri);
  }

  /**
   * Retrieves the [ClientConnection]'s currently active on the server as an
   * [Iterable<Map>]
   */
  Future<Iterable<Map>> clientConnectionsMap() {
    Uri uri = Resource.Notification.clientConnections(this._host);
        uri = appendToken(uri, this._token);

    log.finest('GET $uri');

    return this._backend.get(uri).then(JSON.decode);
  }

  /**
   * Retrieves the [ClientConnection]'s currently active on the server.
   */
  Future<Iterable<Model.ClientConnection>> clientConnections() =>
    this.clientConnectionsMap().then((Iterable<Map> maps) =>
      maps.map ((Map map) => new Model.ClientConnection.fromMap(map)));

  /**
   * Retrieves the [ClientConnection] currently associated with [uid].
   */
  Future<Map> clientConnectionMap(int uid) {
    Uri uri = Resource.Notification.clientConnection(this._host, uid);
        uri = appendToken(uri, this._token);

    log.finest('GET $uri');

    return this._backend.get(uri).then(JSON.decode);
  }

  /**
   * Retrieves the [ClientConnections] currently active on the server.
   */
  Future<Model.ClientConnection> clientConnection(uid) =>
    this.clientConnectionMap(uid).then((Map map) =>
      new Model.ClientConnection.fromMap(map));

  /**
   * Sends an event via the notification server to [recipients]
   *
   * TODO: Implement and add test.
   */
  Future send(Iterable <int> recipients, Event.Event event) {
    Uri uri = Resource.Notification.send(this._host);
        uri = appendToken(uri, this._token);

        return new Future.error(new UnimplementedError());
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

    return this._backend.post (request.resource, JSON.encode(request.body))
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
    this._websocket.onClose = () => this._streamController.close();
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
