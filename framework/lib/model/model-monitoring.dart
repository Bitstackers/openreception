/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library orf.model.monitoring;

import 'package:orf/event.dart' as _event;
import 'package:orf/model.dart';
import 'package:orf/util.dart' as util;

final String _callOfferKey = new _event.CallOffer(null).eventName;
final String _callPickupKey = new _event.CallPickup(null).eventName;
final String _callHangupKey = new _event.CallHangup(null).eventName;
final String _callTransferKey = new _event.CallTransfer(null).eventName;

/// Model class for persistent storage of message/user log entry.
///
/// The log entry will record when a message was created, by whom, and
/// store a reference to the ID message that was created.
class MessageHistory {
  /// The ID of the message that was created.
  final int mid;

  /// The ID of the user that created the message.
  final int uid;

  /// The creation time of the message.
  final DateTime createdAt;

  /// Creates a new [MessageHistory] log entry from values.
  MessageHistory(this.mid, this.uid, this.createdAt);

  /// Creates a new [MessageHistory] log entry from a decoded map.
  factory MessageHistory.fromMap(Map<String, dynamic> map) {
    final int mid = map['mid'] != null ? map['mid'] : Message.noId;
    final int uid = map['uid'] != null ? map['uid'] : User.noId;

    final DateTime createdAt = DateTime.parse(map['created']);

    return new MessageHistory(mid, uid, createdAt);
  }

  /// The hash of a [MessageHistory] entry is different if at least one
  /// value differs.
  ///
  /// If no values differ, the hashcode is the same.
  @override
  int get hashCode => '$mid.$uid.${createdAt.millisecondsSinceEpoch}'.hashCode;

  /// Serialization function.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'mid': mid,
        'uid': uid,
        'created': createdAt.toString()
      };

  /// A [MessageHistory] object is equal to another [MessageHistory] object
  /// if their [mid] are the same.
  ///
  /// The motivation for this, is that any message is created _exactly once_
  /// and message ids should, by definition, _never_ be duplicated in
  /// message history logs.
  @override
  bool operator ==(Object other) => other is MessageHistory && other.mid == mid;
}

/// Model class for providing a complete summary of the performance of an
/// agent.
class AgentStatSummary {}

class CallSummary {
  final int inboundCount;
  final int outBoundCount;
  final int callsUnAnswered;
  final int callsAnsweredWithin20s;

  final int callWaitingMoreThanOneMinute;
  // final Map<int, Duration> agentInboundHandleTime = {};
  // Duration outboundHandleTime = new Duration();
  // Duration inboundHandleTime = new Duration();
  // Duration outboundHandleTime = new Duration();
  // Duration inboundHandleTime = new Duration();
  // Duration outboundHandleTime = new Duration();

  factory CallSummary(DailyReport report) {
    int inboundCount = 0;
    int outboundCount = 0;
    int callsUnAnswered = 0;
    int callsAnsweredWithin20s = 0;
    int callWaitingMoreThanOneMinute = 0;

    Map<int, int> callsByAgent = <int, int>{};
    Map<int, int> obCallsByAgent = <int, int>{};

    report.callHistory.forEach((HistoricCall history) {
      if (history.inbound) {
        inboundCount++;

        /// Individual agent stats.
        if (history.unAssigned) {
          callsUnAnswered++;
        } else if (!history.unAssigned) {
          if (!callsByAgent.containsKey(history.uid)) {
            callsByAgent[history.uid] = 0;
          }

          callsByAgent[history.uid] += 1;

          if (history.isAnswered) {
            if (history.answerLatency < new Duration(seconds: 20)) {
              callsAnsweredWithin20s++;
            } else if (history.answerLatency > new Duration(seconds: 60)) {
              callWaitingMoreThanOneMinute++;
            }
          }
        }
      } else {
        if (!obCallsByAgent.containsKey(history.uid)) {
          obCallsByAgent[history.uid] = 0;
        }

        if (history.unAssigned) {
          print('!!!!HELP!!!');
          print(history);
        }
        obCallsByAgent[history.uid] = obCallsByAgent[history.uid] + 1;
      }
    });

    return new CallSummary._internal(inboundCount, outboundCount,
        callsUnAnswered, callsAnsweredWithin20s, callWaitingMoreThanOneMinute);
  }

  CallSummary._internal(
      this.inboundCount,
      this.outBoundCount,
      this.callsUnAnswered,
      this.callsAnsweredWithin20s,
      this.callWaitingMoreThanOneMinute);

  // /**
  //  *
  //  */
  // List<Map<String, dynamic>> agentSummay() {
  //   List<Map<String, dynamic>> ret = [];
  //   callsByAgent.forEach((k, v) {
  //     ret.add({
  //       'uid': k,
  //       'answered': v,
  //       'name': _userNameCache.containsKey(k) ? _userNameCache[k] : '??'
  //     });
  //   });
  //
  //   return ret;
  // }
  //
  // String toString() => 'totalCalls:$totalCalls, '
  //     'below20s:$callsAnsweredWithin20s, '
  //     'oneminute:$callWaitingMoreThanOneMinute, '
  //     'talktime:$talkTime, '
  //     'unanswered:$callsUnAnswered,'
  //     'agentSummary: ${agentSummay().join(', ')}';
  //
  // Map toJson() => {
  //       'totalCalls': totalCalls,
  //       'below20s': callsAnsweredWithin20s,
  //       'oneminuteplus': callWaitingMoreThanOneMinute,
  //       'unanswered': callsUnAnswered,
  //       'agentSummary': agentSummay()
  //     };
}

class CallStat {
  bool done = false;
  DateTime arrived;
  DateTime answered;
  int userId = User.noId;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'arrived': arrived.toString(),
        'answered': answered.toString(),
        'userId': userId,
      };
}

class DailyReport {
  final Set<HistoricCall> callHistory = new Set<HistoricCall>();
  final Set<MessageHistory> messageHistory = new Set<MessageHistory>();
  final Set<UserStateHistory> userStateHistory = new Set<UserStateHistory>();

  /// Create a new empty report.
  DailyReport.empty();

  DailyReport.fromMap(Map<String, dynamic> map) {
    callHistory.addAll((map['calls'] as Iterable<Map<String, dynamic>>)
        .map((Map<String, dynamic> chMap) => new HistoricCall.fromMap(chMap)));

    messageHistory.addAll((map['messages'] as Iterable<Map<String, dynamic>>)
        .map(
            (Map<String, dynamic> chMap) => new MessageHistory.fromMap(chMap)));
  }

  /// Idicated whether or not this report has actual history entries.
  bool get isEmpty =>
      callHistory.isEmpty && messageHistory.isEmpty && userStateHistory.isEmpty;

  ///
  DateTime get day {
    if (isEmpty) {
      return util.never;
    }

    if (callHistory.isNotEmpty) {
      return callHistory.first._events.first.timestamp;
    }

    if (messageHistory.isNotEmpty) {
      return messageHistory.first.createdAt;
    }

    if (userStateHistory.isNotEmpty) {
      return userStateHistory.first.timestamp;
    }

    return util.never;
  }

  /// Retrieve the call history of a single agent.
  Iterable<HistoricCall> callsOfUid(int uid) =>
      callHistory.where((HistoricCall ch) => ch.uid == uid);

  /// Retrieve the call history of a single agent.
  Iterable<MessageHistory> messagesOfUid(int uid) =>
      messageHistory.where((MessageHistory mh) => mh.uid == uid);

  /// Retrieve the uids involved in the daily report.
  Iterable<int> get uids =>
      callHistory.map((HistoricCall ch) => ch.uid).toSet();

  /// Add a (completed) call history object to the report.
  void addCallHistory(ActiveCall ac) {
    callHistory.add(new HistoricCall.fromActiveCall(ac));
  }

  /// Add a [MessageHistory] history object to the report.
  void addMessageHistory(MessageHistory history) {
    messageHistory.add(history);
  }

  /// Add a [UserStateHistory] history object to the report.
  void addUserStateChange(UserStateHistory history) {
    userStateHistory.add(history);
  }

  /// Serialization function.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'calls': callHistory
            .map((HistoricCall ch) => ch.toJson())
            .toList(growable: false),
        'messages': messageHistory
            .map((MessageHistory mh) => mh.toJson())
            .toList(growable: false),
      };
}

class _HistoricCallEvent {
  final DateTime timestamp;
  final String eventName;

  const _HistoricCallEvent(this.timestamp, this.eventName);

  factory _HistoricCallEvent.fromJson(Map<String, dynamic> map) =>
      new _HistoricCallEvent(DateTime.parse(map['t']), map['e']);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'t': timestamp.toString(), 'e': eventName};
}

class HistoricCall {
  final String callId;
  final int uid;
  final int rid;
  final int cid;
  final bool inbound;
  final List<_HistoricCallEvent> _events = <_HistoricCallEvent>[];

  HistoricCall.fromActiveCall(ActiveCall ac)
      : callId = ac.callId,
        uid = ac.assignee,
        rid = ac.rid,
        cid = ac.cid,
        inbound = ac.inbound {
    _HistoricCallEvent simplifyEvent(_event.CallEvent ce) =>
        new _HistoricCallEvent(ce.timestamp, ce.eventName);

    _events.addAll(ac._events.map(simplifyEvent));
  }

  HistoricCall.fromMap(Map<String, dynamic> map)
      : callId = map['id'],
        uid = map['uid'],
        rid = map['rid'],
        cid = map['cid'],
        inbound = map['in'] {
    _events.addAll((map['es'] as Iterable<Map<String, dynamic>>).map(
        (Map<String, dynamic> map) => new _HistoricCallEvent.fromJson(map)));
  }

  bool get unAssigned => uid == User.noId;

  Duration get answerLatency {
    if (!inbound) {
      return null;
    }

    _HistoricCallEvent offerEvent;
    _HistoricCallEvent pickupEvent;
    try {
      offerEvent = _events
          .firstWhere((_HistoricCallEvent e) => e.eventName == _callOfferKey);

      pickupEvent = _events
          .firstWhere((_HistoricCallEvent e) => e.eventName == _callPickupKey);
    } on StateError {
      return new Duration(seconds: 2);
    }

    return pickupEvent.timestamp.difference(offerEvent.timestamp);
  }

  Duration get lifeTime {
    final _HistoricCallEvent offerEvent = _events
        .firstWhere((_HistoricCallEvent e) => e.eventName == _callOfferKey);

    final _HistoricCallEvent hangupEvent = _events
        .firstWhere((_HistoricCallEvent e) => e.eventName == _callHangupKey);

    return hangupEvent.timestamp.difference(offerEvent.timestamp);
  }

  /// Determines if the call was answered.
  bool get isAnswered =>
      _events.any((_HistoricCallEvent e) => e.eventName == _callPickupKey);

  Duration get handleTime {
    final _HistoricCallEvent offerEvent = _events
        .firstWhere((_HistoricCallEvent e) => e.eventName == _callOfferKey);

    final _HistoricCallEvent hangupEvent = _events.firstWhere(
        (_HistoricCallEvent e) =>
            e.eventName == _callHangupKey || e.eventName == _callTransferKey);

    return hangupEvent.timestamp.difference(offerEvent.timestamp);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': callId,
        'uid': uid,
        'rid': rid,
        'cid': cid,
        'in': inbound,
        'es': _events
            .map((_HistoricCallEvent e) => e.toJson())
            .toList(growable: false)
      };

  @override
  int get hashCode => callId.hashCode;

  @override
  bool operator ==(Object other) =>
      other is HistoricCall && other.callId == callId;
}

class ActiveCall {
  final List<_event.CallEvent> _events = <_event.CallEvent>[];

  ActiveCall.empty();

  ///
  int get rid => _events
      .firstWhere((_event.CallEvent ce) => ce.call.rid != Reception.noId,
          orElse: () => new _event.CallOffer(Call.noCall))
      .call
      .rid;

  ///
  int get cid => _events
      .firstWhere((_event.CallEvent ce) => ce.call.cid != BaseContact.noId,
          orElse: () => new _event.CallOffer(Call.noCall))
      .call
      .cid;

  String get callId => _events.isNotEmpty ? _events.first.call.id : Call.noId;

  void addEvent(_event.Event e) {
    _events.add(e);
    _events.sort((_event.Event e1, _event.Event e2) =>
        e1.timestamp.compareTo(e2.timestamp));
  }

  /// Retrieve the uid of the agent that call was assigned to.
  ///
  /// If the call was never assigned, returns [model.User.noId].
  int get assignee => _events
      .firstWhere((_event.CallEvent ce) => ce.call.assignedTo != User.noId,
          orElse: () => _events.first)
      .call
      .assignedTo;

  bool get unAssigned => assignee == User.noId;

  String eventString() =>
      '  events:\n' +
      _events.map((_event.Event e) => '  - ${_eventToString(e)}').join('\n');

  String _eventToString(_event.Event e) =>
      '${e.timestamp.millisecondsSinceEpoch~/1000}: ${e.eventName}';

  @override
  String toString() => 'done:$isDone\n'
      'owner: $assignee\n'
      'isAnswered:$isAnswered${isAnswered && inbound ? ' (latency:${answerLatency.inMilliseconds}ms)' : ''}\n'
      'inbound:$inbound\n'
      '${eventString()}';

  /// Determine if the call is inbound.
  bool get inbound => _events.first.call.inbound;

  bool get isAnswered =>
      _events.any((_event.CallEvent ce) => ce is _event.CallPickup);

  DateTime get firstEventTime => _events.first.timestamp;

  bool get isDone => _events.any((_event.CallEvent ce) =>
      ce is _event.CallHangup || ce is _event.CallTransfer);

  @override
  int get hashCode => callId.hashCode;

  @override
  bool operator ==(Object other) =>
      other is ActiveCall && other.callId == callId;

  Duration get answerLatency {
    if (!inbound) {
      return null;
    }

    _event.CallOffer offerEvent;
    _event.CallPickup pickupEvent;
    try {
      offerEvent =
          _events.firstWhere((_event.CallEvent ce) => ce is _event.CallOffer);

      pickupEvent =
          _events.firstWhere((_event.CallEvent ce) => ce is _event.CallPickup);
    } on StateError {
      return new Duration(seconds: 2);
    }

    return pickupEvent.timestamp.difference(offerEvent.timestamp);
  }
}

class UserStateHistory {
  final int uid;
  final DateTime timestamp;
  final bool pause;

  /// Default constructor
  const UserStateHistory(this.uid, this.timestamp, this.pause);

  /// Deserializing constructor.
  UserStateHistory.fromMap(Map<String, dynamic> map)
      : uid = map['uid'],
        timestamp = DateTime.parse(map['t']),
        pause = map['p'];

  /// Serialization function
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'uid': uid, 't': timestamp.toString(), 'p': pause};

  @override
  int get hashCode => toJson().toString().hashCode;

  @override
  bool operator ==(Object other) =>
      other is UserStateHistory && other.hashCode == hashCode;
}
