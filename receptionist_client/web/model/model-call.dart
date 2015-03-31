/*                  This file is part of OpenReception
                   Copyright (C) 2012-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

/*
 * Note on removal of assertions.
 *
 * Rather than having an assertion (or more accurately; an implicit precondition) here, and
 * having to perform manual checks from the outside of the object, it makes more sense to
 * just ignore the call.
 */


part of model;

final Call noCall = new Call._null();

class InvalidCallState extends StateError {

  InvalidCallState (String message) : super (message);
}

enum CallState {
  UNKNOWN,
  CREATED,
  RINGING,
  QUEUED,
  HUNGUP,
  TRANSFERRING,
  TRANSFERRED,
  SPEAKING,
  PARKED,
  LOCKED,
  UNLOCKED
}

Map<String,CallState> ORCallStateToCallState = {
  ORModel.CallState.Unknown : CallState.UNKNOWN,
  ORModel.CallState.Created : CallState.CREATED,
  ORModel.CallState.Ringing : CallState.RINGING,
  ORModel.CallState.Queued  : CallState.QUEUED,
  ORModel.CallState.Unparked : CallState.TRANSFERRING,
  ORModel.CallState.Hungup  : CallState.HUNGUP,
  ORModel.CallState.Transferring : CallState.TRANSFERRING,
  ORModel.CallState.Transferred : CallState.TRANSFERRED,
  ORModel.CallState.Speaking : CallState.SPEAKING,
  ORModel.CallState.Parked :CallState.PARKED,
};

/**
 * A call.
 */
class Call extends ORModel.Call implements Comparable {

  static final Logger log = new Logger ('${libraryName}.Call');
  static final noCall = new Call._null();

  static Call _activeCall = noCall;
  static Bus<Call> _activeCallChanged = new Bus<Call>();
  static Stream<Call> get activeCallChanged => _activeCallChanged.stream;

  Bus<CallState> _callState = new Bus<CallState>();
  Stream<CallState> get callState => _callState.stream;

  static Call get activeCall => _activeCall;

  static set activeCall(Call newCall) {
    _activeCall = newCall;
    _activeCallChanged.fire(_activeCall);
    log.finest('Changing active call to ${_activeCall.ID}:');
  }

  bool get isActive => this != noCall;

  CallState _currentState = CallState.UNKNOWN;
  CallState get currentState  => _currentState;

  set currentState (CallState newState) {
    this._currentState = newState;
    this._callState.fire(newState);
  }

  /**
   * [Call] constructor. Merely forwards to the framework contructor.
   */
  Call.fromMap(Map map) : super.fromMap(map);

  /**
   * [Call] constructor.
   * TODO: Optimize this one.
   */
  Call.fromORModel(ORModel.Call call) : this.fromMap(call.toJson());


  /**
   * Determine whether or not a call available for the user.
   *
   */
  bool availableForUser(User user) =>
    ([User.noID, user.ID].contains(this.assignedTo));

  void update (Call newInfo) {
    bool oldLockState = this.locked;

    /// Update local fields with new information.
    this.assignedTo = newInfo.assignedTo;
    this.b_Leg = newInfo.b_Leg;
    this.contactID = newInfo.contactID;
    this.greetingPlayed = newInfo.greetingPlayed;

    if (oldLockState != this.locked) {
      /* Notify of state change. */
      this.currentState = this.locked ? CallState.LOCKED : CallState.UNLOCKED;
    } else {
      this.currentState = ORCallStateToCallState[newInfo.state.toString()];
    }
  }

  /**
   * [Call] null constructor.
   */
  Call._null() : super.stub({ORModel.CallJsonKey.ID : ORModel.Call.nullCallID});

  /**
   * Enables a [Call] to sort itself compared to other calls.
   */
  int compareTo(Call other) => this.arrived.compareTo(other.arrived);

  /**
   * TODO: Document.
   */
  bool operator ==(Call other) {
    return this.ID == other.ID;
  }

  /**
   * TODO: Document.
   */
  int get hashCode {
    return this.ID.hashCode;
  }

  /**
   * Returns the caller ID of the foreign end of the caller from the user's perspective.
   */
  String otherLegCallerID() {
    if (this.inbound) {
      return this.destination;
    } else {
      return this.destination;
    }
  }

  /**
   * Hangup the [call].
   */
  void hangup() {

    // See note on assertions.
    if (this == noCall) {
      log.info('Cowardly refusing ask the call-flow-control server to hangup a null call.');
      return;
    }

    Controller.Call.hangup(this);
  }

  /**
   * Park call.
   */
  void park() {

    // See note on assertions.
    if (this == noCall) {
      log.info('Cowardly refusing ask the call-flow-control server to park a null call.');
      return;
    }
    Controller.Call.park(this);
  }

  /**
   * Park call.
   */
  void transfer(Call destination) {

    // See note on assertions.
    if (this == noCall) {
      log.info('Cowardly refusing ask the call-flow-control server to park a null call.');
      return;
    }
    Controller.Call.transfer (this, destination);
  }

  /**
   * Pickup call.
   */
  void pickup() {

    // See note on assertions.
    if (this == noCall) {
      log.info('Cowardly refusing ask the call-flow-control server to pickup a null call.');
      return;
    }

    Controller.Call.pickup(this);

  }

  /**
   * [Call] as String, for debug/log purposes.
   */
  String toString() => this == noCall
                       ? 'no Call'
                       : 'Call ID:${this.ID}, state:${this.state}, '
                         'destination:${this.destination}';

}
