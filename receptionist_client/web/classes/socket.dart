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
import 'configuration.dart';
import 'environment.dart';
import 'logger.dart';

final StreamController<bool> _connectedToAlice = new StreamController<bool>.broadcast();
Stream<bool> get connectedToAlice => _connectedToAlice.stream;

/**
 * The Socket singleton handles the WebSocket connection to Alice.
 */
class Socket {
  WebSocket             _channel;
  static Socket         _instance;
  bool                  _intendedClose      = false;
  StreamController<Map> _messageStream      = new StreamController<Map>.broadcast();
  bool                  _reconnectScheduled = false;
  Duration              _reconnectInterval  = configuration.notificationSocketReconnectInterval;
  Uri                   _url                = configuration.notificationSocketInterface;

  bool        get isDead    => _channel == null || _channel.readyState != WebSocket.OPEN;
  Stream<Map> get onMessage => _messageStream.stream;

  /**
   * Socket constructor.
   *
   * Opens a websocket on [configuration.notificationSocketInterface].
   *
   * Will try to re-connect at interval [configuration.notificationSocketReconnectInterval]
   * if the connection fails.
   */
  factory Socket() {
    if (_instance == null) {
      _instance = new Socket._internal();
    }

    return _instance;
  }

  /**
   * Socket constructor.
   */
  Socket._internal() {
    _registerEventListeners();
    _connect();
  }

  /**
   * Create and connect the WebSocket.
   */
  void _connect() {
    log.info('Socket._connect ${_url}');

    _reconnectScheduled = false;

    _channel = new WebSocket(_url.toString())
        ..onMessage.listen(_onMessage)
        ..onError.listen(_onError)
        ..onClose.listen(_onError)
        ..onOpen.listen(_onOpen);
  }

  /**
   * Sink boolean true to the _connectedToAlice stream when the _channel
   * WebSocket is connected.
   */
  void _onOpen(Event event) => _connectedToAlice.sink.add(true);

  /**
   * Sink boolean false to the _connectedToAlice stream when the _channel
   * WebSocket disconnects and then try to reconnect.
   */
  void _onError (Event event) {
    if(!_intendedClose) {
      log.error('Socket._onError ${event}');

      _connectedToAlice.sink.add(false);
      _reconnect();
    }
  }

  /**
   * Is called on every message received on the _channel WebSocket. Valid
   * messages, ie. stuff that can be parsed into a map, are sinked to the
   * _messageStream stream.
   */
  void _onMessage(MessageEvent event) {
    try {
      Map notificationEvent = json.parse(event.data);
      _messageStream.sink.add(notificationEvent);
    } on FormatException {
      log.error('Socket._onMessage bad MessageEvent ${event.data}');
    } catch(e) {
      log.error('Socket._onMessage exception ${e}');
    }
  }

  /**
   * Try to connect the _channel WebSocket. This is done once every
   * _reconnectInterval until the WebSocket is connected.
   */
  void _reconnect() {
    if (!_reconnectScheduled) {
      new Timer(_reconnectInterval, () => _connect());
    }
    _reconnectScheduled = true;
  }

  /**
   * Registers event listeners.
   */
  _registerEventListeners() {
    window.onUnload.listen((_) {
      _intendedClose = true;
      _channel.close();
    });
  }
}
