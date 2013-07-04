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
import 'dart:html';
import 'dart:json' as json;

import 'configuration.dart';
import 'environment.dart' as environment;
import 'logger.dart';
import 'model.dart' as model;
import 'protocol.dart' as protocol;
import 'storage.dart' as storage;

const CONTACTID_TYPE = 1;
const PSTN_TYPE      = 2;
const SIP_TYPE       = 3;

/**
 * Hangup the [call].
 */
void hangupCall(model.Call call) {
  log.debug('Hangup call ${call.id}');

  protocol.hangupCall(call).then((protocol.Response response) {
    switch(response.status){
      case protocol.Response.OK:
        log.debug('Hangup call OK ${call.id}');

        // Obviously we don't want to reset the organization on every hangup, but for
        // now this is here to remind us to do _something_ on hangup. I suspect
        // resetting to nullOrganization will become annoying when the time comes.  :D
        environment.organization.set(model.nullOrganization);
        break;

      case protocol.Response.NOTFOUND:
        log.debug('Hangup call NOT FOUND ${call.id}');
        break;

      default:
        log.error('Hangup call ERROR ${call.id}');
    }
  }).catchError((error) {
    // TODO do something
  });
}

/**
 * Put the [call] on hold.
 */
void holdCall(model.Call call) {
  log.debug('Hold call ${call}');

  protocol.holdCall(call).then((protocol.Response response) {
    switch(response.status) {
      case protocol.Response.OK:
        log.debug('Hold call OK ${call}');
        break;

      case protocol.Response.NOTFOUND:
        log.debug('Hold call NOT FOUND  ${call}');
        break;

      default:
        log.error('Hold call ERROR ${call}');
    }
  }).catchError((error) {
    // TODO do something
  });
}

/**
 * Originate [type] call to [address].
 */
void originateCall(String address, int type) {
  String agentId = configuration.agentID;
  Future<protocol.Response> originateCallRequest;

  log.debug('Originate call ${address} (type: ${type})');

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
      log.error('Originate call INVALID TYPE ${type}');
      return;
  }

  originateCallRequest.then((protocol.Response response) {
    switch(response.status) {
      default:
        //TODO Do something.
    }
  }).catchError((error) {
    // TODO do something
  });
}

/**
 * Pickup the [model.Call] [call]
 *
 * If successful set environment organization.
 */
void pickupCall(model.Call call) {
  log.debug('Pickup call ${call.id}');

  protocol.pickupCall(configuration.agentID, call: call).then((protocol.Response response) {
    switch (response.status){
      case protocol.Response.OK:
        _pickupCallSuccess(response);
        log.debug('Pickup call OK ${call.id}');
        break;

      default:
        log.error('commands.pickupCall ERROR protocol.pickupCall failed with${call.id}');
    }
  }).catchError((error) {
    log.error('commands.pickupCall ERROR protocol.pickupCall failed with ${error}');
  });
}

/**
 * Set environment.organization.current to the [model.Organization] found in
 * the [response]. If [response] does not contain a valid organization_id, then
 * log the error and set environment.organization.current to [model.nullOrganization].
 */
void _pickupCallSuccess(protocol.Response response) {
  Map json = response.data;

  if (json.containsKey('organization_id')) {
    int orgId = json['organization_id'];

    storage.getOrganization(orgId).then((model.Organization org) {
      environment.organization.set(org);

      if(org == model.nullOrganization) {
        log.error('commands.pickupCall NOT FOUND organization ${orgId}');
      }
    }).catchError((error) {
      environment.organization.set(model.nullOrganization);
      log.critical('commands.pickupCall ERROR failed with with ${error}');
    });
  } else {
    environment.organization.set(model.nullOrganization);
    log.critical('commands.pickupCall ERROR missing organization_id in ${json}');
  }
}

/**
 * Pickup the next available call.
 */
void pickupNextCall() {
  log.debug('Pickup next call');

  protocol.pickupCall(configuration.agentID).then((protocol.Response response) {
    switch (response.status){
      case protocol.Response.OK:
        _pickupCallSuccess(response);
        log.debug('Pickup next call OK ${response.data['call_id']}');
        break;

      default:
        log.error('Pickup next call ERROR ${response.data['call_id']}');
    }
  }).catchError((error) {
    // TODO do something
  });
}

/**
 * Transfer [call] call.
 */
void transferCall(model.Call call) {
  protocol.transferCall(call).then((protocol.Response response) {
    switch(response.status) {
      default:
        //TODO Do something.
    }
  }).catchError((error) {
    // TODO do something
  });
}
