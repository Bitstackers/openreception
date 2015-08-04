/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.client.simulation;

import 'dart:async';
import 'dart:html';
import 'dart:convert';
import 'controller/controller.dart' as Controller;
import 'package:logging/logging.dart';
import 'package:openreception_framework/model.dart' as ORModel;

_Simulation simulation = new _Simulation();

enum ReceptionistState { IDLE, HUNTING, ACTIVE_CALL, PARKED_CALL }

class _Simulation {
  final Logger log = new Logger('_Simulation');
  ReceptionistState state = ReceptionistState.IDLE;
  Controller.Call _callController;

  OListElement get callQueue =>
      querySelector('#global-call-queue').querySelector('ol');

  bool get callsInCallQueue => callQueue.children.length > 0;

  void checkForCall(Timer timer) {
    if (state != ReceptionistState.IDLE) {
      return;
    }

    if (callsInCallQueue) {
      state = ReceptionistState.HUNTING;
//      ORModel.Call huntedCall = new ORModel.Call.fromMap(
//          JSON.decode(callQueue.children.first.dataset['object']));
    _callController.pickupNext();
    }
  }

  void observers() {
    new Timer.periodic(new Duration(milliseconds: 1000), checkForCall);
  }

  void start(Controller.Call cc) {
    _callController = cc;
    observers();
    print('Started simulation mode. DO NOT USE the interface manully!');
  }
}
