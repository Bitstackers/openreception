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

part of openreception.model;

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
    agentBeginEpoch = json[Key.CdrKey.agentBeginEpoch];
    agentChannel = json[Key.CdrKey.agentChannel];
    agentEndEpoch = json[Key.CdrKey.agentEndEpoch];
    answerEpoch = json[Key.CdrKey.answerEpoch];
    billSec = json[Key.CdrKey.billSec];
    bridgeUuid = json[Key.CdrKey.bridgeUuid];
    callNotify = json[Key.CdrKey.callNotify];
    cid = json[Key.CdrKey.cid];
    contextCallId = json[Key.CdrKey.contextCallId];
    destination = json[Key.CdrKey.destination];
    direction = json[Key.CdrKey.direction];
    endEpoch = json[Key.CdrKey.endEpoch];
    externalTransferEpoch = json[Key.CdrKey.externalTransferEpoch];
    filename = json[Key.CdrKey.filename];
    finalTransferAction = json[Key.CdrKey.finalTransferAction];
    hangupCause = json[Key.CdrKey.hangupCause];
    ivr = json[Key.CdrKey.ivr];
    receptionOpen = json[Key.CdrKey.receptionOpen];
    rid = json[Key.CdrKey.rid];
    sipFromUserStripped = json[Key.CdrKey.sipFromUserStripped];
    startEpoch = json[Key.CdrKey.startEpoch];
    uid = json[Key.CdrKey.uid];
    uuid = json[Key.CdrKey.uuid];
    voicemail = json[Key.CdrKey.voicemail];
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
          application['app_name'].contains(Key.CdrKey.ivr));

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
        Key.CdrKey.agentBeginEpoch: agentBeginEpoch,
        Key.CdrKey.agentChannel: agentChannel,
        Key.CdrKey.agentEndEpoch: agentEndEpoch,
        Key.CdrKey.answerEpoch: answerEpoch,
        Key.CdrKey.billSec: billSec,
        Key.CdrKey.bridgeUuid: bridgeUuid,
        Key.CdrKey.callNotify: callNotify,
        Key.CdrKey.contextCallId: contextCallId,
        Key.CdrKey.cid: cid,
        Key.CdrKey.destination: destination,
        Key.CdrKey.direction: direction,
        Key.CdrKey.endEpoch: endEpoch,
        Key.CdrKey.externalTransferEpoch: externalTransferEpoch,
        Key.CdrKey.filename: filename,
        Key.CdrKey.finalTransferAction: finalTransferAction,
        Key.CdrKey.hangupCause: hangupCause,
        Key.CdrKey.ivr: ivr,
        Key.CdrKey.receptionOpen: receptionOpen,
        Key.CdrKey.sipFromUserStripped: sipFromUserStripped,
        Key.CdrKey.rid: rid,
        Key.CdrKey.startEpoch: startEpoch,
        Key.CdrKey.uid: uid,
        Key.CdrKey.uuid: uuid,
        Key.CdrKey.voicemail: voicemail
      };

  String toString() =>
      '''${Key.CdrKey.agentBeginEpoch}: ${agentBeginEpoch > 0 ? new DateTime.fromMillisecondsSinceEpoch(agentBeginEpoch * 1000).toString() : 0}
${Key.CdrKey.agentChannel}: $agentChannel
${Key.CdrKey.agentEndEpoch}: ${agentEndEpoch > 0 ? new DateTime.fromMillisecondsSinceEpoch(agentEndEpoch * 1000).toString() : 0}
${Key.CdrKey.answerEpoch}: ${answerEpoch > 0 ? new DateTime.fromMillisecondsSinceEpoch(answerEpoch * 1000).toString() : 0}
${Key.CdrKey.billSec}: $billSec
${Key.CdrKey.bridgeUuid}: $bridgeUuid
${Key.CdrKey.callNotify}: $callNotify
${Key.CdrKey.cid}: $cid
${Key.CdrKey.contextCallId}: $contextCallId
${Key.CdrKey.destination}: $destination
${Key.CdrKey.direction}: $direction
${Key.CdrKey.endEpoch}: ${endEpoch > 0 ? new DateTime.fromMillisecondsSinceEpoch(endEpoch * 1000).toString() : 0}
${Key.CdrKey.externalTransferEpoch}: ${externalTransferEpoch > 0 ? new DateTime.fromMillisecondsSinceEpoch(externalTransferEpoch * 1000).toString() : 0}
${Key.CdrKey.filename}: $filename
${Key.CdrKey.finalTransferAction}: $finalTransferAction
${Key.CdrKey.hangupCause}: $hangupCause
${Key.CdrKey.ivr}: $ivr'
${Key.CdrKey.receptionOpen}: $receptionOpen
${Key.CdrKey.rid}: $rid
${Key.CdrKey.sipFromUserStripped}: $sipFromUserStripped
${Key.CdrKey.startEpoch}: ${startEpoch > 0 ? new DateTime.fromMillisecondsSinceEpoch(startEpoch * 1000).toString() : 0}
${Key.CdrKey.state}: ${state.toString().split('.').last}
${Key.CdrKey.uid}: $uid
${Key.CdrKey.uuid}: $uuid
${Key.CdrKey.voicemail}: $voicemail''';
}

/**
 * Don't use this. Deprecated.
 */
@deprecated
class CDREntry {
  double avgDuration;
  String billingType;
  int callCount;
  int duration;
  String flag;
  int orgId;
  String orgName;
  int smsCount;
  int totalWait;

  /**
   * Default empty constructor.
   */
  CDREntry.empty();

  /**
   * Deserializing constructor.
   */
  CDREntry.fromJson(Map json) {
    orgId = json['org_id'];
    callCount = json['call_count'];
    orgName = json['org_name'];
    totalWait = json['total_wait'];
    billingType = json['billing_type'];
    duration = json['duration'];
    flag = json['flag'];
    avgDuration = json['avg_duration'];

    //TODO Extract Data when the interface is updated.
    smsCount = -1;
  }

  /**
   * JSON serialization representation.
   */
  Map toJson() => {
        'org_id': orgId,
        'call_count': callCount,
        'org_name': orgName,
        'total_wait': totalWait,
        'billing_type': billingType,
        'duration': duration,
        'flag': flag,
        'avg_duration': avgDuration,
        'sms_count': smsCount
      };
}
