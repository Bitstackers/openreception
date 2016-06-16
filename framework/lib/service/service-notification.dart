/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.framework.service;

/**
 *
 */

class _NotificationRequest {
  Map body = null;
  Uri resource = null;
  Completer<String> response = new Completer<String>();
}

/**
 * Client for Notification sending.
 */
class NotificationService {
  static final String className = '${libraryName}.Notification';

  static Queue<_NotificationRequest> _requestQueue = new Queue();
  static bool _busy = false;
  static Logger log = new Logger(className);

  final WebService _httpClient;
  final Uri host;
  final String _clientToken;

  NotificationService(
      Uri this.host, String this._clientToken, this._httpClient);

  /**
   * Performs a broadcast via the notification server.
   */
  Future broadcastEvent(event.Event event) {
    Uri uri = resource.Notification.broadcast(host);
    uri = _appendToken(uri, _clientToken);

    log.finest('Broadcasting ${event.runtimeType}');

    return _enqueue(new _NotificationRequest()
      ..body = event.toJson()
      ..resource = uri);
  }

  /**
   * Retrieves the [ClientConnection]'s currently active on the server.
   */
  Future<Iterable<model.ClientConnection>> clientConnections() async {
    Uri uri = resource.Notification.clientConnections(host);
    uri = _appendToken(uri, _clientToken);

    log.finest('GET $uri');

    return await _httpClient.get(uri).then(JSON.decode).then(
        (Iterable<Map> maps) =>
            maps.map((Map map) => new model.ClientConnection.fromMap(map)));
  }

  /**
   * Retrieves the [ClientConnection] currently associated with [uid].
   */
  Future<model.ClientConnection> clientConnection(int uid) {
    Uri uri = resource.Notification.clientConnection(host, uid);
    uri = _appendToken(uri, _clientToken);

    log.finest('GET $uri');

    return _httpClient
        .get(uri)
        .then(JSON.decode)
        .then((Map map) => new model.ClientConnection.fromMap(map));
  }

  /**
   * Sends an event via the notification server to [recipients]
   */
  Future send(Iterable<int> recipients, event.Event event) {
    Uri uri = resource.Notification.send(host);
    uri = _appendToken(uri, _clientToken);

    final payload = {
      'recipients': recipients.toList(),
      'message': event.toJson()
    };

    return _httpClient
        .post(uri, JSON.encode(payload))
        .then(JSON.decode)
        .then((Map map) => new model.ClientConnection.fromMap(map));
  }

  /**
   * Every request sent to the phone is enqueued and executed in-order without
   * the possibility to pipeline requests. This is done to enforce strict
   * ordering of notifications, so that they are received in-order.
   */
  Future<String> _enqueue(_NotificationRequest request) {
    if (!_busy) {
      _busy = true;
      return _performRequest(request);
    } else {
      _requestQueue.add(request);
      return request.response.future;
    }
  }

  /**
   * Performs the actual backend post operation.
   *
   */
  Future<String> _performRequest(_NotificationRequest request) async {
    void dispatchNext() {
      if (_requestQueue.isNotEmpty) {
        _NotificationRequest currentRequest = _requestQueue.removeFirst();

        _performRequest(currentRequest)
            .then((_) => currentRequest.response.complete())
            .catchError(currentRequest.response.completeError);
      } else {
        _busy = false;
      }
    }

    try {
      return await _httpClient
          .post(request.resource, JSON.encode(request.body))
          .whenComplete(dispatchNext);
    } catch (error, StackTrace) {
      log.warning('${error} : ${StackTrace}');
      throw new Error();
    }
  }

  /**
   * Factory shortcut for opening a [NotificationSocket] client connection.
   */
  static Future<NotificationSocket> socket(
      WebSocket notificationBackend, Uri host, String serverToken) {
    return notificationBackend
        .connect(_appendToken(
            resource.Notification.notifications(host), serverToken))
        .then((WebSocket ws) => new NotificationSocket(ws));
  }
}

/**
 * Notification listener socket client.
 */
class NotificationSocket {
  static final String className = '${libraryName}.NotificationSocket';

  WebSocket _websocket = null;
  Bus<event.Event> _eventBus = new Bus<event.Event>();
  Stream<event.Event> get eventStream => _eventBus.stream;
  static Logger log = new Logger(NotificationSocket.className);

  NotificationSocket(this._websocket) {
    log.finest('Created a new WebSocket.');
    _websocket.onMessage = _parseAndDispatch;
    _websocket.onClose = () => _eventBus.close();
  }

  Future close() => _websocket.close();

  void _parseAndDispatch(String buffer) {
    Map map = JSON.decode(buffer);
    event.Event newEvent = new event.Event.parse(map);

    if (newEvent != null) {
      _eventBus.fire(newEvent);
    } else {
      log.warning('Refusing to inject null objects into event stream');
    }
  }
}
