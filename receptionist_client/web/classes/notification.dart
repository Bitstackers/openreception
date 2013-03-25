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
 * Library to manager the notification interface at Alice.
 */
library notification;

import 'dart:async';
import 'dart:uri';

import 'common.dart';
import 'configuration.dart';
import 'logger.dart';
import 'socket.dart';
import 'utilities.dart';

/**
 * A Class to handle all the notifications from Alice.
 */
class Notification {
  var _eventHandlers = new Map<String, StreamController<Map>>();
  Socket _socket;

  Notification._internal() {
    assert(configuration.loaded);

    Uri url = configuration.notificationSocketInterface;
    int reconnetInterval = configuration.notificationSocketReconnectInterval;

    _socket = new Socket(url);
    if (_socket == null){
      throw new Exception('I used to be a Socket, but then i took an arrow to the knee.');
    }
    _socket.onMessage.listen(_onMessage);
    //TODO add panic handler for onError.
  }

  /**
   * Adds subscribers for an event with the specified [eventName].
   */
  void addEventHandler(String eventName, Subscriber subscriber) {
    if (!_eventHandlers.containsKey(eventName)) {
      _eventHandlers[eventName] = new StreamController<Map>.broadcast();
    }
    _eventHandlers[eventName].stream.listen(subscriber);
  }

  void _onMessage(Map json) {
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
    log.info('persistent notification');
  }

  void _nonPersistentNotification(Map json) {
    log.info('nonpersistent notification');

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

final notification = new Notification._internal();
