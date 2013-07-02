/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library socket;

import 'dart:async';
import 'dart:html';
import 'dart:json' as json;

import 'common.dart';
import 'environment.dart';
import 'logger.dart';

final StreamController<bool> _connectionToAlice = new StreamController<bool>.broadcast();
Stream<bool> get connectionToAlice => _connectionToAlice.stream;

/**
 * A generic Websocket, that reconnects itself.
 */
class Socket{
  WebSocket             _channel;
  bool plannedClosed      = false;
  bool reconnectScheduled = false;
  int  baseRetrySeconds   = 2;
  int  retrySeconds;
  StreamController<Map> _errorStream   = new StreamController<Map>.broadcast();
  StreamController<Map> _messageStream = new StreamController<Map>.broadcast();
  final Uri             _url;

  bool        get isDead    => _channel == null || _channel.readyState != WebSocket.OPEN;
  Stream<Map> get onError   => _errorStream.stream;
  Stream<Map> get onMessage => _messageStream.stream;

  /**
   * Open a websocket on [url].
   *
   * Throws an [Exception] if [url] is not an absolute URL.
   */
  factory Socket(Uri url, [int retrySeconds = 2]){
    if (url.isAbsolute) {
      Socket socket = new Socket._internal(url);
      if (retrySeconds != null){
        socket.baseRetrySeconds = retrySeconds;
        socket.retrySeconds = retrySeconds;
      }
      socket._connector();

      return socket;
    } else {
      log.critical('Socket ERROR BAD URL ${url.toString()}');
      throw new Exception('Socket() ERROR BAD URL');
    }
  }

  Socket._internal(this._url){}

  void _connector() {
    log.info('Opening websocket on ${_url}');
    reconnectScheduled = false;
    _channel = new WebSocket(_url.toString());
    _channel.onMessage.listen(_onMessage);
    _channel.onError.listen(_onError);
    _channel.onClose.listen(_onError);
    _channel.onOpen.listen(_onOpen);
    window.onUnload.listen((_){
      plannedClosed = true;
      _channel.close();
    });
  }

  void _onOpen(event) {
    _connectionToAlice.sink.add(true);
    if (baseRetrySeconds != retrySeconds){
      retrySeconds = baseRetrySeconds;
    }
  }

  void _onError (event) {
    if(!plannedClosed){
      _connectionToAlice.sink.add(false);
      log.critical('Socket onError: ' + event.toString());
      _errorStream.sink.add({'error': 'Error on connection'});
      _reconnect();
    }
  }

  void _onMessage(MessageEvent event) {
    log.info('Notification message: ${event.data}');
    _messageStream.sink.add(json.parse(event.data));
  }

  void _reconnect() {
    if (!reconnectScheduled){
      new Timer(new Duration(seconds:baseRetrySeconds),
          () { retrySeconds = retrySeconds*2;
               _connector();
      });
    }
    reconnectScheduled = true;
  }

  String toString() => _url.toString();
}
