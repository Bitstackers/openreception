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

part of model;

final Call nullCall = new Call._null();

/**
 * A call.
 */
class Call implements Comparable {
  int      _assignedAgent;
  String   _bLeg;
  bool     _greetingPlayed = false;
  String   _id;
  bool     _inbound;
  DateTime _start;
  int      _receptionId;

  int      get assignedAgent  => _assignedAgent;
  String   get bLeg           => _bLeg;
  bool     get greetingPlayed => _greetingPlayed;
  String   get id             => _id;
  bool     get inbound        => _inbound;
  DateTime get start          => _start;
  int      get receptionId => _receptionId;

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
   * TODO Obviously the above map format should be in the docs/wiki, as it is
   * also highly relevant to Alice.
   */
  Call.fromJson(Map json) {
    log.debug('Call.fromJson ${json}');
    if(json.containsKey('assigned_to') && json['assigned_to'] != null) {
      _assignedAgent = json['assigned_to'];
    }

    if(json.containsKey('reception_id') && json['reception_id'] != null) {
      _receptionId = json['reception_id'];
    }

    if(json.containsKey('b_leg')) {
      _bLeg = json['b_leg'];
    }

    if(json.containsKey('inbound')) {
      _inbound = json['inbound'];
    }

    if(json.containsKey('greeting_played')) {
      _greetingPlayed = json['greeting_played'];
    }

    _id = json['id'];
    //_start = DateTime.parse(json['arrival_time']);
    log.debug('Model.call Call.fromJson: ${json['arrival_time']} => ${new DateTime.fromMillisecondsSinceEpoch(int.parse(json['arrival_time'])*1000)}');
    _start = new DateTime.fromMillisecondsSinceEpoch(int.parse(json['arrival_time'])*1000);
  }

  /**
   * [Call] null constructor.
   */
  Call._null() {
    _assignedAgent = null;
    _id = null;
    _start = new DateTime.now();
  }

  /**
   * Enables a [Call] to sort itself compared to other calls.
   */
  int compareTo(Call other) => _start.compareTo(other._start);

  /**
   * Hangup the [call].
   */
  void hangup() {
    assert(this != nullCall);
    protocol.hangupCall(this).then((protocol.Response response) {
      switch(response.status) {
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
          log.debug('model.Call.hangup NOT FOUND ${this}');
          break;

        default:
          log.critical('model.Call.hangup ${this} failed with illegal response ${response}');
      }
    }).catchError((error) {
      log.critical('model.Call.hangup ${this} protocol.hangupCall failed with ${error}');
    });
  }

  /**
   * Park call.
   */
  void park() {
    assert(this != nullCall);
    protocol.parkCall(this).then((protocol.Response response) {
      switch(response.status) {
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
    assert(this != nullCall);
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

      storage.getReception(receptionId).then((Reception reception) {
        if(reception == nullReception) {
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
  String toString() => 'Call ${_id} - ${_start}';
}
