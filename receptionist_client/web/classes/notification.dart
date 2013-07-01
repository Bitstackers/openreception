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

library notification;

import 'dart:async';

import 'configuration.dart';
import 'logger.dart';
import 'socket.dart';
import 'utilities.dart';

final _Notification notification = new _Notification();

/**
 * A Class to handle all the WebSocket notifications coming from Alice.
 */
class _Notification {
  Socket                             _socket;
  Map<String, StreamController<Map>> _Streams = {'call_hangup':new StreamController<Map>.broadcast(),
                                                 'call_pickup':new StreamController<Map>.broadcast(),
                                                 'queue_join' :new StreamController<Map>.broadcast(),
                                                 'queue_leave':new StreamController<Map>.broadcast()};

  Stream<Map> get callHangup => _Streams['call_hangup'].stream;
  Stream<Map> get callPickup => _Streams['call_pickup'].stream;
  Stream<Map> get queueJoin  => _Streams['queue_join'].stream;
  Stream<Map> get queueLeave => _Streams['queue_leave'].stream;

  /**
   * [_Notification] constructor.
   */
  _Notification() {
    final Uri url = configuration.notificationSocketInterface;

    try {
      _socket = new Socket(url);
      _socket.onMessage.listen(_onMessage);
      _socket.onError.listen((e) => log.error('notification socket error: ${e.toString()}'));
    } catch(e) {
      log.critical('_Notification() ERROR ${e}');
    }
  }

  /**
   * Handles all notifications from from Alice, and dispatches them according to
   * their persistence status.
   */
  void _onMessage(Map json) {
    log.debug(json.toString());

    if (!json.containsKey('notification')) {
      log.critical('does not contains notification');
      return;
    }
    var notificationMap = json['notification'];

    if (!notificationMap.containsKey('persistent')) {
      log.critical('does not contains persistent');
      return;
    }

    if (parseBool(notificationMap['persistent'])) {
      _persistentNotification(notificationMap);
    }else{
      _nonPersistentNotification(notificationMap);
    }
  }

  /**
   * Handles persistent notifications.
   */
  void _persistentNotification(Map json) {
    log.info('persistent');
  }

  /**
   * Handles non-persistent notifications.
   */
  void _nonPersistentNotification(Map json) {
    log.info('nonpersistent');

    if (!json.containsKey('event')) {
      log.critical('nonPersistensNotification did not have a event field.');
    }
    var eventName = json['event'];
    log.info('notification with event: ${eventName}');

    if (_Streams.containsKey(eventName)) {
      _Streams[eventName].sink.add(json);
    }else{
      log.error('Unhandled event: ${eventName}');
      log.debug(json.toString());
    }
  }
}
