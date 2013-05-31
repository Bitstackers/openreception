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

import 'dart:html';
import 'dart:json' as json;

import 'package:intl/intl.dart';
import 'package:web_ui/web_ui.dart';

import '../classes/commands.dart' as command;
import '../classes/environment.dart' as environment;
import '../classes/logger.dart';
import '../classes/model.dart' as model;
import '../classes/notification.dart' as notify;
import '../classes/protocol.dart' as protocol;

class GlobalQueue extends WebComponent {
  List<model.Call> calls = toObservable(<model.Call>[]);
  @observable bool hangupButtonDisabled = true;
  @observable bool holdButtonDisabled   = true;
  @observable bool pickupButtonDisabled = false;

  String title = 'Global kø';

  void created() {
    _initialFill();
    _registerSubscribers();
  }

  void _initialFill() {
    protocol.callQueue().then((protocol.Response response) {
      switch(response.status){
        case protocol.Response.OK:
          Map callsjson = response.data;
          log.debug('Initial filling of call queue gave ${callsjson['calls'].length} calls');
          for (var call in callsjson['calls']) {
            calls.add(new model.Call.fromJson(call));
          }
          break;

        case protocol.Response.NOTFOUND:
          log.debug('Initial Filling of callqueue. Request returned empty.');
          break;

        default:
          //TODO do something.
      }
    });

    // dummy calls
    calls.add(new model.Call.fromJson({'id':'2','start':'${new DateFormat("y-MM-dd kk:mm:ss").format(new DateTime.now())}'}));
    calls.add(new model.Call.fromJson({'id':'3','start':'${new DateFormat("y-MM-dd kk:mm:ss").format(new DateTime.now().subtract(new Duration(seconds:5)))}'}));
    calls.add(new model.Call.fromJson({'id':'1','start':'${new DateFormat("y-MM-dd kk:mm:ss").format(new DateTime.now().subtract(new Duration(seconds:12)))}'}));

    calls.sort();
  }

  void _registerSubscribers() {
    notify.notification.addEventHandler('queue_join', _queueJoin);
    notify.notification.addEventHandler('queue_leave', _queueLeave);
  }

  void _queueJoin(Map json) {
    calls.add(new model.Call.fromJson(json['call']));
    // Should we sort again, or can we expect that calls joining the queue are
    // always younger then the calls already in the queue?
  }

  void _queueLeave(Map json) {
    var call = new model.Call.fromJson(json['call']);
    //Find the call and removes it from the calls list.
    for (var c in calls) {
      if (c.id == call.id) {
        calls.remove(c);
        break;
      }
    }
  }

  void _callChange(model.Call call){
    pickupButtonDisabled = !(call == null || call == model.nullCall);
    hangupButtonDisabled = call == null || call == model.nullCall;
    holdButtonDisabled = call == null || call == model.nullCall;
  }

  void pickupnextcallHandler() {
    log.debug('pickupnextcallHandler');
    command.pickupNextCall();
  }

  void hangupcallHandler() {
    log.debug('hangupcallHandler');
    command.hangupCall(environment.call.current);
  }

  void holdcallHandler() {
    log.debug('holdcallHandler');
    command.hangupCall(environment.call.current);
  }
}
