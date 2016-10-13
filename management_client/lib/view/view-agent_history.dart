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

library orm.view.agent_history;

import 'dart:async';
import 'dart:html';

import 'package:orf/model.dart' as model;
import 'package:orm/controller.dart' as controller;
import 'package:orm/view.dart' as view;
import 'package:google_charts/google_charts.dart' as gchart;

class AgentHistoryList {
  Map<int, AgentHistory> _info = {};
  view.AgentTimeLines _agentTimelines;

  final controller.User _userController;

  final Map<int, model.UserReference> _userCache = {};

  final DivElement element = new DivElement();
  final DivElement _grapContainer = new DivElement();
  final SpanElement _ibCounter = new SpanElement();
  final SpanElement _obCounter = new SpanElement();
  final SpanElement _below20s = new SpanElement();
  final SpanElement _unanswered = new SpanElement();
  final SpanElement _above1min = new SpanElement();

  final TableSectionElement _tableBody = new TableElement().createTBody();
  final TableSectionElement _tableHead = new TableElement().createTHead();

  final InputElement _dayInput = new InputElement(type: 'date')
    ..valueAsDate = new DateTime.now().subtract(new Duration(days: 7));

  AgentHistoryList(this._userController) {
    _tableHead.children = [
      new TableCellElement()..text = 'Uid',
      new TableCellElement()..text = 'Navn',
      new TableCellElement()..text = 'Svaret < 20s',
      new TableCellElement()..text = 'Indgående antal',
      new TableCellElement()..text = 'Indgående tid',
      new TableCellElement()..text = 'Udgående antal',
      new TableCellElement()..text = 'Udgående tid',
      new TableCellElement()..text = 'Beskeder sendt',
      new TableCellElement()..text = 'Pauser'
    ];
    _agentTimelines = new view.AgentTimeLines(_userController);

    element.children = [
      new DivElement()
        ..children = [
          _grapContainer,
          new DivElement()
            ..children = [_agentTimelines.element]
            ..style.width = '400%',
          new SpanElement()..text = 'Indgående: ',
          _ibCounter,
          new SpanElement()..text = 'Udgående: ',
          _obCounter,
          new SpanElement()..text = 'Svaret inden 20s: ',
          _below20s,
          new SpanElement()..text = 'Ventet > 1 min: ',
          _above1min,
          new SpanElement()..text = 'Ikke svaret: ',
          _unanswered,
          _dayInput
        ],
      new TableElement()..children = [_tableHead, _tableBody]
    ];
    _observers();
  }

  void _observers() {
    _dayInput.onInput.listen((_) async {
      await render();
    });
  }

  Future render() async {
    if (_userCache.isEmpty) {
      Iterable<model.UserReference> users = await _userController.list();

      for (model.UserReference user in users) {
        _userCache[user.id] = user;
      }
    }

    final summary = await _userController.dailySummary(_dayInput.valueAsDate);

    _tableBody.children = _userCache.values
        .where((model.UserReference uRef) =>
            summary.agentStats.containsKey(uRef.id))
        .map((user) {
      _info[user.id] = new AgentHistory.fromModel(user);

      return _info[user.id].element;
    }).toList(growable: false);

    for (model.AgentStatSummary agentStatSummary in summary.agentStats.values) {
      if (!_info.containsKey(agentStatSummary.uid)) {
        continue;
      }

      _info[agentStatSummary.uid].updateSummary(agentStatSummary);

      // _uidCell.text =
      //     'pause + ${agentStatSummary.pauseDuration}, '
      //     'ob: ${agentStatSummary.outBoundCount} (${_prettyDuration(agentStatSummary.outboundDuration)})}, '
      //     'msg: ${agentStatSummary.messagesSent}, '
      //     '<20s: ${agentStatSummary.callsAnsweredWithin20s}';
    }

    final num avgGood = summary.inboundCount > 0
        ? (summary.callsAnsweredWithin20s /
                (summary.inboundCount - summary.callsUnAnswered)) *
            100
        : 0;

    final num avgBad = summary.inboundCount > 0
        ? (summary.callWaitingMoreThanOneMinute / summary.inboundCount) * 100
        : 0;

    _ibCounter.text = summary.inboundCount.toString();
    _obCounter.text = summary.outBoundCount.toString();
    _below20s.text = summary.callsAnsweredWithin20s.toString() +
        '(${avgGood.toStringAsFixed(1)}%)';
    _above1min.text = summary.callWaitingMoreThanOneMinute.toString() +
        '(${avgBad.toStringAsFixed(1)}%)';
    _unanswered.text = summary.callsUnAnswered.toString();

    final report = await _userController.dailyReport(_dayInput.valueAsDate);

    List<List> values = [
      ['Second of day', 'Queue Size']
    ];

    report.queuesizes().forEach((DateTime t, int s) {
      final int normalizedSecondOfday = (t.millisecondsSinceEpoch -
              _dayInput.valueAsDate.millisecondsSinceEpoch) ~/
          1000;

      values.add([normalizedSecondOfday, s]);
    });

    await gchart.LineChart.load().then((_) async {
      var data = gchart.arrayToDataTable(values);

      var options = {'title': 'Daglig køudvikling'};

      var chart = new gchart.LineChart(_grapContainer);

      chart.draw(data, options);
    });
    // Render timelines
    _agentTimelines.render(report, _dayInput.valueAsDate);
  }
}

class AgentHistory {
  final model.UserReference _user;

  final TableCellElement _nameCell = new TableCellElement()
    ..classes.add('name');
  final TableCellElement _uidCell = new TableCellElement();

  final TableCellElement _below20sCell = new TableCellElement();
  final TableCellElement _inboundCell = new TableCellElement();
  final TableCellElement _inboundDurationCell = new TableCellElement();
  final TableCellElement _outboundCell = new TableCellElement();
  final TableCellElement _outboundDurationCell = new TableCellElement();
  final TableCellElement _messageCountCell = new TableCellElement();
  final TableCellElement _pauseCell = new TableCellElement();

  final TableRowElement element = new TableRowElement();

  void updateSummary(model.AgentStatSummary summary) {
    final num avgInboundTime = summary.inboundCount > 0
        ? (summary.inboundDuration.inSeconds / summary.inboundCount) / 60
        : 0;
    final num avgOutboundTime = summary.outBoundCount > 0
        ? (summary.outboundDuration.inSeconds / summary.outBoundCount) / 60
        : 0;

    _inboundCell.text = summary.inboundCount.toString();
    _inboundDurationCell.text =
        (summary.inboundDuration.inSeconds / 60).toStringAsFixed(1).toString() +
            'm (' +
            avgInboundTime.toStringAsFixed(1).toString() +
            'm/kald)';
    _outboundCell.text = summary.outBoundCount.toString();
    _outboundDurationCell.text = (summary.outboundDuration.inSeconds / 60)
            .toStringAsFixed(1)
            .toString() +
        'm (' +
        avgOutboundTime.toStringAsFixed(1).toString() +
        'm/kald)';

    _below20sCell.text = summary.callsAnsweredWithin20s.toString();
    _messageCountCell.text = summary.messagesSent.toString();
    _pauseCell.text =
        (summary.pauseDuration.inSeconds / 60).toStringAsFixed(1).toString() +
            'm';
  }

  /// Default constructor.
  AgentHistory.fromModel(this._user) {
    // Setup visual model.
    element.children = [
      _uidCell..text = _user.id.toString(),
      _nameCell..text = _user.name,
      _below20sCell,
      _inboundCell,
      _inboundDurationCell,
      _outboundCell,
      _outboundDurationCell,
      _messageCountCell,
      _pauseCell
    ];
  }
}
