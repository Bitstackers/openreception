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

import 'common.dart';
import 'configuration.dart';
import 'logger.dart';
import 'socket.dart';
import 'utilities.dart';

final _Notification notification = new _Notification();

/**
 * A Class to handle all the notifications from Alice.
 */
class _Notification {
  Map<String, StreamController<Map>> _eventHandlers = new Map<String, StreamController<Map>>();
  Socket _socket;

  _Notification() {
    assert(configuration.loaded);

    Uri url = configuration.notificationSocketInterface;
    int reconnetInterval = configuration.notificationSocketReconnectInterval;

    try {
      _socket = new Socket(url);

      _socket.onMessage.listen(_onMessage);
      //TODO make better panichandler for onError.
      _socket.onError.listen((e) => log.error('notification socket error: ${e.toString()}'));
    } catch(e) {
      log.critical('_Notification() ERROR ${e}');
    }
  }

  /**
   * Adds subscribers for an event with the specified [eventName].
   * TODO Should this be a getter property instead????.
   */
  void addEventHandler(String eventName, Subscriber subscriber) {
    if (!_eventHandlers.containsKey(eventName)) {
      _eventHandlers[eventName] = new StreamController<Map>();
    }
    _eventHandlers[eventName].stream.asBroadcastStream().listen(subscriber);
  }

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
    //Is it a persistent event or not.
    if (parseBool(notificationMap['persistent'])) {
      _persistentNotification(notificationMap);
    }else{
      _nonPersistentNotification(notificationMap);
    }
  }

  void _persistentNotification(Map json) {
    log.info('persistent');
  }

  void _nonPersistentNotification(Map json) {
    log.info('nonpersistent');

    if (!json.containsKey('event')) {
      log.critical('nonPersistensNotification did not have a event field.');
    }
    var eventName = json['event'];
    log.info('notification with event: ${eventName}');

    if (_eventHandlers.containsKey(eventName)) {
      _eventHandlers[eventName].sink.add(json);
    }else{
      log.error('Unhandled event: ${eventName}');
      log.debug(json.toString());
    }
  }
}
