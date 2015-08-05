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
import 'dart:math' show Random;

import 'controller/controller.dart' as Controller;
import 'model/model.dart' as Model;
import 'package:logging/logging.dart';
import 'package:openreception_framework/model.dart' as ORModel;

_Simulation simulation = new _Simulation();

enum ReceptionistState {
  IDLE,
  HUNTING,
  ACTIVE_CALL,
  PARKED_CALL,
  RECEIVING_CALL
}

/**
 * Automated simulation of the UI.
 */
class _Simulation {
  static int seed = new DateTime.now().millisecondsSinceEpoch;
  static Random rand = new Random(seed);
  Model.AppClientState    _appState;

  final Logger log = new Logger('_Simulation');
  ReceptionistState _state = ReceptionistState.IDLE;
  Controller.Call _callController;


  ReceptionistState get state => _state;
  set state(ReceptionistState newState) {
    _state = newState;
    refreshInfo();
  }

  OListElement get callQueue =>
      querySelector('#global-call-queue ol');

  OListElement get localCalls =>
      querySelector('#my-call-queue ol');


  ParagraphElement get _infoBox => querySelector('p#simulation-info');

  ParagraphElement get _stateBox => querySelector('p#simulation-state');

  bool get isInCall => querySelector('.greeting').classes.contains('incall');
  bool get hasParkedCalls => querySelector('.greeting').classes.contains('incall');

  bool get callsInCallQueue => callQueue.children.length > 0;

  bool get hasLocalCalls => localCalls.children.length > 0;

  int get randomResponseTime => rand.nextInt(900) + 100;

  void refreshInfo() {
    _stateBox.text = '${_state} (in call:$isInCall)';
  }

  /**
   *
   */
  void checkState(Timer timer) {
    if (state != ReceptionistState.IDLE) {
      return;
    }

    if (callsInCallQueue) {
      state = ReceptionistState.HUNTING;

      new Future.delayed(
          new Duration(milliseconds: randomResponseTime), tryPickup);
    }
  }

  /**
   *
   */
  void observers() {
    new Timer.periodic(new Duration(milliseconds: 1000), checkState);
  }

  /**
   *
   */
  void tryPickup() {
    _callController.pickupNext().then((ORModel.Call call) {
      // No call were available, just retutn to idle state again.
      if (call == ORModel.Call.noCall) {
        state = ReceptionistState.IDLE;
      }

      state = ReceptionistState.RECEIVING_CALL;

      new Future.delayed(new Duration(milliseconds: 100), expectCall);
    }).catchError((_) {
      state = ReceptionistState.IDLE;
    });
  }

  /**
   *
   */
  void start(Controller.Call cc, Model.AppClientState as) {
    _callController = cc;
    _appState = as;
    setup();
    observers();
    log.info('Started simulation mode. DO NOT USE the interface manully!');
  }

  /**
   * Expect a call to be received.
   *
   * TODO: Handle condition where hangup happens before it is transferred to
   *   the agent
   */
  void expectCall() {
    refreshInfo();

    if (isInCall) {
      state = ReceptionistState.ACTIVE_CALL;
      new Future.delayed(new Duration(milliseconds: 100), hangupCall);
    }
  }

  /**
   *
   */
  void hangupCall () {
    _callController.hangup(_appState.activeCall).then((_) {

      _state = ReceptionistState.IDLE;

    });
  }

  /**
   *
   */
  void setup() {
    DivElement root = new DivElement()
      ..id = 'simulation-overlay'
      ..style.marginLeft = '30%'
      ..style.position = 'absolute'
      ..style.width = '400px'
      ..style.zIndex = '999'
      ..style.backgroundColor = 'white'
      ..children = [
        new HeadingElement.h1()..text = 'Simulation mode. DO NOT USE INTERFACE',
        new ParagraphElement()..id = 'simulation-state',
        new ParagraphElement()..id = 'simulation-info'
        ];

    querySelector('body').insertBefore(root, querySelector('#receptionistclient-ready'));
  }
}
