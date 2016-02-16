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
library openreception.user_socket_logger;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import '../lib/configuration.dart';

import 'package:openreception_framework/event.dart' as event;

import 'package:openreception_framework/model.dart' as model;

import 'package:openreception_framework/service.dart' as service;
import 'package:openreception_framework/service-io.dart' as transport;

final Map<int, String> _userNameCache = {};

class CallSummary {
  int totalCalls = 0;
  int callsAnsweredWithin20s = 0;
  int callsUnAnswered = 0;
  int callWaitingMoreThanOneMinute = 0;
  int talkTime = 0;
  Map<int, int> callsByAgent = {};

  List<Map<int, int>> agentSummay() {
    List<Map<int, int>> ret = [];
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
  DateTime arrived;
  DateTime answered;
  int userId = model.User.noID;
}

CallSummary totalSummary(Map<String, CallStat> history) {
  CallSummary summary = new CallSummary()..totalCalls = history.length;
  history.values.forEach((CallStat stat) {
    if (stat.answered != null) {
      final Duration answerLatencyInMs =
          stat.answered.difference(stat.arrived).abs();
      if (answerLatencyInMs < new Duration(seconds: 20)) {
        summary.callsAnsweredWithin20s++;
      } else if (answerLatencyInMs > new Duration(minutes: 1)) {
        summary.callWaitingMoreThanOneMinute++;
      }
    } else {
      summary.callsUnAnswered++;
    }

    if (stat.userId != model.User.noID) {
      summary.callsByAgent[stat.userId] = summary.callsByAgent
          .containsKey(stat.userId) ? summary.callsByAgent[stat.userId]++ : 1;
    }
  });

  return summary;
}

Future main(List<String> args) async {
  Map<String, CallStat> _history = {};

  transport.WebSocketClient client = new transport.WebSocketClient();
  await client.connect(Uri.parse(
      '${config.configserver.notificationSocketUri}?token=${config.authServer.serverToken}'));

  service.NotificationSocket notificationSocket =
      new service.NotificationSocket(client);
  service.RESTUserStore userStore = new service.RESTUserStore(
      config.configserver.userServerUri,
      config.authServer.serverToken,
      new transport.Client());

  await userStore.list().then((Iterable<model.User> users) {
    users.forEach((user) {
      _userNameCache[user.id] = user.name;
    });
  });

  dispatchEvent(event.Event e) async {
    if (e is event.CallEvent) {
      if (!_history.containsKey(e.call.ID)) {
        _history[e.call.ID] = new CallStat()..arrived = e.call.arrived;
      }

      if (e is event.CallPickup &&
          _history[e.call.ID].userId == model.User.noID) {
        _history[e.call.ID]
          ..userId = e.call.assignedTo
          ..answered = new DateTime.now();
        new File('/tmp/agentstats.json')
            .writeAsString(JSON.encode(totalSummary(_history)));
      }
    }
  }
  notificationSocket.eventStream.listen((event.Event e) {
    try {
      dispatchEvent(e);
    } catch (e, s) {}
  });
}
