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

part of openreception.framework.model;

/**
 * Enumeration type for call states.
 */
abstract class CallState {
  static const String unknown = 'UNKNOWN';
  static const String created = 'CREATED';
  static const String ringing = 'RINGING';
  static const String queued = 'QUEUED';
  static const String unparked = 'UNPARKED';
  static const String hungup = 'HUNGUP';
  static const String transferring = 'TRANSFERRING';
  static const String transferred = 'TRANSFERRED';
  static const String speaking = 'SPEAKING';
  static const String parked = 'PARKED';
}

/**
 * Class representing a call in the system. Every call is identified by a
 * unique id (uuid) that may be used as a handle for REST service method calls.
 */
class Call {
  static const String className = '${libraryName}.Call';
  static final Logger _log = new Logger(Call.className);

  static final Call noCall = new Call.empty(noId);
  static final String noId = '';

  final Bus<String> _callState = new Bus<String>();
  final Bus<Event.CallEvent> _eventBus = new Bus<Event.CallEvent>();

  DateTime arrived = new DateTime.now();
  DateTime answeredAt = Util.never;
  int assignedTo = User.noId;
  String bLeg = null;
  String callerId = '';
  int cid = BaseContact.noId;
  String destination = '';
  bool greetingPlayed = false;
  String _id = noId;
  bool inbound = null;
  bool _locked = false;
  int rid = Reception.noId;
  String _state = CallState.unknown;
  String hangupCause = '';

  /**
   * Constructor.
   */
  Call.empty(this._id);

  /**
   * Constructor.
   */
  factory Call.fromMap(Map map) => new Call.empty(map[Key.id])
    .._state = map[PbxKey.state]
    ..answeredAt = Util.unixTimestampToDateTime(map[Key.answeredAt])
    ..bLeg = map[Key.bLeg]
    .._locked = map[Key.locked]
    ..inbound = map[Key.inbound]
    ..destination = map[Key.destination]
    ..callerId = map[Key.callerId]
    ..greetingPlayed = map[Key.greetingPlayed]
    ..rid = map[ORPbxKey.receptionId]
    ..cid = map[ORPbxKey.contactId]
    ..assignedTo = map[Key.assignedTo]
    ..arrived = Util.unixTimestampToDateTime(map[Key.arrivalTime]);

  /**
   *
   */
  @override
  bool operator ==(Object other) => other is Call && _id == other._id;

  /**
   *
   */
  void assignTo(User user) {
    assignedTo = user.id;
  }

  /**
   *
   */
  Stream<String> get callState => _callState.stream;

  /**
   *
   */
  void changeState(String newState) {
    final String lastState = _state;

    _state = newState;

    _log.finest('UUID: ${_id}: ${lastState} => ${newState}');

    if (lastState == CallState.queued) {
      notifyEvent(new Event.QueueLeave(this));
    } else if (lastState == CallState.parked) {
      notifyEvent(new Event.CallUnpark(this));
    }

    switch (newState) {
      case (CallState.created):
        notifyEvent(new Event.CallOffer(this));
        break;

      case (CallState.parked):
        notifyEvent(new Event.CallPark(this));
        break;

      case (CallState.unparked):
        notifyEvent(new Event.CallUnpark(this));
        break;

      case (CallState.queued):
        notifyEvent(new Event.QueueJoin(this));
        break;

      case (CallState.hungup):
        notifyEvent(new Event.CallHangup(this, hangupCause: hangupCause));
        break;

      case (CallState.speaking):
        notifyEvent(new Event.CallPickup(this));
        break;

      case (CallState.transferred):
        notifyEvent(new Event.CallTransfer(this));
        break;

      case (CallState.ringing):
        notifyEvent(new Event.CallStateChanged(this));
        break;

      case (CallState.transferring):
        break;

      default:
        _log.severe('Changing call ${this} to Unkown state!');
        break;
    }
  }

  /**
   * Note: The channel is a unique identifier.
   *   Remember to change, if ID changes.
   */
  String get channel => _id;

  /**
   * The Unique identification of the call
   */
  String get id => _id;

  /**
   *
   */
  String get state => _state;

  /**
   *
   */
  set state(String newState) {
    _state = newState;
    _callState.fire(newState);
  }

  /**
   *
   */
  Stream<Event.CallEvent> get event => _eventBus.stream;

  /**
   *
   */
  @override
  int get hashCode => _id.hashCode;

  /**
   *
   */
  bool get isActive => this != noCall;

  /**
   *
   */
  void link(Call other) {
    if (locked) locked = false;

    bLeg = other._id;
    other.bLeg = _id;
  }

  /**
   *
   */
  bool get locked => _locked;

  /**
   *
   */
  void set locked(bool lock) {
    _locked = lock;

    if (lock) {
      notifyEvent(new Event.CallLock((this)));
    } else {
      notifyEvent(new Event.CallUnlock(this));
    }
  }

  /**
   *
   */
  void notifyEvent(Event.Event event) => _eventBus.fire(event);

  /**
   *
   */
  void release() {
    assignedTo = User.noId;
  }

  /**
   * String version of [Call] for debug/log purposes.
   */
  @override
  String toString() => this == noCall
      ? 'no Call'
      : 'CallId: ${_id}, state: ${_state}, destination: ${destination}';

  /**
   *
   */
  Map toJson() => {
        Key.id: _id,
        PbxKey.state: _state,
        Key.bLeg: bLeg,
        Key.locked: locked,
        Key.inbound: inbound,
        Key.destination: destination,
        Key.callerId: callerId,
        Key.greetingPlayed: greetingPlayed,
        ORPbxKey.receptionId: rid,
        ORPbxKey.contactId: cid,
        Key.assignedTo: assignedTo,
        Key.channel: channel,
        Key.arrivalTime: Util.dateTimeToUnixTimestamp(arrived),
        Key.answeredAt: Util.dateTimeToUnixTimestamp(answeredAt)
      };

  /**
   *
   */
  static void validateID(String callId) {
    if (callId == null || callId.isEmpty) {
      throw new FormatException('Invalid CallId: ${callId}');
    }
  }
}
