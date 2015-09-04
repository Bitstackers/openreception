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

///Important. Fill out this one with actual PSTN numbers.
List<String> calleeNumbers = [];

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


  UListElement get _infoBox => querySelector('ul#simulation-info');

  ParagraphElement get _stateBox => querySelector('p#simulation-state');

  bool get isInCall => querySelector('.greeting').classes.contains('incall');
  bool get hasParkedCalls => querySelector('.greeting').classes.contains('incall');

  bool get callsInCallQueue => callQueue.children.length > 0;

  bool get hasLocalCalls => localCalls.children.length > 0;

  int get randomResponseTime => rand.nextInt(900) + 100;

  static dynamic _randomChoice (List pool) {
    if(pool.isEmpty) {
      throw new ArgumentError('Cannot find a random value in an empty list');
    }

    int index = rand.nextInt(pool.length);

    return pool[index];
  }
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
      log.info('Calls detected in call list, hunting one.');

      new Future.delayed(
          new Duration(milliseconds: randomResponseTime), tryPickup);
    }
  }

  /**
   *
   */
  void observers() {
    log.onRecord.listen((LogRecord rec) {
      if (_infoBox.children.length > 9) {
        _infoBox.children.first.remove();
      }

      _infoBox.append(new LIElement()..text = '$rec');
    });

    new Timer.periodic(new Duration(milliseconds: 1000), checkState);
  }

  /**
   *
   */
  void tryPickup() {
    _callController.pickupNext().then((ORModel.Call call) {
      log.info('Trying to pickup');
      // No call were available, just retutn to idle state again.
      if (call == ORModel.Call.noCall) {
        state = ReceptionistState.IDLE;
        log.info('No call awailable.');
      }
      else {
        log.info('Got a call, expecting the UI to update.');
        state = ReceptionistState.RECEIVING_CALL;
      }

      new Future.delayed(new Duration(milliseconds: 10), expectCall);
    }).catchError((_) {
      log.info('No call awailable.');
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
      log.info('Recieved a call, hanging it up immidiately.');
      state = ReceptionistState.ACTIVE_CALL;

      _callController.dial(_randomChoice(calleeNumbers),
          ORModel.Reception.selectedReception, ORModel.Contact.selectedContact);

      new Future.delayed(new Duration(milliseconds: 1000), hangupCall);
    }
  }

  /**
   *
   */
  void hangupCall () {
    _callController.hangup(_appState.activeCall).then((_) {
      log.info('Hung up call, returning to idle.');
      _state = ReceptionistState.IDLE;

    });
  }

  /**
   *
   */
  void setup() {
    hierarchicalLoggingEnabled = true;

    DivElement root = new DivElement()
      ..id = 'simulation-overlay'
      ..style.margin = '5%'
      ..style.position = 'absolute'
      ..style.width = '90%'
      ..style.zIndex = '999'
      ..style.backgroundColor = 'rgba(255,255,255,0.65)'
      ..children = [
        new HeadingElement.h1()..text = 'Simulation mode. DO NOT USE INTERFACE',
        new ParagraphElement()..id = 'simulation-state',
        new UListElement()..id = 'simulation-info'
        ];

    querySelector('body').insertBefore(root, querySelector('#receptionistclient-ready'));
  }
}
