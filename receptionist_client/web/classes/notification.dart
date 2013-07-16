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
import 'environment.dart' as environment;
import 'logger.dart';
import 'model.dart' as model;
import 'socket.dart';
import 'storage.dart' as storage;
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
                                                 'queue_leave':new StreamController<Map>.broadcast(),
                                                 'call_park'  :new StreamController<Map>.broadcast()};

  Stream<Map> get callHangup => _Streams['call_hangup'].stream;
  Stream<Map> get callPickup => _Streams['call_pickup'].stream;
  Stream<Map> get queueJoin  => _Streams['queue_join'].stream;
  Stream<Map> get queueLeave => _Streams['queue_leave'].stream;
  Stream<Map> get callPark   => _Streams['call_park'].stream;

  /**
   * [_Notification] constructor.
   */
  _Notification() {
    _socket = new Socket()
        ..onMessage.listen(_onMessage);

    _registerEventListeners();
  }

  /**
   * Handles non-persistent notifications.
   */
  void _nonPersistentNotification(Map json) {
    log.debug('nonpersistent');

    if (!json.containsKey('event')) {
      log.critical('nonPersistensNotification did not have a event field.');
    }
    String eventName = json['event'];
    log.debug('notification with event: ${eventName}');

    if (_Streams.containsKey(eventName)) {
      _Streams[eventName].sink.add(json);
    }else{
      log.error('Unhandled event: ${eventName}');
      log.debug(json.toString());
    }
  }

  /**
   * Handles all notifications from from Alice, and dispatches them according to
   * their persistence status.
   */
  void _onMessage(Map json) {
    log.debug('notification._onMessage ${json}');

    if (!json.containsKey('notification')) {
      log.critical('does not contains notification');
      return;
    }
    Map notificationMap = json['notification'];

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
   * Register event listeners.
   */
  void _registerEventListeners() {
    callHangup.listen((Map json) => _callHangupEventHandler(json));
    callPickup.listen((Map json) => _callPickupEventHandler(json));
    queueJoin.listen((Map json) => _queueJoinEventHandler(json));
    queueLeave.listen((Map json) => _queueLeaveEventHandler(json));
  }
}

/**
 * Hangup [environment.call] when a call_hangup notification that matches
 * [environment.call] is received on the notification socket.
 */
void _callHangupEventHandler(Map json) {
  log.debug('notification._callHangupEventHandler received ${json}');

  model.Call call = new model.Call.fromJson(json['call']);

  if (call.id == environment.call.id) {
    environment.call = model.nullCall;
    environment.organization = model.nullOrganization;
    environment.contact = model.nullContact;

    log.info('notification._callHangupEventHandler hangup call ${call}');
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
    environment.call = call;

    log.debug('notification._callPickupEventHandler updated environment.call to ${call}');

    if (call.organizationId != null) {
      storage.getOrganization(call.organizationId).then((org) {
        environment.organization = org;
        environment.contact = environment.organization.contactList.first;

        log.debug('notification._callPickupEventHandler updated environment.organization to ${org}');
        log.debug('notification._callPickupEventHandler updated environment.contact to ${org.contactList.first}');
      }).catchError((error) {
        environment.organization = model.nullOrganization;
        environment.contact = model.nullContact;

        log.critical('notification._callPickupEventHandler storage.getOrganization failed with ${error}');
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
  environment.callQueue.addCall(new model.Call.fromJson(json['call']));
  // Should we sort again, or can we expect that calls joining the queue are
  // always younger then the calls already in the queue?
}

/**
 * Handles queue_leave events.
 */
void _queueLeaveEventHandler(Map json) {
  log.debug('notification._queueLeaveEventHandler event: ${json}');
  final model.Call call = new model.Call.fromJson(json['call']);
  environment.callQueue.removeCall(call);
}
