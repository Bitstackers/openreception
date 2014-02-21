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

library commands;

import 'dart:async';

import 'configuration.dart';
import 'events.dart' as event;
import 'environment.dart' as environment;
import 'logger.dart';
import 'model.dart'       as model;
import 'protocol.dart'    as protocol;
import 'storage.dart'     as storage;

const CONTACTID_TYPE = 1;
const PSTN_TYPE      = 2;
const SIP_TYPE       = 3;

/**
 * Originate [type] call to [address].
 */
void originateCall(String address, int type) {
  Future<protocol.Response> originateCallRequest;

//  switch(type) {
//    case CONTACTID_TYPE:
//      originateCallRequest = protocol.originateCall(agentId, cmId: int.parse(address));
//      break;
//
//    case PSTN_TYPE:
//      originateCallRequest = protocol.originateCall(agentId, pstnNumber: address);
//      break;
//
//    case SIP_TYPE:
//      originateCallRequest = protocol.originateCall(agentId, sip: address);
//      break;
//
//    default:
//      log.error('commands.originateCall INVALID TYPE ${type}');
//      return;
//  }

  originateCallRequest.then((protocol.Response response) {
    switch(response.status) {
      case protocol.Response.OK:
        log.debug('commands.originateCall OK ${address} (type: ${type})');
        break;

      default:
        log.critical('commands.originateCall ${address} (type: ${type}) failed with illegal response ${response}');
    }
  }).catchError((error) {
    log.critical('commands.originateCall ${address} (type: ${type}) protocol.originateCall failed with ${error}');
  });
}

/**
 * Pickup the next available call.
 */
void pickupNextCall() {
  protocol.pickupCall().then((protocol.Response response) {
    switch (response.status) {
      case protocol.Response.OK:
        log.debug('commands.pickupNextCall OK ${response.data['id']}');
        _pickupCallSuccess(response);
        break;

      case protocol.Response.NOTFOUND:
        log.debug('commands.pickupNextCall no calls found');
        break;

      default:
        log.critical('commands.pickupNextCall failed with illegal response ${response}');
    }
  }).catchError((error) {
    log.critical('commands.pickupNextCall protocol.pickupCall failed with ${error}');
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
    
    storage.getReception(receptionId).then((model.Reception reception) {
      if(reception == model.nullReception) {
        log.debug('commands._pickupCallSuccess NOT FOUND reception ${receptionId}');
      } else {
        //event.bus.fire(event.receptionChanged, reception);
      }
      
      log.debug('commands._pickupCallSuccess updated environment.reception to ${reception}');
      //log.debug('commands._pickupCallSuccess updated environment.contact to ${reception.contactList.first}');

    }).catchError((error) {
      environment.reception = model.nullReception;
      environment.contact = model.nullContact;

      log.critical('commands._pickupCallSuccess storage.getReception failed with with ${error}');
    });
  } else {
    environment.reception = model.nullReception;
    environment.contact = model.nullContact;

    log.critical('commands._pickupCallSuccess missing reception_id in ${json}');
  }
}

/**
 * Bridges two calls.
 */
void bridgeCall(model.Call a, model.Call b) {
//  protocol.transferCall(call).then((protocol.Response response) {
//    switch(response.status) {
//      case protocol.Response.OK:
//        log.info('commands.transferCall OK ${call}');
//        break;
//
//      case protocol.Response.NOTFOUND:
//        log.info('commands.transferCall NOT FOUND ${call}');
//        break;
//
//      default:
//        log.critical('commands.transferCall ${call} failed with illegal response ${response}');
//    }
//  }).catchError((error) {
//    log.critical('commands.transferCall ${call} protocol.transferCall failed with ${error}');
//  });
}
