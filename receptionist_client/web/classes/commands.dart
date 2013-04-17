/*                                Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This library is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License and
  a copy of the GCC Runtime Library Exception along with this program;
  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
  <http://www.gnu.org/licenses/>.
*/

library commands;

import 'dart:async';
import 'dart:html';
import 'dart:json' as json;

import 'configuration.dart';
import 'environment.dart' as environment;
import 'logger.dart';
import 'protocol.dart' as protocol;
import 'storage.dart' as storage;

/**
 * Sends a request to Alice, to pickup the call for this Agent.
 *
 * If successful it then sets the environment to the call.
 */
void pickupCall(int id){
  log.info('Sending request to pickup ${id.toString()}');
  new protocol.PickupCall(configuration.agentID, callId: id.toString())
      ..onSuccess(_pickupCallSuccess)
      ..onNoCall((){
        //TODO Do something
      })
      ..onError((){
        //Todo Do something
      })
      ..send();
}

void pickupNextCall(){
  log.info('Sending request to pickup the next call');
  new protocol.PickupCall(configuration.agentID)
    ..onSuccess(_pickupCallSuccess)
    ..onNoCall((){
      //TODO Do Something
    })
    ..onError((){
      //TODO Do Something
    })
    ..send();
}

void _pickupCallSuccess(String text) {
  log.info('pickupCall:${text}');
  var response = json.parse(text);
  if (!response.containsKey('organization_id')) {
    log.critical('The call had no organization_id. ${text}');
  }
  var orgId = response['organization_id'];
  storage.organization.get(orgId,(org) =>
      environment.organization.set((org != null) ? org : environment.organization));
}

//TODO check up on the documentation. Today 20 feb 2013. did it wrongly say:
//     POST /call/hangup[?call_id=<call_id>]
//The call_id was not optional.
void hangupCall(int callId){
  log.debug('The command hangupCall is called with callid: ${callId}');
  new protocol.HangupCall(callId:callId.toString())
    ..onSuccess((text){
      log.debug('Hangup call: ${callId} successed');
    })
    ..onNoCall((){
      //TODO Do Something
      log.debug('There ware no call with id: ${callId} to hangup.');
    })
    ..onError((){
      //TODO Do something
      log.error('There was an error with hangup. Callid: ${callId}');
    })
    ..send();
}

const CONTACTID_TYPE = 1;
const PSTN_TYPE = 2;
const SIP_TYPE = 3;
void originateCall(String address, int type){
  int agentId = configuration.agentID;
  protocol.OriginateCall originateCallRequest;

  switch(type){
    case CONTACTID_TYPE:
      originateCallRequest = new protocol.OriginateCall(agentId, cmId: int.parse(address));
      break;

    case PSTN_TYPE:
      originateCallRequest = new protocol.OriginateCall(agentId, pstnNumber: address);
      break;

    case SIP_TYPE:
      originateCallRequest = new protocol.OriginateCall(agentId, sip: address);
      break;

    default:
      log.error('Invalid originate type: ${type}');
      return;
  }

  originateCallRequest
      ..onSuccess((text) {
        //TODO Do something
      })
      ..onError((){
        //TODO Do Something
      })
      ..send();
}

void transferCall(int callId){
  new protocol.TransferCall(callId)
      ..onSuccess((text) {
        //TODO Do Something.
      })
      ..onError(() {
        //TODO Do Something.
      })
      ..send();
}

/**
 * TODO comment
 */
void holdCall(int callId){
  new protocol.HoldCall(callId)
    ..onSuccess((text){
      log.debug('The request to hold call: ${callId} succeeded');
    })
    ..onNoCall((){
      log.info('There is no call with id: ${callId} to hold.');
    })
    ..onError((){})
    ..send();
}
