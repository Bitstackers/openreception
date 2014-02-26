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

import 'commands.dart' as command;
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
  static final EventType<Map> callHangup  = new EventType<Map>();
  static final EventType<Map> callPickup  = new EventType<Map>();
  static final EventType<Map> queueJoin   = new EventType<Map>();
  static final EventType<Map> queueLeave  = new EventType<Map>();
  static final EventType<Map> callPark    = new EventType<Map>();
  static final EventType<Map> callUnpark  = new EventType<Map>();
  static final EventType<Map> callOffer   = new EventType<Map>();
  static final EventType<Map> callLock    = new EventType<Map>();
  static final EventType<Map> callUnlock  = new EventType<Map>();
  static final EventType<Map> peerState   = new EventType<Map>();

  Socket _socket;

  Map<String, EventType<Map>> _events =
    {'call_hangup': callHangup,
     'call_pickup': callPickup,
     'queue_join' : queueJoin,
     'queue_leave': queueLeave,
     'call_park'  : callPark,
     'call_unpark': callUnpark,
     'call_offer' : callOffer,
     'call_unlock': callUnlock,
     'call_lock'  : callLock,
     'peer_state' : peerState};

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
  void _notificationDispatcher(Map json) {
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
    if (json.containsKey('notification')) {
      Map notificationMap = json['notification'];
      _notificationDispatcher(notificationMap);
    } else {
      log.critical('Notification._onMessage Does not contains notification.');
    }
  }
  
  /**
   * Register event listeners.
   */
  void _registerEventListeners() {
    event.bus
      ..on(callHangup).listen(_callHangupEventHandler)
      ..on(callPickup).listen(_callPickupEventHandler)
      ..on(queueJoin) .listen(_queueJoinEventHandler)
      ..on(queueLeave).listen(_queueLeaveEventHandler)
      ..on(callPark)  .listen(_callParkEventHandler)
      ..on(callUnpark).listen(_callUnparkEventHandler)
      ..on(callOffer) .listen(_callOfferEventHandler);

    if(configuration != null && configuration.isLoaded()) {
      makeSocket();

    } else {
      StreamSubscription subscription;
      subscription = event.bus.on(event.stateUpdated).listen((State value) {
        if(value.isConfigurationOK) {
          makeSocket();
          subscription.cancel();
        }
      });
    }
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
    log.info('Opkald lagt på. ${call}', toUserLog: true);
    log.info('notification._callHangupEventHandler hangup ${call}');
    event.bus.fire(event.callChanged, model.nullCall);
  }

  event.bus.fire(event.callQueueRemove, call);  
}

/**
 * Set [environment.call]] when a call_pickup notification is received on the
 * notification socket and the assigned agent match the logged in agent.
 */
void _callPickupEventHandler(Map json) {
  model.Call call = new model.Call.fromJson(json['call']);

  // TODO obviously the agent ID should not come from configuration. This is a
  // temporary hack as long as Alice is oblivious to login/session.
  if (call.assignedAgent == configuration.userId) {
    log.info('Tog kald. ${call}', toUserLog: true);
    event.bus.fire(event.callChanged, call);
    environment.call = call;

    log.debug('notification._callPickupEventHandler updated environment.call to ${call}');

    if (call.receptionId != null && call.receptionId > 0 && call.inbound) {
      storage.getReception(call.receptionId).then((model.Reception reception) {
        event.bus.fire(event.receptionChanged, reception);

      }).catchError((error) {
        log.critical('notification._callPickupEventHandler storage.getReception failed with ${error}');
        event.bus.fire(event.receptionChanged, model.nullReception);
      });
    } else {
      log.error('notification._callPickupEventHandler call ${call} missing receptionId');
    }
  }
  
  event.bus.fire(event.callQueueRemove, call);

  log.info('Opkald ${call} tildelt til agent ${call.assignedAgent}', toUserLog: true);
}

/**
 * Handles queue_join events.
 */
void _queueJoinEventHandler(Map json) {
  log.debug('notification._queueJoinEventHandler event: ${json}');
  //final model.Call call = new model.Call.fromJson(json['call']);
  //event.bus.fire(event.callQueueAdd, call);
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
  if(call.assignedAgent == configuration.userId) {
    event.bus.fire(event.localCallQueueAdd, call);
    event.bus.fire(event.callChanged, model.nullCall);
  }
}

void _callUnparkEventHandler(Map json) {
  model.Call call = new model.Call.fromJson(json['call']);
  event.bus.fire(event.localCallQueueRemove, call);
}

void _callOfferEventHandler(Map json) {
  final model.Call call = new model.Call.fromJson(json['call']);
  if(configuration.autoAnswerEnabled) {
    //TODO HACKY AUTO answer
    command.pickupNextCall(); 
  } else {
    event.bus.fire(event.callQueueAdd, call);
  }
  log.info('Opkalds tilbud. ${json['call']}', toUserLog: true);
}
