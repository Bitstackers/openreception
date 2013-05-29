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
import 'model.dart' as model;
import 'protocol.dart' as protocol;
import 'storage.dart' as storage;

const CONTACTID_TYPE = 1;
const PSTN_TYPE = 2;
const SIP_TYPE = 3;

//TODO check up on the documentation. Today 20 feb 2013. did it wrongly say:
//     POST /call/hangup[?call_id=<call_id>]
//The call_id was not optional.
/**
 * TODO comment
 */
void hangupCall(model.Call call) {
  log.debug('hangupCall ${call.id}');

  protocol.hangupCall(call).then((protocol.Response response) {
    switch(response.status){
      case protocol.Response.OK:
        log.debug('hangupCall OK ${call.id}');
        environment.organization.set(model.nullOrganization);
        break;

      case protocol.Response.NOTFOUND:
        log.debug('hangupCall NOT FOUND ${call.id}');
        break;

      default:
        log.error('hangupCall ERROR ${call.id}');
    }
  });
}

/**
 * TODO comment
 */
void holdCall(int callId) {
  protocol.holdCall(callId).then((protocol.Response response) {
    switch(response.status) {
      case protocol.Response.OK:
        log.debug('holdCall OK ${callId}');
        break;

      case protocol.Response.NOTFOUND:
        log.info('holdCall NOT FOUND  ${callId}');
        break;

      default:
        //TODO Do something.
    }
  });
}

/**
 * TODO comment
 */
void originateCall(String address, int type) {
  int agentId = configuration.agentID;
  Future<protocol.Response> originateCallRequest;

  switch(type){
    case CONTACTID_TYPE:
      originateCallRequest = protocol.originateCall(agentId, cmId: int.parse(address));
      break;

    case PSTN_TYPE:
      originateCallRequest = protocol.originateCall(agentId, pstnNumber: address);
      break;

    case SIP_TYPE:
      originateCallRequest = protocol.originateCall(agentId, sip: address);
      break;

    default:
      log.error('originateCall INVALID TYPE ${type}');
      return;
  }

  originateCallRequest.then((protocol.Response response) {
    switch(response.status) {
      default:
        //TODO Do something.
    }
  });
}

/**
 * Sends a request to Alice, to pickup the call for this Agent.
 *
 * If successful it then sets the environment to the call.
 */
void pickupCall(model.Call call) {
  log.debug('pickupCall ${call.id}');

  protocol.pickupCall(configuration.agentID, callId: call.id.toString()).then((protocol.Response response) {
    switch (response.status){
      case protocol.Response.OK:
        log.debug('pickupCall OK ${call.id}');
        _pickupCallSuccess(response.data);
        break;

      default:
        //TODO do something.
    }
  });
}

/**
 * TODO comment
 */
void _pickupCallSuccess(Map response) {
  log.info('pickupCall: ${response}');

  if (response.containsKey('organization_id')) {
    int orgId = response['organization_id'];

    storage.organization.get(orgId, (org) => environment.organization.set(org),
        onError:() => log.critical('pickupCall->storage.organization.get ERROR ${orgId}'));
  } else {
    log.critical('pickupCall NO organizatio_id KEY FOUND ${response}');
    environment.organization.set(model.nullOrganization);
  }
}

/**
 * TODO comment
 */
void pickupNextCall() {
  log.debug('pickupNextCall'); // TODO append agent information

  protocol.pickupCall(configuration.agentID).then((protocol.Response response) {
    switch (response.status){
      case protocol.Response.OK:
        log.debug('pickupNextCall OK'); // TODO append agent information
        _pickupCallSuccess(response.data);
        break;

      default:
        //TODO do something.
    }
  });
}

/**
 * TODO comment
 */
void transferCall(int callId) {
  protocol.transferCall(callId).then((protocol.Response response) {
    switch(response.status) {
      default:
        //TODO Do something.
    }
  });
}
