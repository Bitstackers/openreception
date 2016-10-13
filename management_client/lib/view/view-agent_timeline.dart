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

library orm.view.agent_timeline;

import 'dart:async';
import 'dart:html';
import 'package:intl/intl.dart';

import 'package:orf/model.dart' as model;
import 'package:orm/controller.dart' as controller;

DateFormat _time = new DateFormat.Hm();

class AgentTimeLines {
  final DivElement element = new DivElement();
  final Map<int, model.UserReference> _agentCache = {};
  final controller.User _userController;

  AgentTimeLines(this._userController) {
    element
      ..style.position = 'relative'
      ..style.top = '20px'
      ..children = [];
  }

  Future render(model.DailyReport report, DateTime day) async {
    if (_agentCache.isEmpty) {
      Iterable<model.UserReference> users = await _userController.list();

      for (model.UserReference user in users) {
        _agentCache[user.id] = user;
      }
    }

    final DateTime start = new DateTime(day.year, day.month, day.day, 8);
    final DateTime stop = new DateTime(day.year, day.month, day.day, 17);
    Map queuesizes = report.queuesizes();

    for (DateTime key in queuesizes.keys) {
      print(_time.format(key) + ': ${queuesizes[key]}');
    }

    element.children.clear();

    final int steps = stop.difference(start).inMinutes ~/ 30;
    final DivElement header = new DivElement()..style.height = '20px';
    for (int step = 0; step < steps; step++) {
      final DateTime periodStart = start.add(new Duration(minutes: step * 30));
      final DateTime periodStop =
          start.add(new Duration(minutes: (1 + step) * 30));
      final String minuteString = periodStart.minute > 9
          ? periodStart.minute.toString()
          : '0${periodStart.minute}';
      final String datelabel = '${periodStart.hour}:${minuteString}';

      final callsInrange = report.callHistory.where((model.HistoricCall call) =>
          call.agentStart.isAfter(periodStart) &&
          call.agentStart.isBefore(periodStop));

      final int unanswered = callsInrange
          .where((model.HistoricCall call) => !call.isAnswered)
          .length;

      final answeredCalls = callsInrange
          .where((model.HistoricCall call) => call.isAnswered && call.inbound);

      Duration total = new Duration();

      for (model.HistoricCall call in answeredCalls) {
        total += call.answerLatency;
      }

      final num answerlatency =
          total.inMilliseconds / (answeredCalls.length * 1000);

      header.children.add(new SpanElement()
        ..style.position = 'absolute'
        ..style.height = '100%'
        ..style.left = (100 * step / steps).toString() + '%'
        ..style.borderLeft = '1px solid grey'
        ..style.fontSize = '70%'
        ..text = datelabel +
            ' - $unanswered kald ikke svaret. Gns svartid: ${answerlatency.toStringAsFixed(1)}s');
    }
    element.children.add(header);

    for (int uid in report.uids.where((int uid) => uid != model.User.noId)) {
      final timeline = new AgentTimeLine(_agentRef(uid), start, stop);
      element.children.add(timeline.element);
      timeline.calls = report.callsOfUid(uid);
      timeline.messages = report.messagesOfUid(uid);
      timeline.pauses = report.userStatesOf(uid);
    }
  }

  _agentRef(int uid) => _agentCache.containsKey(uid)
      ? _agentCache[uid]
      : new model.UserReference(uid, '??');
}

class AgentTimeLine {
  final DivElement element = new DivElement();
  final DivElement _timeline = new DivElement();
  final DateTime _start;
  final DateTime _stop;

  num get _width => _stop.difference(_start).inSeconds;

  AgentTimeLine(model.UserReference uRef, this._start, this._stop) {
    element
      ..children = [
        _timeline
          ..style.position = 'relative'
          ..style.backgroundColor = '#eee'
          ..style.height = '25pt'
          ..style.width = '100%',
        new DivElement()
          ..children = [
            new SpanElement()..text = '${uRef.name} (uid:${uRef.id})'
          ]
      ]
      ..style.clear = 'right';
  }

  set calls(Iterable<model.HistoricCall> calls) {
    for (model.HistoricCall call in calls) {
      try {
        final String callHistory = call.events
            .map((var callevent) =>
                '${_time.format(callevent.timestamp)} - ${callevent.eventName}')
            .join('\n');
        final String colour = call.inbound ? '#0f9d58' : 'darkorange';
        final num width = 100 * call.handleTime.inSeconds / _width;
        final int top = call.inbound ? 0 : 5;
        final num margin =
            100 * call.agentStart.difference(_start).inSeconds / _width;

        _timeline.children.add(new DivElement()
          ..classes.add('historic-call')
          ..style.left = '${margin}%'
          ..style.marginTop = '${top}pt'
          ..style.width = '${width}%'
          ..style.backgroundColor = colour
          ..title = call.callId + '\n' + callHistory);
      } catch (e) {
        print(e);
      }
    }
  }

  set messages(Iterable<model.MessageHistory> msgs) {
    final String colour = 'darkblue';
    for (model.MessageHistory msg in msgs) {
      try {
        final int top = 10;
        final num margin =
            100 * msg.createdAt.difference(_start).inSeconds / _width;

        _timeline.children.add(new DivElement()
          ..classes.add('historic-message')
          ..style.position = 'absolute'
          ..style.left = '${margin}%'
          ..style.marginTop = '${top}pt'
          ..style.backgroundColor = colour
          ..style.minWidth = '2pt'
          ..style.float = 'left'
          ..style.height = '5pt'
          ..title = msg.mid.toString() + '\n' + _time.format(msg.createdAt));
      } catch (e) {
        print(e);
      }
    }
  }

  set pauses(Iterable<model.UserStateHistory> ushs) {
    model.UserStateHistory lastState;
    for (model.UserStateHistory ush in ushs) {
      if (ush.timestamp.isBefore(_start)) {
        continue;
      }

      if (lastState != null && lastState.pause && !ush.pause) {
        try {
          final Duration delta = ush.timestamp.difference(lastState.timestamp);
          final String colour = 'rgba(0, 0, 0, 0.1)';
          final num width = 100 * delta.inSeconds / _width;
          final int top = 15;
          final num margin =
              100 * lastState.timestamp.difference(_start).inSeconds / _width;
          final String label = delta.inMinutes.toString() + 'm';

          _timeline.children.add(new DivElement()
            ..classes.add('historic-pause')
            ..style.position = 'absolute'
            ..style.left = '${margin}%'
            ..style.marginTop = '${top}pt'
            ..style.float = 'left'
            ..style.width = '${width}%'
            ..style.height = '10pt'
            ..style.overflow = 'hidden'
            ..style.backgroundColor = colour
            ..style.textAlign = 'center'
            ..style.padding = '1px'
            ..style.fontSize = '70%'
            ..title = label +
                '\n' +
                _time.format(lastState.timestamp) +
                ' - ' +
                _time.format(ush.timestamp)
            ..text = label);
        } catch (e) {
          print(e);
        }
      }
      lastState = ush;
    }
  }
}
