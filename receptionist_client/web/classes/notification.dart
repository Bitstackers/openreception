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

import 'package:event_bus/event_bus.dart';

import 'configuration.dart';
import 'environment.dart' as environment;
import 'events.dart' as event;
import 'logger.dart';
import 'model.dart' as model;
import 'socket.dart';
import 'state.dart';
import 'storage.dart' as storage;
import 'utilities.dart';

final _Notification notification = new _Notification();

/**
 * A Class to handle all the WebSocket notifications coming from Alice.
 */
class _Notification {
  static final EventType<Map> callHangup = new EventType<Map>();
  static final EventType<Map> callPickup = new EventType<Map>();
  static final EventType<Map> queueJoin  = new EventType<Map>();
  static final EventType<Map> queueLeave = new EventType<Map>();
  static final EventType<Map> callPark   = new EventType<Map>();
  static final EventType<Map> callUnpark = new EventType<Map>();

  Socket _socket;

  Map<String, EventType<Map>> _events =
    {'call_hangup': callHangup,
     'call_pickup': callPickup,
     'queue_join' : queueJoin,
     'queue_leave': queueLeave,
     'call_park'  : callPark,
     'call_unpark': callUnpark};

  /**
   * [_Notification] constructor.
   */
  _Notification();

  void initialize() {
    _registerEventListeners();
  }

  void makeSocket() {
    assert(state.isConfigurationOK);
    _socket = new Socket()
      ..onMessage.listen(_onMessage);
  }

  bool isConnected() => _socket.isConnected;

  /**
   * Handles non-persistent notifications.
   */
  void _nonPersistentNotification(Map json) {
    log.debug('nonpersistent');

    if(json.containsKey('event')) {
      String eventName = json['event'];
      log.debug('notification with event: ${eventName}');

      if (_events.containsKey(eventName)) {
        event.bus.fire(_events[eventName], json);

      } else {
        log.error('Unhandled event: ${eventName}');
        log.debug(json.toString());
      }
    } else {
      log.critical('nonPersistensNotification did not have a event field.');
    }
  }

  /**
   * Handles all notifications from from Alice, and dispatches them according to
   * their persistence status.
   */
  void _onMessage(Map json) {
    log.debug('Notification._onMessage ${json}');
    if (json.containsKey('notification')) {
      Map notificationMap = json['notification'];
      if (notificationMap.containsKey('persistent')) {
        if (parseBool(notificationMap['persistent'])) {
          _persistentNotification(notificationMap);
        } else {
          _nonPersistentNotification(notificationMap);
        }
      } else {
        log.error('Notification._onMessage Does not contains persistent.');
      }
    } else {
      log.critical('Notification._onMessage Does not contains notification.');
    }
  }

  /**
   * Handles persistent notifications.
   */
  void _persistentNotification(Map json) {
    log.debug('Notification._persistentNotification');
  }

  /**
   * Register event listeners.
   */
  void _registerEventListeners() {
    event.bus
    ..on(callHangup).listen((Map json) => _callHangupEventHandler(json))
    ..on(callPickup).listen((Map json) => _callPickupEventHandler(json))
    ..on(queueJoin) .listen((Map json) => _queueJoinEventHandler(json))
    ..on(queueLeave).listen((Map json) => _queueLeaveEventHandler(json))
    ..on(callPark)  .listen((Map json) => _callParkEventHandler(json))
    ..on(callUnpark).listen((Map json) => _callUnparkEventHandler(json));

    StreamSubscription subscription;
    subscription = event.bus.on(event.stateUpdated).listen((State value) {
      if(value.isConfigurationOK) {
        makeSocket();
        subscription.cancel();
      }
    });
  }
}

/**
 * Hangup [environment.call] when a call_hangup notification that matches
 * [environment.call] is received on the notification socket.
 */
void _callHangupEventHandler(Map json) {
  log.debug('notification._callHangupEventHandler');

  model.Call call = new model.Call.fromJson(json['call']);

  if (call.id == environment.call.id) {
    log.info('Call hangup ${call}', toUserLog: true);
    log.info('notification._callHangupEventHandler hangup call ${call}');
    event.bus.fire(event.callChanged, model.nullCall);
  }
}

/**
 * Set [environment.call]] when a call_pickup notification is received on the
 * notification socket and the assigned agent match the logged in agent.
 */
void _callPickupEventHandler(Map json) {
  log.debug('notification._callPickupEventHandler received ${json}');

  model.Call call = new model.Call.fromJson(json['call']);

  // TODO obviously the agent ID should not come from configuration. This is a
  // temporary hack as long as Alice is oblivious to login/session.
  if (call.assignedAgent == configuration.agentID) {
    log.info('Picked up call ${call}', toUserLog: true);
    event.bus.fire(event.callChanged, call);
    environment.call = call;

    log.debug('notification._callPickupEventHandler updated environment.call to ${call}');

    if (call.organizationId != null) {
      storage.getOrganization(call.organizationId).then((org) {
        event.bus.fire(event.organizationChanged, org);

      }).catchError((error) {
        log.critical('notification._callPickupEventHandler storage.getOrganization failed with ${error}');
        event.bus.fire(event.organizationChanged, model.nullOrganization);
      });
    } else {
      log.error('notification._callPickupEventHandler call ${call} missing organizationId');
    }
  }

  log.info('notification._callPickupEventHandler call ${call} assigned to agent ${call.assignedAgent}', toUserLog: true);
}

/**
 * Handles queue_join events.
 */
void _queueJoinEventHandler(Map json) {
  log.debug('notification._queueJoinEventHandler event: ${json}');
  final model.Call call = new model.Call.fromJson(json['call']);
  event.bus.fire(event.callQueueAdd, call);
}

/**
 * Handles queue_leave events.
 */
void _queueLeaveEventHandler(Map json) {
  log.debug('notification._queueLeaveEventHandler event: ${json}');
  final model.Call call = new model.Call.fromJson(json['call']);
  event.bus.fire(event.callQueueRemove, call);
}

/**
 * Sends the parked call to the localqueue.
 */
void _callParkEventHandler(Map json) {
  model.Call call = new model.Call.fromJson(json['call']);
  if(call.assignedAgent == configuration.agentID) {
    event.bus.fire(event.localCallQueueAdd, call);
    event.bus.fire(event.callChanged, model.nullCall);
  }
}

void _callUnparkEventHandler(Map json) {
  model.Call call = new model.Call.fromJson(json['call']);
  event.bus.fire(event.localCallQueueRemove, call);
}
