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

library environment;

import 'dart:async';
import 'dart:collection';

import 'package:web_ui/web_ui.dart';

import 'common.dart';
import 'configuration.dart';
import 'context.dart';
import 'logger.dart';
import 'model.dart' as model;
import 'notification.dart' as notify;
import 'storage.dart' as storage;

@observable String                 activeWidget     = '';
@observable model.Contact          contact          = model.nullContact;
@observable model.Organization     organization     = model.nullOrganization;
@observable model.OrganizationList organizationList = model.nullOrganizationList;

final _Call         call         = new _Call();
final _ContextList  contextList  = new _ContextList();

/**
 * The currently active call.
 */
class _Call{
  model.Call _call = model.nullCall;

  model.Call get current => _call;

  /**
   * _Call constructor.
   */
  _Call() {
    _registerEventListeners();
  }

  /**
   * Hangup the currently active [Call] when a call_hangup notification is
   * received.
   */
  void _callHangupEventHandler(Map json) {
    model.Call call = new model.Call.fromJson(json['call']);

    if (call.id == _call.id) {
      log.info('Hangup call ${call.id}');
      set(model.nullCall);
    }
  }

  /**
   * Set the currently active [Call] when a call_pickup notification is received
   * and the assigned agent match the logged in agent.
   */
  void _callPickupEventHandler(Map json) {
    model.Call call = new model.Call.fromJson(json['call']);

    // TODO obviously the agent ID should not come from configuration. This is a
    // temporary hack as long as Alice is oblivious to login/session.
    if (call.assignedAgent == configuration.agentID) {
      set(call);
      if (call.organizationId != null){
        storage.getOrganization(call.organizationId).then((org){
          if (org != null && org != model.nullOrganization){
            organization = org;
          }
        });
      }
    }else{
      log.info('Agent ${call.assignedAgent} answered call ${call.id}');
    }
  }

  /**
   * Registers event listeners.
   */
  void _registerEventListeners() {
    notify.notification.callHangup.listen((json) => _callHangupEventHandler(json));
    notify.notification.callPickup.listen((json) => _callPickupEventHandler(json));
  }

 /**
  * Set the currently active [call].
  */
  void set(model.Call call) {
    if (call != _call) {
      _call = call;
      log.info('Current Call ${call}');

      if (_call != null && _call != model.nullCall){
        log.info('Call answered ${_call.toString()}, dumpToUser: true');
      }
    }
  }
}

/**
 * A list of the application contexts.
 */
class _ContextList extends IterableBase<Context>{
  List<Context>        _list = toObservable(<Context>[]);
  Map<String, Context> _map  = new Map<String, Context>();

  Iterator<Context> get iterator => _list.iterator;

  /**
   * _ContextList constructor.
   */
  _ContextList();

  /**
   * Add [context] to the [_ContextList].
   */
  void add(Context context) {
    // We store the context twice. This is for fast lookup, so we don't have to
    // loop the list to find a context based on its id.
    _list.add(context);
    _map[context.id] = context;
  }

  /**
   * Return the [id] [Context].
   */
  Context get(String id) {
    if(_map.containsKey(id)) {
      return _map[id];
    }

    return null;
  }
}
