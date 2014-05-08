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

/*
 * Note on removal of assertions.
 * 
 * Rather than having an assertion (or more accurately; an implicit precondition) here, and
 * having to perform manual checks from the outside of the object, it makes more sense to
 * just ignore the call. 
 */


part of model;

final Call nullCall = new Call._null();

/**
 * A call.
 */
class Call implements Comparable {
  
  static const String className = "${libraryName}.Call";

  static final EventType currentCallChanged = new EventType();

  Map _data;
  
  int _assignedAgent;
  String _bLeg;
  String _callerID;
  String _destination;
  bool _greetingPlayed = false;
  String _ID;
  bool _inbound;
  DateTime _start;
  int _receptionID;

  static Call _currentCall = nullCall;

  int get assignedAgent => _assignedAgent;
  String get bLeg => _bLeg;
  String get callerId => _callerID;
  String get destination => _destination;
  bool get greetingPlayed => _greetingPlayed;
  String get ID => _ID;
  bool get inbound => _inbound;
  DateTime get start => _start;
  int get receptionId => _receptionID;

  static Call get currentCall => _currentCall;
  static set currentCall(Call newCall) {
    _currentCall = newCall;
    print("Call changed: ${newCall}");
    event.bus.fire(event.callChanged, _currentCall);
  }

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
    log.debug('Call.fromJson ${map}');
    if (map.containsKey('assigned_to') && map['assigned_to'] != null) {
      _assignedAgent = map['assigned_to'];
    }

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
    //_start = DateTime.parse(json['arrival_time']);
    log.debug('Model.call Call.fromJson: ${map['arrival_time']} => ${new DateTime.fromMillisecondsSinceEpoch(int.parse(map['arrival_time'])*1000)}');
    _start = new DateTime.fromMillisecondsSinceEpoch(int.parse(map['arrival_time']) * 1000);
    
    this._data = map;
  }
  
  void update (Map map) {
    this._data = map;
  }

  /**
   * [Call] null constructor.
   */
  Call._null() {
    _assignedAgent = null;
    _ID = null;
    _start = new DateTime.now();
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

    protocol.hangupCall(this).then((protocol.Response response) {
      switch (response.status) {
        case protocol.Response.OK:
          log.debug('model.Call.hangup OK ${this}');

          // Obviously we don't want to reset the reception on every hangup, but for
          // now this is here to remind us to do _something_ on hangup. I suspect
          // resetting to nullReception will become annoying when the time comes.  :D
          event.bus.fire(event.receptionChanged, nullReception);
          event.bus.fire(event.contactChanged, nullContact);

          log.debug('model.Call.hangup updated environment.reception to nullReception');
          log.debug('model.Call.hangup updated environment.contact to nullContact');
          break;

        case protocol.Response.NOTFOUND:
          log.error('model.Call.hangup() NOT FOUND ${this}');
          currentCall = nullCall;
          break;

        default:
          log.critical('model.Call.hangup ${this} failed with illegal response ${response}');
      }

      currentCall = nullCall;

    }).catchError((error) {
      log.critical('model.Call.hangup ${this} protocol.hangupCall failed with ${error}');
      //TODO Actively check state or go to panic-action. At this point we cannot derive anything about the state in the current scope.
    });
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
    protocol.parkCall(this).then((protocol.Response response) {
      switch (response.status) {
        case protocol.Response.OK:
          log.debug('model.Call.park OK ${this}');
          break;

        case protocol.Response.NOTFOUND:
          log.debug('model.Call.park NOT FOUND ${this}');
          break;

        default:
          log.critical('model.Call.park ${this} failed with illegal response ${response}');
      }
    }).catchError((error) {
      log.critical('model.Call.park ${this} protocol.parkCall failed with ${error}');
    });
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

    protocol.pickupCall(call: this).then((protocol.Response response) {
      switch (response.status) {
        case protocol.Response.OK:
          log.debug('model.Call.pickup OK ${this}');
          _pickupCallSuccess(response);
          break;

        case protocol.Response.NOTFOUND:
          log.debug('model.Call.pickupCall NOT FOUND ${this}');
          break;

        default:
          log.critical('model.Call.pickupCall ${this} failed with illegal response ${response}');
      }
    }).catchError((error) {
      log.critical('model.Call.pickupCall ${this} protocol.pickupCall failed with ${error}');
    });
  }

  /**
   * Update [environment.reception] and [environment.contact] according to the
   * [model.Reception] found in the [response].
   */
  void _pickupCallSuccess(protocol.Response response) {
    Map json = response.data;

    if (json.containsKey('reception_id')) {
      int receptionId = json['reception_id'];

      storage.Reception.get(receptionId).then((Reception reception) {
        if (reception == nullReception) {
          log.error('model.Call._pickupCallSuccess NOT FOUND reception ${receptionId}');
        }

        environment.reception = reception;
        //environment.contact = reception.contactList.first;

        log.debug('model.Call._pickupCallSuccess updated environment.reception to ${reception}');
        //log.debug('model.Call._pickupCallSuccess updated environment.contact to ${reception.contactList.first}');

      }).catchError((error) {
        environment.reception = nullReception;
        environment.contact = nullContact;

        log.critical('model.Call._pickupCallSuccess storage.getReception failed with with ${error}');
      });
    } else {
      environment.reception = nullReception;
      environment.contact = nullContact;

      log.critical('model.Call._pickupCallSuccess missing reception_id in ${json}');
    }
  }

  /**
   * [Call] as String, for debug/log purposes.
   */
  String toString() => 'Call ${_ID} - ${_start}';
}
