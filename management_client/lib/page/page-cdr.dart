library management_tool.page.cdr;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:logging/logging.dart';
import 'package:management_tool/controller.dart' as controller;
import 'package:management_tool/eventbus.dart';
import 'package:management_tool/view.dart' as view;
import 'package:openreception_framework/model.dart' as model;

const String _libraryName = 'management_tool.page.cdr';

class Cdr {
  final controller.Cdr _cdrCtrl;
  final DivElement element = new DivElement()
    ..id = 'cdr-page'
    ..hidden = true
    ..classes.addAll(['page'])
    ..style.display = 'flex'
    ..style.flexDirection = 'column';
  final DivElement filter = new DivElement()
    ..style.border = 'solid 1px red'
    ..style.marginLeft = '0.5em';
  final DivElement listing = new DivElement()
    ..style.border = 'solid 1px brown'
    ..style.marginLeft = '0.5em'
    ..style.flexGrow = '1'
    ..style.overflow = 'auto';
  final Logger _log = new Logger('$_libraryName');
  final controller.Organization _orgCtrl;
  final controller.Reception _recCtrl;
  final TableElement table = new TableElement();
  final DivElement totals = new DivElement()
    ..style.border = 'solid 1px blue'
    ..style.marginLeft = '0.5em';
  static const String _viewName = 'cdr';

  Cdr(controller.Cdr this._cdrCtrl, controller.Organization this._orgCtrl,
      controller.Reception this._recCtrl) {
    filter
      ..children = [
        new InputElement()..placeholder = 'ISO8601 fra tidsstempel',
        new InputElement()..placeholder = 'ISO8601 til tidsstempel',
        new InputElement()..placeholder = 'type list | summary',
        new InputElement()..placeholder = 'retning both | inbound | outbound',
        new InputElement()..placeholder = 'reception id',
        new InputElement()..placeholder = 'agent id',
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
        new TableCellElement()..text = 'Besvarede',
        new TableCellElement()..text = 'Trafik',
        new TableCellElement()..text = 'Voicesvar',
        new TableCellElement()..text = 'Mistede'
      ]
      ..style.textAlign = 'center';
    listing.children = [table];

    element.children = [filter, totals, listing];

    _observers();
  }

  /**
   *
   */
  void _fetch() {
    _orgCtrl.list().then((list) {
      final String from = Uri.encodeComponent('2016-03-14');
      final String to = Uri.encodeComponent('2016-03-14T23:59:59');
      final String token = 'feedabbadeadbeef1';
      HttpRequest
          .getString(
              'http://localhost:4090/from/$from/to/$to/kind/summary?token=$token')
          .then((String response) {
        final Map map = JSON.decode(response);
        final List<TableRowElement> rows = new List<TableRowElement>();
        final List<model.CdrSummary> summaries = new List<model.CdrSummary>();

        table.querySelector('tbody')?.remove();
        int totalAnswered = 0;
        int totalInbound = 0;
        double outboundCost = 0.0;

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

          totalAnswered += answered;
          totalInbound += (answered +
              summary.notifiedNotAnswered +
              summary.inboundNotNotified);
          outboundCost += summary.outboundCost;

          rows.add(new TableRowElement()
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
                ..children = [
                  new SpanElement()..text = '$answered',
                  new SpanElement()
                    ..style.color = 'grey'
                    ..style.paddingLeft = '0.5em'
                    ..text =
                        '($answered10 / $answered10To20 / $answered20To60 / $answeredAfter60)'
                ],
              new TableCellElement()
                ..style.textAlign = 'right'
                ..text = (summary.outboundCost / 100).toString(),
              new TableCellElement()
                ..style.textAlign = 'center'
                ..text = summary.inboundNotNotified > 0
                    ? summary.inboundNotNotified
                    : '',
              new TableCellElement()
                ..style.textAlign = 'center'
                ..text = summary.notifiedNotAnswered > 0
                    ? summary.notifiedNotAnswered
                    : ''
            ]);
        });

        table.createTBody()..children = rows;

        totals.text = '$totalAnswered / $totalInbound / ${outboundCost / 100}';
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
