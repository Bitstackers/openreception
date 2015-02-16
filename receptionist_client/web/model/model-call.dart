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

final Call nullCall = new Call._null();

class InvalidCallState extends StateError {

  InvalidCallState (String message) : super (message);
}

class CallState {
  final String _name;

  static final CallState UNKNOWN      = new CallState._internal ('unknown'.toUpperCase());
  static final CallState CREATED      = new CallState._internal ('created'.toUpperCase());
  static final CallState RINGING      = new CallState._internal ('ringing'.toUpperCase());
  static final CallState QUEUED       = new CallState._internal ('queued'.toUpperCase());
  static final CallState HUNGUP       = new CallState._internal ('hungup'.toUpperCase());
  static final CallState TRANSFERRING = new CallState._internal ('transferring'.toUpperCase());
  static final CallState TRANSFERRED  = new CallState._internal ('TRANSFERRED');
  static final CallState SPEAKING     = new CallState._internal ('speaking'.toUpperCase());
  static final CallState PARKED       = new CallState._internal ('parked'.toUpperCase());

  static final List<CallState> _validStates =
       [UNKNOWN, CREATED, RINGING, QUEUED, HUNGUP, TRANSFERRING,
        TRANSFERRED, SPEAKING, PARKED];

  /**
   * Default private constructor.
   */
  CallState._internal (this._name);

  /**
   * Basic constructor. Normalizes the "enum" and performs checks.
   */
  factory CallState (String name) {

    CallState newItem = new CallState._internal(name.toUpperCase());

    if (!_validStates.contains (newItem)) {
      throw new InvalidCallState(newItem.toString());
    }

    return newItem;
  }

  @override
  operator == (CallState other) {
    return this._name == other._name;
  }

  @override
  int get hashCode {
    return this._name.hashCode;
  }


  @override
  String toString () {
    return this._name;
  }

  static CallState parse (String value) {
    return new CallState(value);
  }
}

/**
 * A call.
 */
class Call implements Comparable {

  static const String className = "${libraryName}.Call";

  static final EventType currentCallChanged = new EventType();
  static final EventType hungup      = new EventType();
  static final EventType answered    = new EventType();
  static final EventType parked      = new EventType();
  static final EventType queueLeave  = new EventType();
  static final EventType transferred = new EventType();
  static final EventType stateChange = new EventType();
  static final EventType<bool> lock  = new EventType<bool>();

  static final Map<CallState, EventType> stateEventMap =
    {CallState.HUNGUP      : Call.hungup,
     CallState.SPEAKING    : Call.answered,
     CallState.PARKED      : Call.parked,
     CallState.TRANSFERRED : Call.transferred};

  EventBus _bus = new EventBus();
  EventBus get events => _bus;

  Map _data = {};
  CallState _currentState = CallState.UNKNOWN;
  String _bLeg;
  String _callerID;
  String _destination;
  bool _greetingPlayed = false;
  String _ID;
  bool _inbound;
  DateTime _start;
  int _receptionID;

  static Call _currentCall = nullCall;

  int get assignedAgent => this._data['assigned_to'];
  bool get isCall => this._data['is_call'];
  String get bLeg => _bLeg;
  String get callerId => _callerID;
  String get destination => _destination;
  bool get greetingPlayed => _greetingPlayed;
  String get ID => this._data['id'];
  bool get inbound => _inbound;
  DateTime get start => _start;
  int get receptionId => _receptionID;
  CallState get state => CallState.parse(this._data['state']);

  static Call get currentCall => _currentCall;

  static set currentCall(Call newCall) {
    _currentCall = newCall;
    event.bus.fire(currentCallChanged, _currentCall);
  }

  bool get isActive => this != nullCall;

  /**
   * [Call] constructor. Expects a map in the following format:
   *
   *  {
   *    'assigned_to' : String,
   *    'id'          : String,
   *    'start'       : DateTime String
   *  }
   *
   * 'assigned_to' is the String agent ID. 'id' is the ID of the call.'start'
   * is a timestamp of when the call was started. It MUST be in a format that
   * can be parsed by the [DateTime.parse] method.
   *
   * TODO Obviously the above map format should be in the docs/wiki, and completed.
   */
  Call.fromMap(Map map) {

    if (map.containsKey('reception_id') && map['reception_id'] != null) {
      _receptionID = map['reception_id'];
    }

    if (map.containsKey('b_leg')) {
      _bLeg = map['b_leg'];
    }

    if (map.containsKey('caller_id')) {
      _callerID = map['caller_id'];
    }

    if (map.containsKey('destination')) {
      _destination = map['destination'];
    }

    if (map.containsKey('inbound')) {
      _inbound = map['inbound'];
    }

    if (map.containsKey('greeting_played')) {
      _greetingPlayed = map['greeting_played'];
    }

    _ID = map['id'];

    log.debug('Model.call Call.fromJson: ${map['arrival_time']} => ${new DateTime.fromMillisecondsSinceEpoch(map['arrival_time']*1000)}');
    _start = new DateTime.fromMillisecondsSinceEpoch(map['arrival_time'] * 1000);

    this._data = map;
    }

  /**
   * Determine whether or not a call available for the user.
   *
   */
  bool availableForUser(ORModel.User user) {
    //return this.assignedAgent == user.ID || this.assignedAgent == User.nullUser.ID
    return ([ORModel.User.nullID, user.ID].contains(this.assignedAgent));
  }

  void update (Call newCall) {
    const String context = '${className}.update';

    /* Update the current internal dataset */
    this._data = newCall._data;

    log.debugContext("${this.ID}: NewState: ${this.state}", context);

    /* Perfom a state change. */
    this._bus.fire(Call.stateEventMap[this.state], null);
  }

  /**
   * [Call] null constructor.
   */
  Call._null() {
    _ID = null;
    _start = null;
  }

  Call.stub(this._ID);

  /**
   * Enables a [Call] to sort itself compared to other calls.
   */
  int compareTo(Call other) => _start.compareTo(other._start);


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
    if (this == nullCall) {
      log.debug('Cowardly refusing ask the call-flow-control server to hangup a null call.');
      return;
    }

    Controller.Call.hangup(this);
  }

  /**
   * Park call.
   */
  void park() {

    // See note on assertions.
    if (this == nullCall) {
      log.debug('Cowardly refusing ask the call-flow-control server to park a null call.');
      return;
    }
    Controller.Call.park(this);
  }

  /**
   * Park call.
   */
  void transfer(Call destination) {

    // See note on assertions.
    if (this == nullCall) {
      log.debug('Cowardly refusing ask the call-flow-control server to park a null call.');
      return;
    }
    Controller.Call.transfer (this, destination);
  }

  /**
   * Pickup call.
   */
  void pickup() {

    // See note on assertions.
    if (this == nullCall) {
      log.debug('Cowardly refusing ask the call-flow-control server to pickup a null call.');
      return;
    }

    Controller.Call.pickupSpecific(this);

  }

  /**
   * [Call] as String, for debug/log purposes.
   */
  String toString() => 'Call ${this.ID} - ${_start} - ${this.state}';
}
