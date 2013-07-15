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

import 'package:intl/intl.dart';
import 'package:web_ui/web_ui.dart';

import '../classes/environment.dart' as environment;
import '../classes/logger.dart';
import '../classes/model.dart' as model;
import '../classes/notification.dart' as notify;
import '../classes/protocol.dart' as protocol;

class LocalQueue extends WebComponent {
  List<model.Call> calls = toObservable(<model.Call>[]);

  String title = 'Lokal kø';

  void created() {
    _initialFill();
  }

  void _initialFill() {
    // dummy calls
    //calls.add(new model.Call.fromJson({'id':'43','arrival_time':'${new DateFormat("y-MM-dd kk:mm:ss").format(new DateTime.now())}'}));
    //calls.add(new model.Call.fromJson({'id':'42','arrival_time':'${new DateFormat("y-MM-dd kk:mm:ss").format(new DateTime.now().subtract(new Duration(seconds:27)))}'}));
    calls.add(new model.Call.fromJson({'id':'43','arrival_time':'${(new DateTime.now().millisecondsSinceEpoch/1000).toInt()}'}));
    calls.add(new model.Call.fromJson({'id':'42','arrival_time':'${(new DateTime.now().subtract(new Duration(seconds:27)).millisecondsSinceEpoch/1000).toInt()}'}));

    calls.sort();

    notify.notification.callPark.listen((json) => _callParkEventHandler(json));
    notify.notification.queueLeave.listen((json) => _queueLeaveEventHandler(json));
  }


  /**
   * Sends the parked call to the localqueue.
   */
  void _callParkEventHandler(Map json){
    model.Call call = new model.Call.fromJson(json['call']);

    calls.add(call);
  }

  /**
   * If a call from the local queue leaves.
   */
  void _queueLeaveEventHandler(Map json){
    log.debug('localqueue._queueLeaveEventHandler ${json}');
    var call = new model.Call.fromJson(json['call']);
    //Find the call and removes it from the calls list.
    for (var c in calls) {
      if (c.id == call.id) {
        calls.remove(c);
        break;
      }
    }
  }
}
