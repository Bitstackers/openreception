library management_tool.page.cdr;

import 'dart:html';

import 'package:logging/logging.dart';
import 'package:management_tool/controller.dart' as controller;
import 'package:management_tool/eventbus.dart';
import 'package:openreception_framework/model.dart' as model;

const String _libraryName = 'management_tool.page.cdr';

class Cdr {
  final controller.Cdr _cdrCtrl;
  InputElement directionInput;
  final DivElement element = new DivElement()
    ..id = 'cdr-page'
    ..hidden = true
    ..classes.addAll(['page'])
    ..style.display = 'flex'
    ..style.flexDirection = 'column';
  final DivElement filter = new DivElement()..style.marginLeft = '0.5em';
  InputElement fromInput;
  InputElement kindInput;
  final DivElement listing = new DivElement()
    ..style.margin = '0 0 0 1em'
    ..style.flexGrow = '1'
    ..style.overflow = 'auto';
  final Logger _log = new Logger('$_libraryName');
  final controller.Organization _orgCtrl;
  final controller.Reception _recCtrl;
  InputElement ridInput;
  final TableElement table = new TableElement();
  InputElement toInput;
  final DivElement totals = new DivElement()
    ..style.margin = '0.5em 0 1em 1.5em';
  InputElement uidInput;
  static const String _viewName = 'cdr';

  Cdr(controller.Cdr this._cdrCtrl, controller.Organization this._orgCtrl,
      controller.Reception this._recCtrl) {
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
    kindInput = new InputElement()
      ..placeholder = 'type list | summary'
      ..value = 'summary'
      ..disabled = true;
    directionInput = new InputElement()
      ..placeholder = 'retning both | inbound | outbound'
      ..value = 'both'
      ..disabled = true;
    ridInput = new InputElement()..placeholder = 'reception id';
    uidInput = new InputElement()
      ..placeholder = 'agent id'
      ..disabled = true;

    filter
      ..children = [
        fromInput,
        toInput,
        kindInput,
        directionInput,
        ridInput,
        uidInput,
        new ButtonElement()
          ..text = 'hent'
          ..classes.add('create')
          ..onClick.listen((_) => _fetch()),
      ];

    table.createTHead()
      ..children = [
        new TableCellElement()..text = 'Organisation',
        new TableCellElement()..text = 'Reception',
        new TableCellElement()..text = 'Ind total',
        new TableCellElement()..text = 'Trafik',
        new TableCellElement()..text = 'Besvarede',
        new TableCellElement()..text = 'Voicesvar',
        new TableCellElement()..text = 'Mistede',
        new TableCellElement()..text = 'Gns. samtaletid',
        new TableCellElement()..text = 'Korte kald',
        new TableCellElement()..text = 'Lange kald'
      ]
      ..style.textAlign = 'center';
    listing.children = [table];

    element.children = [filter, totals, listing];

    _observers();
  }

  /**
   *
   */
  String averageString(int dividend, int divisor) {
    if (divisor == 0) {
      return '';
    }

    return (dividend / divisor).ceilToDouble().toString();
  }

  /**
   *
   */
  void _fetch() {
    _orgCtrl.list().then((list) {
      final DateTime from = DateTime.parse(fromInput.value);
      final DateTime to = DateTime.parse(toInput.value);

      _cdrCtrl
          .summaries(from, to, ridInput.value)
          .then((Map<String, dynamic> map) {
        final List<TableRowElement> rows = new List<TableRowElement>();
        final List<model.CdrSummary> summaries = new List<model.CdrSummary>();

        /// Reset total counters and tbody element.
        table.querySelector('tbody')?.remove();
        int totalAnswered = 0;
        int totalInbound = 0;
        int totalInboundBillSec = 0;
        int totalInboundNotNotified = 0;
        int totalLongCalls = 0;
        int totalNotifiedNotAnswered = 0;
        double totalOutboundCost = 0.0;
        int totalShortCalls = 0;

        map['summaries'].forEach((Map m) {
          summaries.add(new model.CdrSummary.fromJson(m));
        });

        summaries.sort((a, b) => a.rid.compareTo(b.rid));

        summaries.forEach((model.CdrSummary summary) {
          final int answered = summary.agentSummaries
              .fold(0, (acc, model.CdrAgentSummary a) => acc + a.answered);
          final int answered10 = summary.agentSummaries
              .fold(0, (acc, model.CdrAgentSummary a) => acc + a.answered10);
          final int answered10To20 = summary.agentSummaries.fold(
              0, (acc, model.CdrAgentSummary a) => acc + a.answered10To20);
          final int answered20To60 = summary.agentSummaries.fold(
              0, (acc, model.CdrAgentSummary a) => acc + a.answered20To60);
          final int answeredAfter60 = summary.agentSummaries.fold(
              0, (acc, model.CdrAgentSummary a) => acc + a.answeredAfter60);
          final int inboundBillSeconds = summary.agentSummaries.fold(
              0, (acc, model.CdrAgentSummary a) => acc + a.inboundBillSeconds);
          final int longCalls = summary.agentSummaries
              .fold(0, (acc, model.CdrAgentSummary a) => acc + a.longCalls);
          final int shortCalls = summary.agentSummaries
              .fold(0, (acc, model.CdrAgentSummary a) => acc + a.shortCalls);

          totalAnswered += answered;
          totalInbound += (answered +
              summary.notifiedNotAnswered +
              summary.inboundNotNotified);
          totalInboundBillSec += inboundBillSeconds;
          totalInboundNotNotified += summary.inboundNotNotified;
          totalLongCalls += longCalls;
          totalNotifiedNotAnswered += summary.notifiedNotAnswered;
          totalOutboundCost += summary.outboundCost;
          totalShortCalls += shortCalls;

          rows.add(new TableRowElement()
            ..onClick.listen((MouseEvent event) {
              final Element target = event.currentTarget;
              final String color = target.style.color;
              if (color == 'red') {
                target.style.color = 'blue';
              } else if (color == 'blue') {
                target.style.color = 'grey';
              } else if (color == 'grey') {
                target.style.color = '';
              } else {
                target.style.color = 'red';
              }
            })
            ..children = [
              new TableCellElement()..text = 'Some Org',
              new TableCellElement()..text = summary.rid.toString(),
              new TableCellElement()
                ..style.textAlign = 'center'
                ..text = (answered +
                        summary.inboundNotNotified +
                        summary.notifiedNotAnswered)
                    .toString(),
              new TableCellElement()
                ..style.textAlign = 'right'
                ..text = (summary.outboundCost / 100).toString(),
              new TableCellElement()
                ..style.textAlign = 'right'
                ..children = [
                  new SpanElement()..text = '$answered',
                  new SpanElement()
                    ..style.color = 'grey'
                    ..style.paddingLeft = '0.5em'
                    ..text =
                        '($answered10 / $answered10To20 / $answered20To60 / $answeredAfter60)'
                ],
              new TableCellElement()
                ..style.textAlign = 'center'
                ..text = summary.inboundNotNotified > 0
                    ? summary.inboundNotNotified
                    : '',
              new TableCellElement()
                ..style.textAlign = 'center'
                ..text = summary.notifiedNotAnswered > 0
                    ? summary.notifiedNotAnswered
                    : '',
              new TableCellElement()
                ..style.textAlign = 'right'
                ..text = averageString(inboundBillSeconds, answered),
              new TableCellElement()
                ..style.textAlign = 'center'
                ..text = '$shortCalls',
              new TableCellElement()
                ..style.textAlign = 'center'
                ..text = '$longCalls'
            ]);
        });

        table.createTBody()..children = rows;

        totals.text = 'Total ind: $totalInbound'
            ' / Svarede: $totalAnswered'
            ' / Voicesvar: $totalInboundNotNotified'
            ' / Mistede: $totalNotifiedNotAnswered'
            ' / Korte kald: $totalShortCalls'
            ' / Lange kald: $totalLongCalls'
            ' / Teleomkostning: ${totalOutboundCost / 100}'
            ' / Gns. samtaletid: ${averageString(totalInboundBillSec, totalAnswered)}'
            ' / callChargeMultiplier: ${map['callChargeMultiplier']}'
            ' / shortCallBoundary: ${map['shortCallBoundaryInSeconds']}'
            ' / longCallBoundary: ${map['longCallBoundaryInSeconds']}';
      });
    });
  }

  /**
   * Observers.
   */
  void _observers() {
    bus.on(WindowChanged).listen((WindowChanged event) async {
      if (event.window == _viewName) {
        element.hidden = false;
      } else {
        element.hidden = true;
      }
    });
  }
}
