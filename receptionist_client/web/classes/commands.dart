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
void pickupCall(int id) {
  log.info('Sending request to pickup ${id.toString()}');

  new protocol.PickupCall(configuration.agentID, callId: id.toString())
      ..onResponse((protocol.Response response){
        switch (response.status){
          case protocol.Response.OK:
            _pickupCallSuccess(response.data);
            break;

          default:
            //TODO do something.
        }
      })
      ..send();
}

void pickupNextCall() {
  log.info('Sending request to pickup the next call');

  new protocol.PickupCall(configuration.agentID)
    ..onResponse((protocol.Response response){
      switch (response.status){
        case protocol.Response.OK:
          _pickupCallSuccess(response.data);
          break;

        default:
          //TODO do something.
      }
    })
    ..send();
}

void _pickupCallSuccess(Map response) {
  log.info('pickupCall: ${response}');

  if (!response.containsKey('organization_id')) {
    log.critical('The call had no organization_id: ${response}');
  }

  int orgId = response['organization_id'];

  storage.organization.get(orgId, (org) => environment.organization.set(org),
      onError:() => log.critical('Pickup call. Could not fetch organization.'));
}

//TODO check up on the documentation. Today 20 feb 2013. did it wrongly say:
//     POST /call/hangup[?call_id=<call_id>]
//The call_id was not optional.
void hangupCall(int callId){
  log.debug('The command hangupCall is called with callid: ${callId}');
  new protocol.HangupCall(callId:callId.toString())
    ..onResponse((protocol.Response response) {
      switch(response.status){
        case protocol.Response.OK:
          log.debug('Hangup call: ${callId} successed');
          break;

        case protocol.Response.NOTFOUND:
          log.debug('There were no call to hangup with Callid: ${callId}');
          break;

        default:
          log.error('There were an error with hangup. Callid: ${callId}');
      }
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
      ..onResponse((protocol.Response response) {
        switch(response.status) {
          default:
            //TODO Do something.
        }
      })
      ..send();
}

void transferCall(int callId){
  new protocol.TransferCall(callId)
      ..onResponse((protocol.Response response) {
        switch(response.status) {
          default:
            //TODO Do something.
        }
      })
      ..send();
}

/**
 * TODO comment
 */
void holdCall(int callId){
  new protocol.HoldCall(callId)
    ..onResponse((protocol.Response response) {
      switch(response.status) {
        case protocol.Response.OK:
          log.debug('The request to hold call: ${callId} succeeded');
          break;

        case protocol.Response.NOTFOUND:
          log.info('There is no call with id: ${callId} to hold.');
          break;

        default:
          //TODO Do something.
      }
    })
    ..send();
}
