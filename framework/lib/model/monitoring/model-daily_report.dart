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

class DailyReport {
  final Set<HistoricCall> callHistory = new Set<HistoricCall>();
  final Set<MessageHistory> messageHistory = new Set<MessageHistory>();
  final Set<UserStateHistory> userStateHistory = new Set<UserStateHistory>();

  /// Create a new empty report.
  DailyReport.empty();

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

  ///
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

  /// Playback the queue size over time
  Map<DateTime, int> queuesizes() {
    final Map<DateTime, int> queueSizes = <DateTime, int>{};

    List<_HistoricCallEvent> orderedEvents = callHistory
        .where((HistoricCall hc) => hc.inbound)
        .fold(
            <_HistoricCallEvent>[],
            (List<_HistoricCallEvent> l, HistoricCall hc) =>
                l..addAll(hc.events))
          ..sort((_HistoricCallEvent a, _HistoricCallEvent b) =>
              a.timestamp.compareTo(b.timestamp));

    int queueSize = 0;

    for (_HistoricCallEvent callEvt in orderedEvents) {
      if (callEvt.eventName == _callOfferKey) {
        queueSize++;
        queueSizes[callEvt.timestamp] = queueSize;
      } else if (callEvt.eventName == _callHangupKey) {
        queueSize--;
        queueSizes[callEvt.timestamp] = queueSize;
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
