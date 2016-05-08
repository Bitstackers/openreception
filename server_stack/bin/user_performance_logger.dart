/*                  This file is part of OpenReception
                   Copyright (C) 2016-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

/**
 * The OR-Stack command-line event logger.
 */
library openreception.server.user_performance_logger;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart' show DateFormat;
import 'package:openreception.framework/event.dart' as event;
import 'package:openreception.framework/model.dart' as model;
import 'package:openreception.framework/service-io.dart' as transport;
import 'package:openreception.framework/service.dart' as service;
import 'package:openreception.server/configuration.dart';

final Map<int, String> _userNameCache = {};
final DateFormat rfc3339 = new DateFormat('yyyy-MM-dd');

class CallSummary {
  int totalCalls = 0;
  int callsAnsweredWithin20s = 0;
  int callsUnAnswered = 0;
  int callWaitingMoreThanOneMinute = 0;
  int talkTime = 0;
  Map<int, int> callsByAgent = {};
  Map<int, int> obCallsByAgent = {};

  List<Map<String, dynamic>> agentSummay() {
    List<Map<String, dynamic>> ret = [];
    callsByAgent.forEach((k, v) {
      ret.add({
        'uid': k,
        'answered': v,
        'name': _userNameCache.containsKey(k) ? _userNameCache[k] : '??'
      });
    });

    return ret;
  }

  String toString() => 'totalCalls:$totalCalls, '
      'below20s:$callsAnsweredWithin20s, '
      'oneminute:$callWaitingMoreThanOneMinute, '
      'talktime:$talkTime, '
      'unanswered:$callsUnAnswered,'
      'agentSummary: ${agentSummay().join(', ')}';

  Map toJson() => {
        'totalCalls': totalCalls,
        'below20s': callsAnsweredWithin20s,
        'oneminuteplus': callWaitingMoreThanOneMinute,
        'unanswered': callsUnAnswered,
        'agentSummary': agentSummay()
      };
}

class CallStat {
  bool done = false;
  DateTime arrived;
  DateTime answered;
  int userId = model.User.noId;

  Map toJson() => {
        'arrived': arrived.toString(),
        'answered': answered.toString(),
        'userId': userId,
      };
}

class CallHistory {
  List<event.CallEvent> _events = [];
  int availableAgents = 0;

  void addEvent(event.Event e) {
    _events.add(e);
    _events.sort((e1, e2) => e1.timestamp.compareTo(e2.timestamp));
  }

  int get assignee => _events
      .firstWhere((event.CallEvent ce) => ce.call.assignedTo != model.User.noId,
          orElse: () => _events.first)
      .call
      .assignedTo;

  bool get unAssigned => assignee == model.User.noId;

  String eventString() =>
      '  events:\n' + _events.map((e) => '  - ${_eventToString(e)}').join('\n');

  String _eventToString(event.Event e) =>
      '${e.timestamp.millisecondsSinceEpoch~/1000}: ${e.eventName}';

  String toString() => 'done:$isDone\n'
      'owner: $assignee\n'
      'isAnswered:$isAnswered${isAnswered && inbound ? ' (latency:${answerLatency.inMilliseconds}ms)' : ''}\n'
      'inbound:$inbound\n'
      '${eventString()}';

  bool get inbound => _events.first.call.inbound;

  bool get isAnswered =>
      _events.any((event.CallEvent ce) => ce is event.CallPickup);

  DateTime get firstEventTime => _events.first.timestamp;

  Duration get answerLatency {
    if (!inbound) {
      return null;
    }

    var offerEvent;
    var pickupEvent;
    try {
      offerEvent =
          _events.firstWhere((event.CallEvent ce) => ce is event.CallOffer);

      pickupEvent =
          _events.firstWhere((event.CallEvent ce) => ce is event.CallPickup);
    } on StateError {
      return new Duration(seconds: 2);
    }

    return pickupEvent.timestamp.difference(offerEvent.timestamp);
  }

  Duration get lifeTime {
    final offerEvent =
        _events.firstWhere((event.CallEvent ce) => ce is event.CallOffer);

    final hangupEvent =
        _events.firstWhere((event.CallEvent ce) => ce is event.CallHangup);

    return hangupEvent.timestamp.difference(offerEvent.timestamp);
  }

  Duration get handleTime {
    final offerEvent =
        _events.firstWhere((event.CallEvent ce) => ce is event.CallOffer);

    final hangupEvent = _events.firstWhere((event.CallEvent ce) =>
        ce is event.CallHangup || ce is event.CallTransfer);

    return hangupEvent.timestamp.difference(offerEvent.timestamp);
  }

  bool get isDone => _events.any((event.CallEvent ce) =>
      ce is event.CallHangup || ce is event.CallTransfer);

  Map toJson() => {
        'uid': assignee,
        'inbound': inbound,
        'events': []..addAll(_events.map(_eventToString))
      };
}

CallSummary _summarize(Map<String, CallHistory> history) {
  final CallSummary summary = new CallSummary();

  history.forEach((_, call) {
    if (call.inbound) {
      summary.totalCalls++;

      /// Individual agent stats.
      if (call.unAssigned && call.isDone) {
        summary.callsUnAnswered++;
      } else if (!call.unAssigned) {
        if (!summary.callsByAgent.containsKey(call.assignee)) {
          summary.callsByAgent[call.assignee] = 0;
        }

        summary.callsByAgent[call.assignee] =
            summary.callsByAgent[call.assignee] + 1;

        if (call.isAnswered) {
          if (call.answerLatency < new Duration(seconds: 20)) {
            summary.callsAnsweredWithin20s++;
          } else if (call.answerLatency > new Duration(seconds: 60)) {
            summary.callWaitingMoreThanOneMinute++;
          }
        }
      }
    } else {
      if (!summary.obCallsByAgent.containsKey(call.assignee)) {
        summary.obCallsByAgent[call.assignee] = 0;
      }

      if (call.unAssigned) {
        print('!!!!HELP!!!');
        print(call);
      }
      summary.obCallsByAgent[call.assignee] =
          summary.obCallsByAgent[call.assignee] + 1;
    }
  });

  return summary;
}

Future main(List<String> args) async {
  Map<String, CallHistory> _eventHistory = {};

  // transport.WebSocketClient client = new transport.WebSocketClient();
  // await client.connect(Uri.parse(
  //     '${config.configserver.notificationSocketUri}?token=${config.authServer.serverToken}'));
  //
  // service.NotificationSocket notificationSocket =
  //     new service.NotificationSocket(client);
  service.RESTUserStore userStore = new service.RESTUserStore(
      config.configserver.userServerUri,
      config.authServer.serverToken,
      new transport.Client());

  await userStore.list().then((Iterable<model.UserReference> users) {
    users.forEach((user) {
      _userNameCache[user.id] = user.name;
    });
  });

  dispatchEvent(event.Event e) async {
    if (e is event.CallEvent) {
      if (!_eventHistory.containsKey(e.call.id)) {
        _eventHistory[e.call.id] = new CallHistory();
      }
      _eventHistory[e.call.id].addEvent(e);

      if (_eventHistory[e.call.id].isDone) {
        CallHistory ch = _eventHistory.remove(e.call.id);
        String dirPath = '${rfc3339.format(ch.firstEventTime)}';

        if (!new Directory(dirPath).existsSync()) {
          new Directory(dirPath).createSync();
        }

        try {
          new File('$dirPath/' + e.call.id).writeAsStringSync(JSON.encode(ch));
        } catch (e) {
          print('Could not save $ch');
        }
      }
    } else {
      return;
    }
  }

  // notificationSocket.eventStream.listen((event.Event e) {
  //   try {
  //     dispatchEvent(e);
  //   } catch (e, s) {
  //     print(e);
  //     print(s);
  //   }
  // });

  if (args.isNotEmpty) {
    args.forEach((arg) {
      print('Loading data from file $arg');
      List<String> lines = new File(arg).readAsLinesSync();

      lines.forEach((String line) {
        Map json = JSON.decode(line);
        event.Event e = new event.Event.parse(json);
        try {
          dispatchEvent(e);
        } catch (e, s) {
          print(e);
          print(s);
        }
      });
    });
  }

  String jsonCache = '';
  String keyOf(DateTime dt) => rfc3339.format(dt);

  Map<String, CallHistory> dateSorted = {};

  _eventHistory.values.forEach((CallHistory ch) {
    dateSorted[keyOf(ch.firstEventTime)] = ch;
  });

  dateSorted.forEach((time, callHistory) {
    final newCache = JSON.encode(_summarize({'': callHistory}).toJson());

    if (newCache.hashCode != jsonCache.hashCode) {
      jsonCache = newCache;
      new File('agentstats-${time}.json').writeAsStringSync(jsonCache);
      print('Wrote statfile agentstats-${time}.json');
    }
  });
}
