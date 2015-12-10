/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of model;

enum AppState { LOADING, ERROR, READY }

class HungUp {
  final String callId;
  final DateTime timestamp;

  HungUp(String this.callId, DateTime this.timestamp);
}

class AppClientState {
  ORModel.Call _activeCall = ORModel.Call.noCall;
  final Bus<ORModel.Call> _activeCallChangeBus = new Bus<ORModel.Call>();
  ORModel.User _currentUser = new ORModel.User.empty();
  List<HungUp> _hungupCalls = new List<HungUp>();
  final Logger _log = new Logger('${libraryName}.AppClientState');
  final Duration _maxHungUpAge = new Duration(seconds: 60);
  final Controller.Notification _notification;
  final Bus<AppState> _stateChange = new Bus<AppState>();

  /**
   * Constructor.
   */
  AppClientState(Controller.Notification this._notification) {
    _observers();
  }

  /**
   *
   */
  Stream<ORModel.Call> get activeCallChanged => _activeCallChangeBus.stream;

  /**
   *
   */
  ORModel.Call get activeCall => _activeCall;

  /**
   *
   */
  set activeCall(ORModel.Call newCall) {
    if (_hungupCalls.any((HungUp hungUp) => hungUp.callId == newCall.ID)) {
      _activeCall = ORModel.Call.noCall;
    } else {
      _activeCall = newCall;
    }

    _activeCallChangeBus.fire(_activeCall);

    _log.finest(
        'Changing active call to ${_activeCall == ORModel.Call.noCall ? 'noCall' : _activeCall}');

    /// Clean up the hungup calls list.
    _hungupCalls.removeWhere(
        (HungUp hungUp) => hungUp.timestamp.difference(new DateTime.now()) > _maxHungUpAge);
  }

  /**
   * Change the application to [newState]
   */
  void changeState(AppState newState) {
    _stateChange.fire(newState);
  }

  /**
   *
   */
  ORModel.User get currentUser => _currentUser;

  /**
   *
   */
  set currentUser(ORModel.User newUser) => _currentUser = newUser;

  /**
   *
   */
  void _observers() {
    _notification.onAnyCallStateChange.listen((OREvent.CallEvent event) {
      if (event is OREvent.CallHangup && event.call.assignedTo == currentUser.ID) {
        _hungupCalls.add(new HungUp(event.call.ID, new DateTime.now()));
        activeCall = event.call;
      }
    });
  }

  /**
   * Listen for [AppState] change events.
   */
  Stream<AppState> get onStateChange => this._stateChange.stream;
}
