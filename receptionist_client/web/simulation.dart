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

Controller.SimulationHotKeys key =
    new Controller.SimulationHotKeys(new Controller.HotKeys());

enum ReceptionistState { idle, hunting, activeCall, parkedCall, receivingCall }

///Important. Fill out this one with actual PSTN numbers.
List<String> calleeNumbers = [
  "1200@10.10.1.118:5100",
  "1201@10.10.1.118:5101",
  "1202@10.10.1.118:5102",
  "1203@10.10.1.118:5103",
  "1204@10.10.1.118:5104",
  "1205@10.10.1.118:5105",
  "1206@10.10.1.118:5106",
  "1207@10.10.1.118:5107",
  "1208@10.10.1.118:5108",
  "1209@10.10.1.118:5109",
];

/**
 * Automated simulation of the UI.
 *
 * TODO (KRC): Check for parked calls when idle.
 */
class _Simulation {
  static int seed = new DateTime.now().millisecondsSinceEpoch;
  static Random rand = new Random(seed);
  //Model.AppClientState _appState;

  final Logger log = new Logger('_Simulation');
  ReceptionistState _state = ReceptionistState.idle;
  Controller.Call _callController;

  ReceptionistState get state => _state;
  set state(ReceptionistState newState) {
    _state = newState;
    refreshInfo();
  }

  OListElement get callQueue => querySelector('#global-call-queue ol');

  OListElement get localCalls => querySelector('#my-call-queue ol');

  ORModel.Call get _activeCall {
    LIElement li = localCalls.querySelector('li.outbound');

    if (li == null) {
      return ORModel.Call.noCall;
    } else {
      return new ORModel.Call.fromMap(JSON.decode(li.dataset['object']));
    }
  }

  UListElement get _infoBox => querySelector('ul#simulation-info');

  ParagraphElement get _stateBox => querySelector('p#simulation-state');

  SpanElement get _showPstnBox => querySelector('#contact-data span.show-pstn');
  InputElement get _pstnInputField => querySelector('#contact-data input.pstn');

  bool get isInCall => querySelector('.greeting').classes.contains('incall');
  bool get hasParkedCalls =>
      querySelector('.greeting').classes.contains('incall');

  bool get callsInCallQueue => callQueue.children.length > 0;

  bool get hasLocalCalls => localCalls.children.length > 0;

  int get randomResponseTime => rand.nextInt(900) + 100;

  static dynamic _randomChoice(List pool) {
    if (pool.isEmpty) {
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
  checkState(Timer timer) {
    if (state != ReceptionistState.idle) {
      return new Future(() => null);
    }

    if (isInCall) {
      final Duration delay = new Duration(milliseconds: randomResponseTime);
      log.info(
          'Active call detected, hanging up after ${delay.inMilliseconds}ms');
      new Future.delayed(delay, hangupCall);
    } else if (hasLocalCalls) {
      state = ReceptionistState.parkedCall;
      final Duration delay = new Duration(milliseconds: randomResponseTime);
      log.info(
          'Calls detected in local call list, hanging up after ${delay.inMilliseconds}ms');

      new Future.delayed(delay, unParkAndHangup);
    } else if (callsInCallQueue) {
      state = ReceptionistState.hunting;
      final Duration delay = new Duration(milliseconds: randomResponseTime);
      log.info(
          'Calls detected in call list, hunting one after ${delay.inMilliseconds}ms');

      new Future.delayed(delay, tryPickup);
    }
  }

  /**
   *
   */
  void observers() {
    log.onRecord.listen((LogRecord rec) {
      if (_infoBox.children.length > 29) {
        _infoBox.children.first.remove();
      }

      _infoBox.append(new LIElement()..text = '$rec');
    });

    new Timer.periodic(new Duration(milliseconds: 1000), checkState);
  }

  /**
   *
   */
  Future continouslyPickup() async {
    Future tryWait() => _callController.commandStream.first
            .then((Controller.CallCommand command) {
          log.info('Got $command');
          if (command != Controller.CallCommand.pickup) {
            throw new StateError(
                'Expected pickup command, but recieved $command');
          }

          return command;
        }).timeout(new Duration(milliseconds: 1000));

    key.numPlus();

    try {
      await tryWait();
      return;
    } on TimeoutException {
      log.warning('Controller ignored our key press (+), trying again');
    }

    key.numPlus();

    try {
      await tryWait();
      return;
    } on TimeoutException {
      log.warning('Controller ignored our key press (+), trying again');
    }

    key.numPlus();

    try {
      await tryWait();
      return;
    } on TimeoutException {
      log.warning('Controller ignored our key press (+), trying again');
    }

    throw new TimeoutException('Failed to pickup call within the given time.');
  }

  Future unParkAndHangup() async {
    log.info('Trying to pickup parked call');

    // Pickup call.
    try {
      await continouslyUnPark();
    } on TimeoutException {
      if (isInCall) {
        log.shout('Pickup failed while still in call, hangin it up in 1s');
        new Future.delayed(new Duration(milliseconds: 1000), hangupCall);
      } else {
        log.shout(
            'Call was hung up before we could park it, returning to idle');
        state = ReceptionistState.idle;
      }
      return;
    }

    final Controller.CallCommand response =
        await _callController.commandStream.first;

    if (response == Controller.CallCommand.pickupSuccess) {
      log.info('Got a call, expecting the UI to update.');
      state = ReceptionistState.receivingCall;

      new Future.delayed(new Duration(milliseconds: 10), hangupCall);
    } else if (response == Controller.CallCommand.pickupFailure) {
      log.warning('Pickup failed, expecting checkState to clear up the mess.');
      state = ReceptionistState.idle;
    } else {
      throw new StateError('Expected pickup response, but recieved $response');
    }
  }

  /**
   *
   */
  Future tryPickup() async {
    log.info('Trying to pickup');

    // Pickup call.
    try {
      await continouslyPickup();
    } on TimeoutException {
      if (isInCall) {
        log.shout('Park failed while still in call, hangin it up in 1s');
        new Future.delayed(new Duration(milliseconds: 1000), hangupCall);
      } else {
        log.shout(
            'Call was hung up before we could park it, returning to idle');
        state = ReceptionistState.idle;
      }
      return;
    }

    final Controller.CallCommand response =
        await _callController.commandStream.first;

    if (response == Controller.CallCommand.pickupSuccess) {
      log.info('Got a call, expecting the UI to update.');
      state = ReceptionistState.receivingCall;

      new Future.delayed(new Duration(milliseconds: 10), expectCall);
    } else if (response == Controller.CallCommand.pickupFailure) {
      log.warning('Pickup failed, trying again later.');
      state = ReceptionistState.idle;
    } else {
      throw new StateError('Expected pickup response, but recieved $response');
    }
  }

  /**
   *
   */
  void start(Controller.Call cc, Model.AppClientState as) {
    _callController = cc;

    setup();
    observers();
    log.info('Started simulation mode. DO NOT USE the interface manully!');
  }

  /**
   * Expect a call to be received.
   *
   * TODO (KRC): Handle condition where hangup happens before it is transferred to
   *   the agent
   */
  void expectCall() {
    refreshInfo();

    if (isInCall) {
      log.info('Recieved a call, hanging it up immidiately.');
      state = ReceptionistState.activeCall;

      /// Determine what to do with the call.
      final int action = _randomChoice(new List.generate(10, (int i) => i));

      /// Take a message
      if (action < 5) {
        log.info('Callee wants us to take a message');
        new Future.delayed(new Duration(milliseconds: 1000), hangupCall);
      }

      /// Try to perform a transfer.
      else {
        log.info('Callee wants us to perform a transfer');
        new Future.delayed(new Duration(milliseconds: 1000), tryTransfer);
      }
    }
  }

  /**
   *
   */
  Future hangupCall() async {
    Future sub = _callController.commandStream.first;

    key.numDiv();

    Controller.CallCommand command;

    try {
      command = await sub.timeout(new Duration(seconds: 1));
    } on TimeoutException {
      if (isInCall) {
        log.shout('Hangup failed while still in call, trying again in 1s');
        new Future.delayed(new Duration(milliseconds: 1000), hangupCall);
      } else {
        log.shout('Call was hung up before we could, returning to idle');
        state = ReceptionistState.idle;
      }
      return;
    }

    if (command != Controller.CallCommand.hangup) {
      throw new StateError('Expected hangup command, but recieved $command');
    }

    final Controller.CallCommand response =
        await _callController.commandStream.first;

    if (response == Controller.CallCommand.hangupSuccess) {
      log.info('Hung up call, returning to idle.');
      _state = ReceptionistState.idle;
    } else if (response == Controller.CallCommand.hangupFailure) {
      log.warning('Hangup failed! Expecting call to be hung up already.');
      _state = ReceptionistState.idle;
    } else {
      throw new StateError('Expected hangup response, but recieved $response');
    }
  }

  Future<Controller.CallCommand> _awaitAnyOf(
          List<Controller.CallCommand> callCommands,
          {Duration timeout: const Duration(seconds: 10)}) =>
      _callController.commandStream.firstWhere(callCommands.contains)
      as Future<Controller.CallCommand>;

  Future<bool> _performOrigination() async {
    await new Future.delayed(new Duration(seconds: 1));
    _showPstnBox.click();
    _pstnInputField.value = _randomChoice(calleeNumbers);

    await continouslyDial();
    final Controller.CallCommand response =
        await _callController.commandStream.first;

    if (response == Controller.CallCommand.dialSuccess) {
      log.info('Dial success!');

      _state = ReceptionistState.activeCall;
    } else if (response == Controller.CallCommand.dialFailure) {
      _state = ReceptionistState.ACTIVE_CALL;
    } else if (response == Controller.CallCommand.PARK) {
      final Controller.CallCommand response =
          await _callController.commandStream.first;
      if (response == Controller.CallCommand.DIALSUCCESS) {
        log.info('Dial success!');
        _state = ReceptionistState.ACTIVE_CALL;
      } else if (response == Controller.CallCommand.DIALFAILURE) {
        log.warning('Dial failed! Don\'t known what do to next!');
      }
    } else if (response == Controller.CallCommand.DIALFAILURE) {
      log.warning('Dial failed! Don\'t known what do to next!');
    } else {
      throw new StateError('Expected dial response, but recieved $response');
    }

    return await _outboundCallOK().whenComplete(_showPstnBox.click);
  }

  /**
   * Poll and wait for the call to be picked up, hung up or just timed out.
   */
  Future _outboundCallOK() async {
    final Duration timeout = new Duration(seconds: 6);
    final Duration period = new Duration(milliseconds: 500);

    bool gotCall = false;
    try {
      await Future.doWhile(() async {
        await new Future.delayed(period);

        log.info(_activeCall.state);

        if (_activeCall == ORModel.Call.noCall) {
          log.info('Call hung up, returning');

          return false;
        }

        if (_activeCall.state == ORModel.CallState.Speaking) {
          log.info('Call answered!');
          gotCall = true;

          return false;
        }

        return true;
      }).timeout(timeout);
    } on TimeoutException {
      if (isInCall) {
        log.info(
            'Call was not answered within ${timeout.inMilliseconds}ms. Hanging it up');
        await hangupCall();
      }

      return false;
    }

    return gotCall;
  }

  /**
   *
   */
  Future continouslyDial() async {
    Future tryWait() async {
      Future reply = _awaitAnyOf([Controller.CallCommand.dial]);
      key.numMult();
      await reply;
    }

    try {
      await tryWait();
      return;
    } on TimeoutException {
      log.warning('Controller ignored our key press (*), trying again');
    }

    key.numMult();

    try {
      await tryWait();
      return;
    } on TimeoutException {
      log.warning('Controller ignored our key press (*), trying again');
    }

    key.numMult();

    try {
      await tryWait();
      return;
    } on TimeoutException {
      log.warning('Controller ignored our key press (*), trying again');
    }
  }

  /**
   *
   */
  Future continouslyPark() async {
    Future tryWait() => _callController.commandStream.first
            .then((Controller.CallCommand command) {
          log.info('Got $command');
          if (command != Controller.CallCommand.park) {
            throw new StateError(
                'Expected park command, but recieved $command');
          }

          return command;
        }).timeout(new Duration(milliseconds: 1000));

    key.f7();

    try {
      await tryWait();
      return;
    } on TimeoutException {
      log.warning('Controller ignored our key press (F7), trying again');
    }

    key.f7();

    try {
      await tryWait();
      return;
    } on TimeoutException {
      log.warning('Controller ignored our key press (F7), trying again');
    }

    key.f7();

    try {
      await tryWait();
      return;
    } on TimeoutException {
      log.warning('Controller ignored our key press (F7), trying again');
    }

    throw new TimeoutException('Failed to park call within the given time.');
  }

  /**
   *
   */
  Future continouslyUnPark() async {
    Future tryWait() => _callController.commandStream.first
            .then((Controller.CallCommand command) {
          log.info('Got $command');
          if (command != Controller.CallCommand.pickup) {
            throw new StateError(
                'Expected PICKUP command, but recieved $command');
          }

          return command;
        }).timeout(new Duration(milliseconds: 1000));

    key.f8();

    try {
      await tryWait();
      return;
    } on TimeoutException {
      log.warning('Controller ignored our key press (F8), trying again');
    }

    key.f8();

    try {
      await tryWait();
      return;
    } on TimeoutException {
      log.warning('Controller ignored our key press (F8), trying again');
    }

    key.f8();

    try {
      await tryWait();
      return;
    } on TimeoutException {
      log.warning('Controller ignored our key press (F8), trying again');
    }
  }

  /**
   *
   */
  Future _continouslyTransfer() async {
    Future tryWait() => _callController.commandStream.first
            .then((Controller.CallCommand command) {
          log.info('Got $command');
          if (command != Controller.CallCommand.transfer) {
            throw new StateError(
                'Expected TRANSFER command, but recieved $command');
          }

          return command;
        }).timeout(new Duration(milliseconds: 1000));

    key.ctrlNumMinus();

    try {
      await tryWait();
      return;
    } on TimeoutException {
      log.warning('Controller ignored our key press (Ctrl-), trying again');
    }

    key.ctrlNumMinus();

    try {
      await tryWait();
      return;
    } on TimeoutException {
      log.warning('Controller ignored our key press (Ctrl-), trying again');
    }

    key.ctrlNumMinus();

    try {
      await tryWait();
      return;
    } on TimeoutException {
      log.warning('Controller ignored our key press (Ctrl-), trying again');
    }
  }

  Future _performTransfer() async {
    await _continouslyTransfer();

    final Controller.CallCommand responsep =
        await _callController.commandStream.first;

    if (responsep == Controller.CallCommand.transferSuccess) {
      log.info('Transferred call. Returning to idle');
      state = ReceptionistState.idle;
    } else if (responsep == Controller.CallCommand.transferFailure) {
      log.warning('Transfer failed, trying again later.');
      state = ReceptionistState.idle;
    } else {
      throw new StateError('Expected pickup response, but recieved $responsep');
    }
  }

  /**
   *
   */
  Future tryTransfer() async {
    log.info('Parking call.');
    // Park call.
    try {
      await continouslyPark();
    } on TimeoutException {
      if (isInCall) {
        log.shout('Park failed while still in call, hangin it up in 1s');
        new Future.delayed(new Duration(milliseconds: 1000), hangupCall);
      } else {
        log.shout(
            'Call was hung up before we could park it, returning to idle');
        state = ReceptionistState.idle;
      }
      return;
    }

    log.info('Waiting response.');
    final Controller.CallCommand response =
        await _callController.commandStream.first;

    log.info('got response.');
    if (response == Controller.CallCommand.parkSuccess) {
      log.info('Parked call. expecting the UI to update.');
      state = ReceptionistState.parkedCall;
    } else if (response == Controller.CallCommand.parkFailure) {
      log.warning('Pickup failed, trying again later.');

      /// TODO (KRC): Reschedule.
    } else {
      throw new StateError('Expected park response, but recieved $response');
    }

    if (await _performOrigination()) {
      log.info('Outbound call is ready, performing transfer in 1 second');
      new Future.delayed(new Duration(milliseconds: 1000), _performTransfer);
      return;
    }

    // Pickup the call again.
    await continouslyUnPark();

    final Controller.CallCommand responsep =
        await _callController.commandStream.first;

    if (responsep == Controller.CallCommand.pickupSuccess) {
      log.info('Got a call, expecting the UI to update.');
      state = ReceptionistState.receivingCall;

      new Future.delayed(new Duration(milliseconds: 10), expectCall);
    } else if (responsep == Controller.CallCommand.pickupFailure) {
      log.warning('Pickup failed, trying again later.');
      state = ReceptionistState.idle;
    } else {
      throw new StateError('Expected pickup response, but recieved $responsep');
    }

    /// Hangup the call.
    new Future.delayed(new Duration(milliseconds: 1000), hangupCall);
  }

  /**
   *
   */
  void setup() {
    hierarchicalLoggingEnabled = true;
    _callController.commandStream.listen((Controller.CallCommand command) {
      log.finest('Got $command');
    });

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

    querySelector('body').insertBefore(root, querySelector('#orc-ready'));
  }
}
