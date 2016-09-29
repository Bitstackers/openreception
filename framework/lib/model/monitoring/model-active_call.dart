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
