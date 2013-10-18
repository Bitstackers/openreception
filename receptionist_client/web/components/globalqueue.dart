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

import 'package:polymer/polymer.dart';

import '../classes/common.dart';
import '../classes/commands.dart' as command;
import '../classes/events.dart' as event;
import '../classes/logger.dart';
import '../classes/model.dart' as model;
import '../classes/protocol.dart' as protocol;

@CustomTag('global-queue')
class GlobalQueue extends PolymerElement with ApplyAuthorStyle {
  @observable model.Call     call                 = model.nullCall;
  @observable model.CallList callQueue;
  @observable bool           hangupButtonDisabled = true;
  @observable bool           holdButtonDisabled   = true;
              model.Call     nullCall             = model.nullCall;
  @observable bool           pickupButtonDisabled = false;
  final       String         title                = 'Global kø';

  void created() {
    super.created();
    registerEventListerns();
    _initialFill();
  }

  void registerEventListerns() {
    event.bus.on(event.callChanged)
      .listen((model.Call value) => call = value);

    event.bus.on(event.callQueueAdd)
      .listen((model.Call call) => callQueue.addCall(call));

    event.bus.on(event.callQueueRemove)
      .listen((model.Call call) => callQueue.removeCall(call));
  }

  void _initialFill() {
    protocol.callQueue().then((protocol.Response response) {
      switch(response.status) {
        case protocol.Response.OK:
          Map callsjson = response.data;
          callQueue = new model.CallList.fromJson(callsjson, 'calls');
          log.debug('GlobalQueue._initialFill updated callQueue');
          break;

        default:
          callQueue = new model.CallList();
          log.debug('GlobalQueue._initialFill updated callQueue with empty list');
      }
    }).catchError((error) {
      callQueue = new model.CallList();
      log.critical('GlobalQueue._initialFill protocol.callQueue failed with ${error}');
    });
  }

  void _callChange(model.Call call) {
    pickupButtonDisabled = !(call == null || call == model.nullCall);
    hangupButtonDisabled = call == null || call == model.nullCall;
    holdButtonDisabled = call == null || call == model.nullCall;
  }

  void pickupnextcallHandler() {
    log.debug('GlobalQueue.pickupnextcallHandler');
    command.pickupNextCall();
  }

  void hangupcallHandler() {
    log.debug('GlobalQueue.hangupcallHandler');
    call.hangup();
  }

  void holdcallHandler() {
    log.debug('GlobalQueue.holdcallHandler');
    call.park();
  }
}
