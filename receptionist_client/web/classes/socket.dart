/*                                Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This library is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License and
  a copy of the GCC Runtime Library Exception along with this program;
  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
  <http://www.gnu.org/licenses/>.
*/

/**
 * A class that contains a websocket.
 */
library socket;

import 'dart:async';
import 'dart:html';
import 'dart:json' as json;
import 'dart:uri';

import 'common.dart';
import 'logger.dart';

class _ConnectionManager{
  var connections = new List<Socket>();
  const MAX_TICKS = 3;

  /**
   * Adds a connection to the list of managed connections.
   */
  void addConnection(Socket socket) => connections.add(socket);

  _ConnectionManager(Duration reconnectInterval) {
    new Timer.periodic  (reconnectInterval,(timer) {
      for (var connection in connections) {
        if (connection.dead) {

          if (connection._connectTicks == 0) {
            log.critical('${connection.toString()} is dead');
            connection._reconnect();
            connection._connectTicks += 1;

          } else if (connection._connectTicks > MAX_TICKS) {
            log.critical('${connection.toString()} is timedout');
            connection._connectTicks = 0;
            connection._reconnect();

          } else {
            connection._connectTicks += 1;
          }
        }
      }
    });
  }
}

final _connectionManager = new _ConnectionManager(new Duration(seconds: 1));

/**
 * A generic Websocket, that reconnects itself.
 */
class Socket{
  WebSocket _channel;
  StreamController<Map> _messageStream = new StreamController<Map>();
  StreamController<Map> _errorStream = new StreamController<Map>();
  final String _url;

  int _connectTicks = 0;

  Socket._internal(this._url){
    _connector();
  }

  /**
   * Open a websocket on [url].
   */
  factory Socket(Uri url){
    if (url.isAbsolute) {
      var socket = new Socket._internal(url.toString());
      socket._connectTicks = 1;
      _connectionManager.addConnection(socket);
      return socket;
    } else {
      log.critical('${url.toString()} is not valid.');
    }
  }

  void _connector() {
    log.info('Opening websocket on ${_url}');
    _channel = new WebSocket(_url);
    _channel.onOpen.listen((_) => _connectTicks = 0);
    _channel.onMessage.listen(_onMessage);
    _channel.onError.listen(_onError);
    _channel.onClose.listen(_onError);

    window.onUnload.listen((_){
      _channel.close();
    });
  }

  /**
   * Checks if the socket is dead.
   */
  bool get dead => _channel == null || _channel.readyState != WebSocket.OPEN;

  void _onError (event) {
    log.critical(event.toString());

    _errorStream.sink.add({'error': 'Error on connection'});
  }

  /**
   * returns [_errorStream] for subscribers.
   */
  Stream<Map> get onError => _errorStream.stream.asBroadcastStream();

  void _onMessage(MessageEvent event) {
    log.info('Notification message: ${event.data}');
    _messageStream.sink.add(json.parse(event.data));
  }

  /**
   * returns [_messageStream] for subscribers.
   */
  Stream<Map> get onMessage => _messageStream.stream.asBroadcastStream();

  void _reconnect() => _connector();

  String toString() {
    return _url;
  }
}
