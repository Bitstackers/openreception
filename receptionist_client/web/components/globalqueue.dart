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
  @observable bool   hangupButtonDisabled = true;
  @observable bool   holdButtonDisabled   = true;
  @observable bool   pickupButtonDisabled = false;
  final       String title                = 'Global kø';

  void created() {
    _initialFill();
  }

  void _initialFill() {
    protocol.callQueue().then((protocol.Response response) {
      switch(response.status) {
        case protocol.Response.OK:
          Map callsjson = response.data;
          environment.callQueue = new model.CallList.fromJson(callsjson, 'calls');
          log.debug('GlobalQueue._initialFill updated environment.callQueue');
          break;

        default:
          environment.callQueue = new model.CallList();
          log.debug('GlobalQueue._initialFill updated environment.callQueue with empty list');
      }
    }).catchError((error) {
      environment.callQueue = new model.CallList();
      log.critical('GlobalQueue._initialFill protocol.callQueue failed with ${error}');
    });
  }

  void _callChange(model.Call call) {
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
    command.hangupCall(environment.call);
  }

  void holdcallHandler() {
    log.debug('holdcallHandler');
    command.hangupCall(environment.call);
  }
}
