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

library openreception.framework.model.monitoring;

import 'package:openreception.framework/event.dart' as _event;
import 'package:openreception.framework/model.dart';
import 'package:openreception.framework/util.dart' as util;

class MessageHistory {
  final int mid;
  final int uid;
  final DateTime createdAt;

  /**
   *
   */
  factory MessageHistory.fromMap(Map map) {
    final int mid = map['mid'] != null ? map['mid'] : Message.noId;
    final int uid = map['uid'] != null ? map['uid'] : User.noId;

    final DateTime createdAt = DateTime.parse(map['created']);

    return new MessageHistory(mid, uid, createdAt);
  }

  /**
   *
   */
  MessageHistory(this.mid, this.uid, this.createdAt);

  /**
   *
   */
  @override
  int get hashCode => '$mid.$uid.${createdAt.millisecondsSinceEpoch}'.hashCode;

  /**
   *
   */
  Map toJson() => {'mid': mid, 'uid': uid, 'created': createdAt.toString()};

  @override
  operator ==(Object other) => other is MessageHistory && other.mid == mid;
}

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

    Map<int, int> callsByAgent = {};
    Map<int, int> obCallsByAgent = {};

    report.callHistory.forEach((history) {
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

  Map toJson() => {
        'arrived': arrived.toString(),
        'answered': answered.toString(),
        'userId': userId,
      };
}

class DailyReport {
  final Set<HistoricCall> callHistory = new Set();
  final Set<MessageHistory> messageHistory = new Set();
  final Set<UserStateHistory> userStateHistory = new Set();

  /// Idicated whether or not this report has actual history entries.
  bool get isEmpty =>
      callHistory.isEmpty && messageHistory.isEmpty && userStateHistory.isEmpty;

  /**
   * Create a new empty report.
   */
  DailyReport.empty();

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

  /**
   *
   */
  DailyReport.fromMap(Map map) {
    callHistory.addAll((map['calls'] as Iterable)
        .map((Map chMap) => new HistoricCall.fromMap(chMap)));

    messageHistory.addAll((map['messages'] as Iterable)
        .map((Map chMap) => new MessageHistory.fromMap(chMap)));
  }

  /**
   * Retrieve the call history of a single agent.
   */
  Iterable<HistoricCall> callsOfUid(int uid) =>
      callHistory.where((HistoricCall ch) => ch.uid == uid);

  /**
   * Retrieve the call history of a single agent.
   */
  Iterable<MessageHistory> messagesOfUid(int uid) =>
      messageHistory.where((MessageHistory mh) => mh.uid == uid);

  /**
   * Retrieve the uids involved in the daily report.
   */
  Iterable<int> get uids =>
      callHistory.map((HistoricCall ch) => ch.uid).toSet();

  /**
   * Add a (completed) call history object to the report.
   */
  void addCallHistory(ActiveCall ac) {
    callHistory.add(new HistoricCall.fromActiveCall(ac));
  }

  /**
   * Add a [MessageHistory] history object to the report.
   */
  void addMessageHistory(MessageHistory history) {
    messageHistory.add(history);
  }

  /**
     * Add a [UserStateHistory] history object to the report.
     */
  void addUserStateChange(UserStateHistory history) {
    userStateHistory.add(history);
  }

  /**
   *
   */
  Map toJson() => {
        'calls': callHistory.map((ch) => ch.toJson()).toList(growable: false),
        'messages':
            messageHistory.map((mh) => mh.toJson()).toList(growable: false),
      };
}

class _HistoricCallEvent {
  final DateTime timestamp;
  final String eventName;

  /**
   *
   */
  const _HistoricCallEvent(this.timestamp, this.eventName);

  /**
   *
   */
  factory _HistoricCallEvent.fromJson(Map map) =>
      new _HistoricCallEvent(DateTime.parse(map['t']), map['e']);

  /**
   *
   */
  Map toJson() => {'t': timestamp.toString(), 'e': eventName};
}

class HistoricCall {
  final String callId;
  final int uid;
  final int rid;
  final int cid;
  final bool inbound;
  final List<_HistoricCallEvent> _events = [];

  bool get unAssigned => uid == User.noId;

  /**
   *
   */
  Duration get answerLatency {
    if (!inbound) {
      return null;
    }

    var offerEvent;
    var pickupEvent;
    try {
      offerEvent =
          _events.firstWhere((e) => e.eventName == _event.Key.callOffer);

      pickupEvent =
          _events.firstWhere((e) => e.eventName == _event.Key.callPickup);
    } on StateError {
      return new Duration(seconds: 2);
    }

    return pickupEvent.timestamp.difference(offerEvent.timestamp);
  }

  /**
   *
   */
  Duration get lifeTime {
    final offerEvent =
        _events.firstWhere((e) => e.eventName == _event.Key.callOffer);

    final hangupEvent =
        _events.firstWhere((e) => e.eventName == _event.Key.callHangup);

    return hangupEvent.timestamp.difference(offerEvent.timestamp);
  }

  /**
   * Determines if the call was answered.
   */
  bool get isAnswered =>
      _events.any((e) => e.eventName == _event.Key.callPickup);

  /**
   *
   */
  Duration get handleTime {
    final offerEvent =
        _events.firstWhere((e) => e.eventName == _event.Key.callOffer);

    final hangupEvent = _events.firstWhere((e) =>
        e.eventName == _event.Key.callHangup ||
        e.eventName == _event.Key.callTransfer);

    return hangupEvent.timestamp.difference(offerEvent.timestamp);
  }

  /**
   *
   */
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

  /**
   *
   */
  HistoricCall.fromMap(Map map)
      : callId = map['id'],
        uid = map['uid'],
        rid = map['rid'],
        cid = map['cid'],
        inbound = map['in'] {
    _events.addAll((map['es'] as Iterable)
        .map((map) => new _HistoricCallEvent.fromJson(map)));
  }

  /**
   *
   */
  Map toJson() => {
        'id': callId,
        'uid': uid,
        'rid': rid,
        'cid': cid,
        'in': inbound,
        'es': _events.map((e) => e.toJson()).toList(growable: false)
      };

  /**
   *
   */
  @override
  int get hashCode => callId.hashCode;

  @override
  operator ==(Object other) => other is HistoricCall && other.callId == callId;
}

class ActiveCall {
  final List<_event.CallEvent> _events = [];

  ///
  int get rid => _events
      .firstWhere((ce) => ce.call.rid != Reception.noId,
          orElse: () => new _event.CallOffer(Call.noCall))
      .call
      .rid;

  ///
  int get cid => _events
      .firstWhere((ce) => ce.call.cid != BaseContact.noId,
          orElse: () => new _event.CallOffer(Call.noCall))
      .call
      .cid;

  /**
   *
   */
  ActiveCall.empty();

  /**
   *
   */
  String get callId => _events.isNotEmpty ? _events.first.call.id : Call.noId;

  void addEvent(_event.Event e) {
    _events.add(e);
    _events.sort((e1, e2) => e1.timestamp.compareTo(e2.timestamp));
  }

  /**
   * Retrieve the uid of the agent that call was assigned to. If the call
   * was never assigned, returns [model.User.noId].
   */
  int get assignee => _events
      .firstWhere((_event.CallEvent ce) => ce.call.assignedTo != User.noId,
          orElse: () => _events.first)
      .call
      .assignedTo;

  bool get unAssigned => assignee == User.noId;

  String eventString() =>
      '  events:\n' + _events.map((e) => '  - ${_eventToString(e)}').join('\n');

  String _eventToString(_event.Event e) =>
      '${e.timestamp.millisecondsSinceEpoch~/1000}: ${e.eventName}';

  @override
  String toString() => 'done:$isDone\n'
      'owner: $assignee\n'
      'isAnswered:$isAnswered${isAnswered && inbound ? ' (latency:${answerLatency.inMilliseconds}ms)' : ''}\n'
      'inbound:$inbound\n'
      '${eventString()}';

  ///
  bool get inbound => _events.first.call.inbound;

  bool get isAnswered =>
      _events.any((_event.CallEvent ce) => ce is _event.CallPickup);

  DateTime get firstEventTime => _events.first.timestamp;

  bool get isDone => _events.any((_event.CallEvent ce) =>
      ce is _event.CallHangup || ce is _event.CallTransfer);

  @override
  int get hashCode => callId.hashCode;

  @override
  operator ==(Object other) => other is ActiveCall && other.callId == callId;

  /**
   *
   */
  Duration get answerLatency {
    if (!inbound) {
      return null;
    }

    var offerEvent;
    var pickupEvent;
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

  /**
   * Default constructor
   */
  const UserStateHistory(this.uid, this.timestamp, this.pause);

  /**
   * Deserilizing constructor.
   */
  UserStateHistory.fromMap(Map map)
      : uid = map['uid'],
        timestamp = DateTime.parse(map['t']),
        pause = map['p'];

  /**
   * Serialization function
   */
  Map toJson() => {'uid': uid, 't': timestamp.toString(), 'p': pause};

  @override
  int get hashCode => toJson().toString().hashCode;

  @override
  operator ==(Object other) =>
      other is UserStateHistory && other.hashCode == hashCode;
}
