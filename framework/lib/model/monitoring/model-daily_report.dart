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

part of orf.model.monitoring;

/// Model class that contains a full report of which events occured at a given
/// day.
///
/// Useful for extracting agent performance information.
class DailyReport {
  /// A set calls that was handled on the given day.
  final Set<HistoricCall> callHistory = new Set<HistoricCall>();

  /// A set messages that was handled on the given day.
  final Set<MessageHistory> messageHistory = new Set<MessageHistory>();

  /// A set user state changes that occured on the given day.
  final Set<UserStateHistory> userStateHistory = new Set<UserStateHistory>();

  /// Create a new empty report.
  DailyReport.empty();

  /// Deserialization function.
  DailyReport.fromJson(Map<String, dynamic> map) {
    callHistory.addAll((map['calls'] as Iterable<Map<String, dynamic>>)
        .map((Map<String, dynamic> chMap) => new HistoricCall.fromJson(chMap)));

    messageHistory.addAll((map['messages'] as Iterable<Map<String, dynamic>>)
        .map((Map<String, dynamic> chMap) =>
            new MessageHistory.fromJson(chMap)));

    userStateHistory.addAll((map['userstate'] as Iterable<Map<String, dynamic>>)
        .map((Map<String, dynamic> ushMap) =>
            new UserStateHistory.fromJson(ushMap)));
  }

  /// Idicated whether or not this report has actual history entries.
  bool get isEmpty =>
      callHistory.isEmpty && messageHistory.isEmpty && userStateHistory.isEmpty;

  /// Get the [DateTime] of the first event in any if the event history sets.
  DateTime get day {
    if (isEmpty) {
      return util.never;
    }

    if (callHistory.isNotEmpty) {
      return callHistory.first.events.first.timestamp;
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

  /// Retrieve the call history of a single agent.
  Iterable<UserStateHistory> userStatesOf(int uid) =>
      userStateHistory.where((UserStateHistory ush) => ush.uid == uid);

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

  /// Playback the queue size over time and return a map with the queuesizes as
  /// values and the time the registered value as key.
  Map<DateTime, int> queuesizes() {
    final Map<DateTime, int> queueSizes = <DateTime, int>{};

    Iterable<HistoricCall> inboundCalls =
        callHistory.where((HistoricCall hc) => hc.inbound);

    List<_InternalCallEventRep> orderedEvents = <_InternalCallEventRep>[];

    for (HistoricCall hc in inboundCalls) {
      for (_HistoricCallEvent e in hc.events) {
        orderedEvents.add(
            new _InternalCallEventRep(hc.callId, e.timestamp, e.eventName));
      }
    }

    orderedEvents.sort((_InternalCallEventRep a, _InternalCallEventRep b) =>
        a.timestamp.compareTo(b.timestamp));

    int queueSize = 0;

    Set<String> seen = new Set<String>();
    for (_InternalCallEventRep e in orderedEvents) {
      if (e.eventName == _callOfferKey) {
        queueSize++;
        queueSizes[e.timestamp] = queueSize;
      } else if (e.eventName == _callPickupKey) {
        if (!seen.contains(e.callId)) {
          queueSize--;
          queueSizes[e.timestamp] = queueSize;
          seen.add(e.callId);
        }
      } else if (e.eventName == _callHangupKey) {
        if (!seen.remove(e.callId)) {
          queueSize--;
          queueSizes[e.timestamp] = queueSize;
        }
      }
    }

    return queueSizes;
  }

  /// Serialization function.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'calls': callHistory
            .map((HistoricCall ch) => ch.toJson())
            .toList(growable: false),
        'messages': messageHistory
            .map((MessageHistory mh) => mh.toJson())
            .toList(growable: false),
        'userstate': userStateHistory
            .map((UserStateHistory ush) => ush.toJson())
            .toList(growable: false),
      };
}

/// Internal helper class for extracting queue lengths.
class _InternalCallEventRep {
  final String callId;
  final DateTime timestamp;
  final String eventName;

  const _InternalCallEventRep(this.callId, this.timestamp, this.eventName);
}
