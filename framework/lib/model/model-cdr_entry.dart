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

class PriceNotFound extends StateError {
  PriceNotFound(String msg) : super(msg);
}

class UnknownDestination extends StateError {
  UnknownDestination(String msg) : super(msg);
}

enum CdrEntryState {
  agentChannel,
  inboundNotNotified,
  notifiedAnsweredByAgent,
  notifiedNotAnswered,
  outboundByAgent,
  outboundByPbx,
  unknown
}

class CdrEntry {
  int agentBeginEpoch = 0;
  bool agentChannel = false;
  int agentEndEpoch = 0;
  int answerEpoch = 0;
  int billSec = 0;
  String bridgeUuid = '';
  bool callNotify = false; // NOTE: False can mean both false and not set.
  int cid = 0; // The contact id
  String contextCallId = '';
  String destination = '';
  String direction = '';
  int endEpoch = 0;
  int externalTransferEpoch = 0;
  String filename = '';
  String finalTransferAction = '';
  String hangupCause = '';
  bool ivr = false;
  bool receptionOpen = false; // NOTE: False can mean both false and not set.
  int rid = 0; // The reception id
  String sipFromUserStripped = '';
  int startEpoch = 0;
  int uid = 0; // The agent id
  String uuid = '';
  bool voicemail = false;

  /**
   * Constructor.
   *
   * Creates a CdrEntry object from [rawCdrJson], which must be a FreeSWITCH CDR
   * JSON.
   */
  CdrEntry(Map rawCdrJson, String cdrFilename) {
    final Map vars = rawCdrJson['variables'];
    final Map appLog =
        rawCdrJson.containsKey('app_log') ? rawCdrJson['app_log'] : null;

    cid = vars.containsKey(ORPbxKey.contactId)
        ? int.parse(vars[ORPbxKey.contactId])
        : 0;
    rid = vars.containsKey(ORPbxKey.receptionId)
        ? int.parse(vars[ORPbxKey.receptionId])
        : 0;
    uuid = vars[PbxKey.uuid];
    if (appLog != null) {
      callNotify = _callHasBeenNotified(appLog['applications'] as List<Map>);
      ivr = _ivrApp(appLog['applications'] as List<Map>);
    }

    agentChannel = vars.containsKey(ORPbxKey.agentChannel)
        ? vars[ORPbxKey.agentChannel] == 'true'
        : false;
    answerEpoch = int.parse(vars[PbxKey.answerEpoch]);
    bridgeUuid = vars.containsKey(PbxKey.bridgeUuid)
        ? vars[PbxKey.bridgeUuid]
        : vars.containsKey(PbxKey.signalBond)
            ? vars[PbxKey.signalBond]
            : vars.containsKey(PbxKey.originateSignalBond)
                ? vars[PbxKey.originateSignalBond]
                : '';
    contextCallId = vars.containsKey(ORPbxKey.contextCallId)
        ? vars[ORPbxKey.contextCallId]
        : '';
    destination = _extractDestination(rawCdrJson);
    direction = vars[PbxKey.direction];
    endEpoch = int.parse(vars[PbxKey.endEpoch]);
    filename = path.basename(cdrFilename);
    hangupCause = vars[PbxKey.hangupCause];
    receptionOpen = vars.containsKey(ORPbxKey.receptionOpen)
        ? vars[ORPbxKey.receptionOpen] == 'true'
        : false;
    sipFromUserStripped = vars.containsKey(PbxKey.sipFromUserStripped)
        ? vars[PbxKey.sipFromUserStripped]
        : '';
    startEpoch = int.parse(vars[PbxKey.startEpoch]);
    voicemail = vars.containsKey('current_application')
        ? vars['current_application'] == 'voicemail' ? true : false
        : false;

    if (direction == 'inbound' && vars.containsKey('transfer_history')) {
      _extractTransferHistoryData(vars['transfer_history']);
    }

    /// Set billSec.
    if (agentChannel) {
      /// This is an agent channel. No billing.
      billSec = 0;
    } else {
      if (direction == 'outbound') {
        /// This is an outbound call to an external number. In this case billing
        /// seconds can be assumed to match up with what FreeSWITCH is telling
        /// us.
        billSec = int.parse(vars[PbxKey.billSec]);
      } else {
        if (externalTransferEpoch > 0 && agentBeginEpoch > 0) {
          /// This is an inbound call that has been answered by an agent and
          /// ultimately transferred to an external number.
          billSec = externalTransferEpoch - agentBeginEpoch;
        } else if (externalTransferEpoch == 0 && agentBeginEpoch > 0) {
          /// This is an inbound call that has been answered and hungup by an
          /// agent.
          billSec = endEpoch - agentBeginEpoch;
        } else {
          /// This is an inbound call that has not been answered by an agent. It
          /// may or may not have been transferred to an external number by the
          /// PBX.
          /// Setting billing seconds to zero, since billing might be handled by
          /// the potential outbound CDR.
          billSec = 0;
        }
      }
    }

    /// Don't move this block up. It depends on having the finalTransferAction
    /// extracted by_extractTransferHistoryData().
    /// We search for the uid in various places because setting it on the event
    /// socket can fail due to race conditions when calls are abruptly/quickly
    /// disconnected.
    if (vars.containsKey(ORPbxKey.userId)) {
      uid = int.parse(vars[ORPbxKey.userId]);
    } else if (finalTransferAction.startsWith('uuid_br:agent')) {
      /// Example: uuid_br:agent-20-1455786790547
      uid = int.parse(finalTransferAction.split('-')[1]);
    } else if (direction == 'outbound' && bridgeUuid.startsWith('agent-')) {
      /// Example: agent-9-1455876216119
      uid = int.parse(bridgeUuid.split('-')[1]);
    } else {
      uid = 0;
    }
  }

  /**
   * JSON constructor.
   */
  CdrEntry.fromJson(Map json) {
    agentBeginEpoch = json[key.CdrKey.agentBeginEpoch];
    agentChannel = json[key.CdrKey.agentChannel];
    agentEndEpoch = json[key.CdrKey.agentEndEpoch];
    answerEpoch = json[key.CdrKey.answerEpoch];
    billSec = json[key.CdrKey.billSec];
    bridgeUuid = json[key.CdrKey.bridgeUuid];
    callNotify = json[key.CdrKey.callNotify];
    cid = json[key.CdrKey.cid];
    contextCallId = json[key.CdrKey.contextCallId];
    destination = json[key.CdrKey.destination];
    direction = json[key.CdrKey.direction];
    endEpoch = json[key.CdrKey.endEpoch];
    externalTransferEpoch = json[key.CdrKey.externalTransferEpoch];
    filename = json[key.CdrKey.filename];
    finalTransferAction = json[key.CdrKey.finalTransferAction];
    hangupCause = json[key.CdrKey.hangupCause];
    ivr = json[key.CdrKey.ivr];
    receptionOpen = json[key.CdrKey.receptionOpen];
    rid = json[key.CdrKey.rid];
    sipFromUserStripped = json[key.CdrKey.sipFromUserStripped];
    startEpoch = json[key.CdrKey.startEpoch];
    uid = json[key.CdrKey.uid];
    uuid = json[key.CdrKey.uuid];
    voicemail = json[key.CdrKey.voicemail];
  }

  /**
   * Return true if any one of the applications contains the call-notify string.
   */
  bool _callHasBeenNotified(List<Map<String, String>> applications) =>
      applications.any((Map<String, String> application) =>
          application['app_data'].contains(ORPbxKey.callNotify));

  /**
   * Try to locate the destination number.
   */
  String _extractDestination(Map json) {
    final Map vars = json['variables'];
    final List callFlow =
        json.containsKey('callflow') ? json['callflow'] : null;
    String desti = '';

    if (vars.containsKey(ORPbxKey.destination)) {
      desti = vars[ORPbxKey.destination];
    } else if (vars.containsKey('sip_to_user')) {
      desti = vars['sip_to_user'];
    } else if (callFlow != null) {
      desti = callFlow.first['caller_profile']['destination_number'];
    }

    return desti;
  }

  /**
   * Return the cost of [cdrEntry], based on [callPrices] and '
   * [callChargeMultiplier].
   *
   * Throws [PriceNotFound] if the destination found in [cdrEntry] does not
   * match any of the options available in the [callPrices] map.
   *
   * Throws [UnknownDestination] if no rid is found in [cdrEntry] and the
   * destination found in [cdrEntry] does not match any of the options available
   * in the [callPrices] map.
   */
  double cost(Map<String, Map<String, double>> callPrices,
      double callChargeMultiplier) {
    if (agentChannel || direction == 'inbound') {
      return 0.0;
    }

    String shortDestination = destination;

    while (shortDestination.isNotEmpty &&
        !callPrices.containsKey(shortDestination)) {
      shortDestination =
          shortDestination.substring(0, shortDestination.length - 1);
    }

    if (shortDestination.isEmpty) {
      if (rid != 0) {
        throw new PriceNotFound(
            'Destination "${destination}" not found in callPrices map for call ${uuid}');
      } else {
        throw new UnknownDestination(
            'Destination "${destination}" not found in callPrices map AND no rid found for call ${uuid}');
      }
    }

    return ((callPrices[shortDestination]['setup'] +
                (billSec * callPrices[shortDestination]['persecond'])) *
            callChargeMultiplier)
        .ceilToDouble();
  }

  /**
   * Extract [agentBeginEpoch], [agentEndEpoch], [externalTransferEpoch] and [finalTransferEpoch]
   * from [transferHistory].
   */
  void _extractTransferHistoryData(String transferHistory) {
    List<Map<String, String>> actions = new List<Map<String, String>>();
    final String actionString = transferHistory.split('::').last;
    bool answeredByAgent;
    bool hungupByAgent;

    actionString.split('|:').forEach((String value) {
      final List<String> items = value.split(':');
      actions.add({
        'epoch': items.first,
        'command': items[2],
        'destination': items.last
      });
    });

    answeredByAgent = actions.any((Map action) =>
        action['command'] == 'uuid_br' &&
        action['destination'].startsWith('agent-'));
    hungupByAgent = actions.last['command'] == 'uuid_br' &&
        actions.last['destination'].startsWith('agent-');

    if (answeredByAgent) {
      agentBeginEpoch = int.parse(actions.firstWhere((Map action) =>
          action['command'] == 'uuid_br' &&
          (action['destination'] as String).startsWith('agent-'))['epoch']);
    }

    if (hungupByAgent) {
      agentEndEpoch = endEpoch;
    }

    if (actions.last['destination'].startsWith('external_transfer_') ||
        (actions.last['command'] == 'uuid_br' &&
            !actions.last['destination'].startsWith('agent-'))) {
      externalTransferEpoch = int.parse(actions.last['epoch']);
    }

    finalTransferAction =
        '${actions.last['command']}:${actions.last['destination']}';
  }

  /**
   * Return true if any one of the applications contains the ivr string.
   */
  bool _ivrApp(List<Map<String, String>> applications) =>
      applications.any((Map<String, String> application) =>
          application['app_name'].contains(key.CdrKey.ivr));

  /**
   * Figure out what kind of CDR entry we're dealing with.
   */
  CdrEntryState get state {
    if (agentChannel) {
      return CdrEntryState.agentChannel;
    } else if (callNotify &&
        uid != 0 &&
        rid != 0 &&
        agentBeginEpoch != 0 &&
        direction == 'inbound') {
      return CdrEntryState.notifiedAnsweredByAgent;
    } else if (callNotify &&
        uid == 0 &&
        rid != 0 &&
        agentBeginEpoch == 0 &&
        direction == 'inbound') {
      return CdrEntryState.notifiedNotAnswered;
    } else if (!callNotify &&
        uid == 0 &&
        rid != 0 &&
        agentBeginEpoch == 0 &&
        direction == 'inbound') {
      return CdrEntryState.inboundNotNotified;
    } else if (uid != 0 && rid != 0 && direction == 'outbound') {
      return CdrEntryState.outboundByAgent;
    } else if (uid == 0 && rid != 0 && direction == 'outbound') {
      return CdrEntryState.outboundByPbx;
    } else {
      return CdrEntryState.unknown;
    }
  }

  Map toJson() => {
        key.CdrKey.agentBeginEpoch: agentBeginEpoch,
        key.CdrKey.agentChannel: agentChannel,
        key.CdrKey.agentEndEpoch: agentEndEpoch,
        key.CdrKey.answerEpoch: answerEpoch,
        key.CdrKey.billSec: billSec,
        key.CdrKey.bridgeUuid: bridgeUuid,
        key.CdrKey.callNotify: callNotify,
        key.CdrKey.contextCallId: contextCallId,
        key.CdrKey.cid: cid,
        key.CdrKey.destination: destination,
        key.CdrKey.direction: direction,
        key.CdrKey.endEpoch: endEpoch,
        key.CdrKey.externalTransferEpoch: externalTransferEpoch,
        key.CdrKey.filename: filename,
        key.CdrKey.finalTransferAction: finalTransferAction,
        key.CdrKey.hangupCause: hangupCause,
        key.CdrKey.ivr: ivr,
        key.CdrKey.receptionOpen: receptionOpen,
        key.CdrKey.sipFromUserStripped: sipFromUserStripped,
        key.CdrKey.rid: rid,
        key.CdrKey.startEpoch: startEpoch,
        key.CdrKey.uid: uid,
        key.CdrKey.uuid: uuid,
        key.CdrKey.voicemail: voicemail
      };

  String toString() =>
      '''${key.CdrKey.agentBeginEpoch}: ${agentBeginEpoch > 0 ? new DateTime.fromMillisecondsSinceEpoch(agentBeginEpoch * 1000).toString() : 0}
${key.CdrKey.agentChannel}: $agentChannel
${key.CdrKey.agentEndEpoch}: ${agentEndEpoch > 0 ? new DateTime.fromMillisecondsSinceEpoch(agentEndEpoch * 1000).toString() : 0}
${key.CdrKey.answerEpoch}: ${answerEpoch > 0 ? new DateTime.fromMillisecondsSinceEpoch(answerEpoch * 1000).toString() : 0}
${key.CdrKey.billSec}: $billSec
${key.CdrKey.bridgeUuid}: $bridgeUuid
${key.CdrKey.callNotify}: $callNotify
${key.CdrKey.cid}: $cid
${key.CdrKey.contextCallId}: $contextCallId
${key.CdrKey.destination}: $destination
${key.CdrKey.direction}: $direction
${key.CdrKey.endEpoch}: ${endEpoch > 0 ? new DateTime.fromMillisecondsSinceEpoch(endEpoch * 1000).toString() : 0}
${key.CdrKey.externalTransferEpoch}: ${externalTransferEpoch > 0 ? new DateTime.fromMillisecondsSinceEpoch(externalTransferEpoch * 1000).toString() : 0}
${key.CdrKey.filename}: $filename
${key.CdrKey.finalTransferAction}: $finalTransferAction
${key.CdrKey.hangupCause}: $hangupCause
${key.CdrKey.ivr}: $ivr
${key.CdrKey.receptionOpen}: $receptionOpen
${key.CdrKey.rid}: $rid
${key.CdrKey.sipFromUserStripped}: $sipFromUserStripped
${key.CdrKey.startEpoch}: ${startEpoch > 0 ? new DateTime.fromMillisecondsSinceEpoch(startEpoch * 1000).toString() : 0}
${key.CdrKey.state}: ${state.toString().split('.').last}
${key.CdrKey.uid}: $uid
${key.CdrKey.uuid}: $uuid
${key.CdrKey.voicemail}: $voicemail''';
}
