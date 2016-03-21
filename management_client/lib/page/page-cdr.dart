library management_tool.page.cdr;

import 'dart:async';
import 'dart:html';

import 'package:management_tool/controller.dart' as controller;
import 'package:management_tool/eventbus.dart';
import 'package:openreception_framework/model.dart' as model;

const String _libraryName = 'management_tool.page.cdr';

final Map<model.CdrEntryState, String> actorMap = {
  model.CdrEntryState.agentChannel: 'agentkanal',
  model.CdrEntryState.inboundNotNotified: 'pbx',
  model.CdrEntryState.notifiedAnsweredByAgent: 'agent',
  model.CdrEntryState.notifiedNotAnswered: 'ubesvaret',
  model.CdrEntryState.outboundByAgent: 'agent',
  model.CdrEntryState.outboundByPbx: 'pbx',
  model.CdrEntryState.unknown: 'ukendt'
};

final Map<model.CdrEntryState, String> directionMap = {
  model.CdrEntryState.agentChannel: 'agentkanal',
  model.CdrEntryState.inboundNotNotified: 'ind',
  model.CdrEntryState.notifiedAnsweredByAgent: 'ind',
  model.CdrEntryState.notifiedNotAnswered: 'ind',
  model.CdrEntryState.outboundByAgent: 'ud',
  model.CdrEntryState.outboundByPbx: 'ud',
  model.CdrEntryState.unknown: 'ukendt'
};

class Context {
  String name;
  String orgName;
  String recName;
  model.CdrEntry entry;
  model.CdrSummary summary;
}

class Cdr {
  final controller.Cdr _cdrCtrl;
  InputElement directionInput;
  final DivElement element = new DivElement()
    ..id = 'cdr-page'
    ..hidden = true
    ..classes.addAll(['page']);
  ButtonElement fetchButton;
  final DivElement filter = new DivElement()..style.marginLeft = '0.5em';
  InputElement fromInput;
  SelectElement kindSelect = new SelectElement()
    ..style.height = '28px'
    ..children = [
      new OptionElement()
        ..text = 'summering'
        ..value = 'summary'
        ..selected = true,
      new OptionElement()
        ..text = 'liste'
        ..value = 'list'
    ];
  final DivElement listing = new DivElement()
    ..style.margin = '0 0 0 1em'
    ..style.flexGrow = '1'
    ..style.overflow = 'auto';
  final controller.Organization _orgCtrl;
  InputElement ridInput;
  InputElement toInput;
  final DivElement totals = new DivElement()
    ..style.margin = '0.5em 0 1em 1.5em';
  InputElement uidInput;
  final controller.User _userCtrl;
  static const String _viewName = 'cdr';

  Cdr(controller.Cdr this._cdrCtrl, controller.Organization this._orgCtrl,
      controller.User this._userCtrl) {
    final DateTime now = new DateTime.now();
    final DateTime from = new DateTime(now.year, now.month, now.day);
    final DateTime to =
        new DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    fromInput = new InputElement()
      ..placeholder = 'ISO8601 fra tidsstempel'
      ..value = from.toIso8601String().split('.').first;
    toInput = new InputElement()
      ..placeholder = 'ISO8601 til tidsstempel'
      ..value = to.toIso8601String().split('.').first;
    directionInput = new InputElement()
      ..placeholder = 'retning both | inbound | outbound'
      ..value = 'both'
      ..disabled = true;
    ridInput = new InputElement()..placeholder = 'reception id';
    uidInput = new InputElement()
      ..placeholder = 'agent id'
      ..disabled = true;
    fetchButton = new ButtonElement()
      ..text = 'hent'
      ..classes.add('create')
      ..onClick.listen((_) => _fetch());

    filter
      ..children = [
        fromInput,
        toInput,
        kindSelect,
        directionInput,
        ridInput,
        uidInput,
        fetchButton,
      ];

    element.children = [filter, totals, listing];

    _observers();
  }

  String averageString(int dividend, int divisor) {
    if (divisor == 0) {
      return '';
    }

    return (dividend / divisor).ceilToDouble().toString();
  }

  String epochToString(int epoch, {bool withDate: true}) {
    if (epoch == 0) {
      return '';
    } else {
      final String stamp = new DateTime.fromMillisecondsSinceEpoch(epoch * 1000)
          .toIso8601String()
          .split('.')
          .first;
      if (withDate) {
        return stamp.replaceAll('T', ' ');
      } else {
        return stamp.split('T').last;
      }
    }
  }

  Future _fetch() async {
    final DateTime from = DateTime.parse(fromInput.value);
    Map<String, dynamic> ridToNameMap;
    final DateTime to = DateTime.parse(toInput.value);
    Map<int, String> uidToNameMap = new Map<int, String>();

    listing.children.clear();
    totals.children.clear();

    fetchButton.disabled = true;
    fetchButton.style.backgroundColor = 'grey';
    fetchButton.text = 'Henter...';

    ridToNameMap = (await _orgCtrl.receptionMap());
    for (model.User user in (await _userCtrl.list())) {
      uidToNameMap[user.id] = user.name;
    }

    if (kindSelect.value == 'summary') {
      await _fetchSummaries(from, to, ridToNameMap);
    } else if (kindSelect.value == 'list') {
      await _fetchList(from, to, ridToNameMap, uidToNameMap);
    }

    fetchButton.disabled = false;
    fetchButton.style.backgroundColor = '';
    fetchButton.text = 'Hent';
  }

  Future _fetchList(DateTime from, DateTime to,
      Map<String, dynamic> ridToNameMap, Map<int, String> uidToNameMap) async {
    final List<Context> contexts = new List<Context>();
    final Map<String, dynamic> map = (await _cdrCtrl.list(
        from, to, directionInput.value, ridInput.value, uidInput.value));
    final List<TableRowElement> rows = new List<TableRowElement>();
    final TableElement table = new TableElement();

    table.createTHead()
      ..children = [
        new TableCellElement()..text = 'start',
        new TableCellElement()..text = 'retning',
        new TableCellElement()..text = 'aktør',
        new TableCellElement()..text = 'besvaret',
        new TableCellElement()..text = 'ventetid',
        new TableCellElement()..text = 'reception',
        new TableCellElement()..text = 'agent',
        new TableCellElement()..text = 'cdr fil'
      ]
      ..style.textAlign = 'center';
    listing.children = [table];

    for (Map m in (map['entries'] as List)) {
      final model.CdrEntry entry = new model.CdrEntry.fromJson(m);
      if (ridToNameMap.containsKey(entry.rid.toString())) {
        contexts.add(new Context()
          ..name = ridToNameMap[entry.rid.toString()]['organization'] +
              ridToNameMap[entry.rid.toString()]['reception']
          ..orgName = ridToNameMap[entry.rid.toString()]['organization']
          ..recName = ridToNameMap[entry.rid.toString()]['reception']
          ..entry = entry);
      } else {
        contexts.add(new Context()
          ..name = '.....${entry.rid.toString()}'
          ..orgName = ''
          ..recName = entry.rid.toString()
          ..entry = entry);
      }
    }

    contexts.sort((a, b) => a.entry.startEpoch.compareTo(b.entry.startEpoch));

    String answerTime(model.CdrEntry entry) {
      return entry.agentBeginEpoch > 0
          ? '${epochToString(entry.agentBeginEpoch, withDate: false)}'
          : entry.answerEpoch > 0
              ? '${epochToString(entry.answerEpoch, withDate: false)}'
              : '';
    }

    String waitDuration(model.CdrEntry entry) {
      Duration d;
      String durationToString(Duration d) => d.toString().split('.').first;

      switch (entry.state) {
        case model.CdrEntryState.agentChannel:
        case model.CdrEntryState.unknown:
          return '';
        case model.CdrEntryState.inboundNotNotified:
          d = new Duration(seconds: entry.answerEpoch - entry.startEpoch);
          break;
        case model.CdrEntryState.notifiedAnsweredByAgent:
          d = new Duration(seconds: entry.agentBeginEpoch - entry.startEpoch);
          break;
        case model.CdrEntryState.notifiedNotAnswered:
          d = new Duration(seconds: entry.endEpoch - entry.startEpoch);
          break;
        case model.CdrEntryState.outboundByAgent:
        case model.CdrEntryState.outboundByPbx:
          if (entry.answerEpoch > 0) {
            d = new Duration(seconds: entry.answerEpoch - entry.startEpoch);
          } else {
            d = new Duration(seconds: entry.endEpoch - entry.startEpoch);
          }
      }

      return durationToString(d);
    }

    for (Context c in contexts) {
      rows.add(new TableRowElement()
        ..children = [
          new TableCellElement()
            ..title = c.entry.state.toString().split('.').last
            ..text = epochToString(c.entry.startEpoch),
          new TableCellElement()
            ..style.textAlign = 'center'
            ..text = directionMap[c.entry.state],
          new TableCellElement()
            ..style.textAlign = 'center'
            ..text = actorMap[c.entry.state],
          new TableCellElement()
            ..style.textAlign = 'center'
            ..text = answerTime(c.entry),
          new TableCellElement()
            ..style.textAlign = 'center'
            ..text = waitDuration(c.entry).toString().split('.').first,
          new TableCellElement()..text = c.recName,
          new TableCellElement()..text = uidToNameMap[c.entry.uid],
          new TableCellElement()..text = c.entry.filename
        ]);
    }

    table.createTBody()..children = rows;
  }

  Future _fetchSummaries(
      DateTime from, DateTime to, Map<String, dynamic> ridToNameMap) async {
    final List<Context> contexts = new List<Context>();
    final Map<String, dynamic> map =
        (await _cdrCtrl.summaries(from, to, ridInput.value));
    final List<TableRowElement> rows = new List<TableRowElement>();
    final TableElement table = new TableElement();

    table.createTHead()
      ..children = [
        new TableCellElement()..text = 'organisation',
        new TableCellElement()..text = 'reception',
        new TableCellElement()..text = 'ind total',
        new TableCellElement()..text = 'trafik',
        new TableCellElement()..text = 'besvarede',
        new TableCellElement()..text = 'udgående',
        new TableCellElement()..text = 'voicesvar',
        new TableCellElement()..text = 'mistede',
        new TableCellElement()..text = 'gns. samtaletid',
        new TableCellElement()..text = 'korte kald',
        new TableCellElement()..text = 'lange kald'
      ]
      ..style.textAlign = 'center';
    listing.children = [table];

    /// Reset total counters and tbody element.
    table.querySelector('tbody')?.remove();
    int totalAnswered = 0;
    int totalAnsweredAfter60 = 0;
    int totalAnsweredBefore20 = 0;
    int totalInbound = 0;
    int totalInboundBillSec = 0;
    int totalInboundNotNotified = 0;
    int totalLongCalls = 0;
    int totalNotifiedNotAnswered = 0;
    int totalOutboundAgent = 0;
    int totalOutboundPbx = 0;
    double totalOutboundCost = 0.0;
    int totalShortCalls = 0;

    for (Map m in (map['summaries'] as List)) {
      final model.CdrSummary summary = new model.CdrSummary.fromJson(m);
      if (ridToNameMap.containsKey(summary.rid.toString())) {
        contexts.add(new Context()
          ..name = ridToNameMap[summary.rid.toString()]['organization'] +
              ridToNameMap[summary.rid.toString()]['reception']
          ..orgName = ridToNameMap[summary.rid.toString()]['organization']
          ..recName = ridToNameMap[summary.rid.toString()]['reception']
          ..summary = summary);
      } else {
        contexts.add(new Context()
          ..name = '.....${summary.rid.toString()}'
          ..orgName = ''
          ..recName = summary.rid.toString()
          ..summary = summary);
      }
    }

    contexts
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    for (Context c in contexts) {
      final int answered = c.summary.agentSummaries
          .fold(0, (acc, model.CdrAgentSummary a) => acc + a.answered);
      final int answered10 = c.summary.agentSummaries
          .fold(0, (acc, model.CdrAgentSummary a) => acc + a.answered10);
      final int answered10To20 = c.summary.agentSummaries
          .fold(0, (acc, model.CdrAgentSummary a) => acc + a.answered10To20);
      final int answered20To60 = c.summary.agentSummaries
          .fold(0, (acc, model.CdrAgentSummary a) => acc + a.answered20To60);
      final int answeredAfter60 = c.summary.agentSummaries
          .fold(0, (acc, model.CdrAgentSummary a) => acc + a.answeredAfter60);
      final int inboundBillSeconds = c.summary.agentSummaries.fold(
          0, (acc, model.CdrAgentSummary a) => acc + a.inboundBillSeconds);
      final int longCalls = c.summary.agentSummaries
          .fold(0, (acc, model.CdrAgentSummary a) => acc + a.longCalls);
      final int outboundAgent = c.summary.agentSummaries
          .fold(0, (acc, model.CdrAgentSummary a) => acc + a.outbound);
      final int shortCalls = c.summary.agentSummaries
          .fold(0, (acc, model.CdrAgentSummary a) => acc + a.shortCalls);

      totalAnswered += answered;
      totalAnsweredAfter60 += answeredAfter60;
      totalAnsweredBefore20 += answered10 + answered10To20;
      totalInbound += (answered +
          c.summary.notifiedNotAnswered +
          c.summary.inboundNotNotified);
      totalInboundBillSec += inboundBillSeconds;
      totalInboundNotNotified += c.summary.inboundNotNotified;
      totalLongCalls += longCalls;
      totalNotifiedNotAnswered += c.summary.notifiedNotAnswered;
      totalOutboundAgent += outboundAgent;
      totalOutboundCost += c.summary.outboundCost;
      totalOutboundPbx += c.summary.outboundByPbx;
      totalShortCalls += shortCalls;

      rows.add(new TableRowElement()
        ..onClick.listen((MouseEvent event) {
          final Element target = event.currentTarget;
          final String color = target.style.color;
          if (color == 'red') {
            target.style.color = 'blue';
          } else if (color == 'blue') {
            target.style.color = 'lightgrey';
          } else if (color == 'lightgrey') {
            target.style.color = '';
          } else {
            target.style.color = 'red';
          }
        })
        ..children = [
          new TableCellElement()..text = c.orgName,
          new TableCellElement()
            ..text = c.recName
            ..title = c.summary.rid.toString(),
          new TableCellElement()
            ..style.textAlign = 'center'
            ..text = (answered +
                    c.summary.inboundNotNotified +
                    c.summary.notifiedNotAnswered)
                .toString()
            ..title = 'Ind total',
          new TableCellElement()
            ..style.textAlign = 'right'
            ..text = (c.summary.outboundCost / 100).toString()
            ..title = 'Trafik',
          new TableCellElement()
            ..style.textAlign = 'right'
            ..children = [
              new SpanElement()
                ..text = '$answered'
                ..title = 'Besvarede',
              new SpanElement()
                ..style.color = 'grey'
                ..style.paddingLeft = '0.5em'
                ..text =
                    '($answered10 / $answered10To20 / $answered20To60 / $answeredAfter60)'
                ..title = '>10, 10-20, 20-60, >60'
            ],
          new TableCellElement()
            ..style.textAlign = 'center'
            ..text = (c.summary.outboundByPbx + outboundAgent).toString()
            ..title = 'Udgående',
          new TableCellElement()
            ..style.textAlign = 'center'
            ..text = c.summary.inboundNotNotified > 0
                ? c.summary.inboundNotNotified
                : ''
            ..title = 'Voicesvar',
          new TableCellElement()
            ..style.textAlign = 'center'
            ..text = c.summary.notifiedNotAnswered > 0
                ? c.summary.notifiedNotAnswered
                : ''
            ..title = 'Mistede',
          new TableCellElement()
            ..style.textAlign = 'right'
            ..text = averageString(inboundBillSeconds, answered)
            ..title = 'Gns. samtaletid',
          new TableCellElement()
            ..style.textAlign = 'center'
            ..text = '$shortCalls'
            ..title = 'Korte kald',
          new TableCellElement()
            ..style.textAlign = 'center'
            ..text = '$longCalls'
            ..title = 'Lange kald'
        ]);
    }

    table.createTBody()..children = rows;

    setSummaryTotalsNode(
        totalInbound,
        totalAnswered,
        totalAnsweredAfter60,
        totalAnsweredBefore20,
        totalInboundNotNotified,
        totalNotifiedNotAnswered,
        totalShortCalls,
        totalLongCalls,
        totalOutboundAgent,
        totalOutboundCost,
        totalOutboundPbx,
        totalInboundBillSec,
        map['callChargeMultiplier'],
        map['shortCallBoundaryInSeconds'],
        map['longCallBoundaryInSeconds']);
  }

  void _observers() {
    bus.on(WindowChanged).listen((WindowChanged event) async {
      if (event.window == _viewName) {
        element.hidden = false;
        element.style.display = 'flex';
        element.style.flexDirection = 'column';
      } else {
        element.hidden = true;
        element.style.display = '';
        element.style.flexDirection = '';
      }
    });
  }

  /**
   * Populate the summary totals node.
   */
  void setSummaryTotalsNode(
      int totalInbound,
      int totalAnswered,
      int totalAnsweredAfter60,
      int totalAnsweredBefore20,
      int totalInboundNotNotified,
      int totalNotifiedNotAnswered,
      int totalShortCalls,
      int totalLongCalls,
      int totalOutboundAgent,
      double totalOutboundCost,
      int totalOutboundPbx,
      int totalInboundBillSec,
      double callChargeMultiplier,
      int shortCallBoundaryInSeconds,
      int longCallBoundaryInSeconds) {
    final DivElement inboundData = new DivElement()
      ..text = 'Total ind: $totalInbound'
          ' / Svarede: $totalAnswered'
          ' / <=20: ${(totalAnsweredBefore20 / totalAnswered * 100).toStringAsPrecision(2)}%'
          ' / +60: ${(totalAnsweredAfter60 / totalAnswered * 100).toStringAsPrecision(2)}%'
          ' / Gns. samtaletid: ${averageString(totalInboundBillSec, totalAnswered)}'
          ' / Voicesvar: $totalInboundNotNotified'
          ' / Mistede: $totalNotifiedNotAnswered';
    final DivElement metadata = new DivElement()
      ..text = 'Korte kald: $totalShortCalls'
          ' / Lange kald: $totalLongCalls'
          ' / shortCallBoundary: $shortCallBoundaryInSeconds'
          ' / longCallBoundary: $longCallBoundaryInSeconds'
          ' / callChargeMultiplier: $callChargeMultiplier';
    final DivElement outboundData = new DivElement()
      ..text = 'Udgående agent: $totalOutboundAgent'
          ' / Udgående PBX: $totalOutboundPbx'
          ' / Teleomkostning: ${totalOutboundCost / 100}';
    totals..children = [inboundData, outboundData, metadata];
  }
}
