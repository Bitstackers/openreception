library management_tool.page.cdr;

import 'dart:async';
import 'dart:html';

// import 'package:logging/logging.dart';
import 'package:management_tool/controller.dart' as controller;
import 'package:management_tool/eventbus.dart';
import 'package:openreception_framework/model.dart' as model;

const String _libraryName = 'management_tool.page.cdr';

class Context {
  String name;
  String orgName;
  String recName;
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
  InputElement kindInput;
  final DivElement listing = new DivElement()
    ..style.margin = '0 0 0 1em'
    ..style.flexGrow = '1'
    ..style.overflow = 'auto';
  // final Logger _log = new Logger('$_libraryName');
  final controller.Organization _orgCtrl;
  final controller.Reception _recCtrl;
  InputElement ridInput;
  final Map<int, Map<String, String>> ridToNameMap =
      new Map<int, Map<String, String>>();
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
    fetchButton = new ButtonElement()
      ..text = 'hent'
      ..classes.add('create')
      ..hidden = true
      ..onClick.listen((_) => _fetch());

    loadOrgsAndReceptions();

    filter
      ..children = [
        fromInput,
        toInput,
        kindInput,
        directionInput,
        ridInput,
        uidInput,
        fetchButton,
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
    final DateTime from = DateTime.parse(fromInput.value);
    final DateTime to = DateTime.parse(toInput.value);

    fetchButton.disabled = true;
    fetchButton.style.backgroundColor = 'grey';

    _cdrCtrl
        .summaries(from, to, ridInput.value)
        .then((Map<String, dynamic> map) {
      final List<TableRowElement> rows = new List<TableRowElement>();
      final List<Context> contexts = new List<Context>();

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
        final model.CdrSummary summary = new model.CdrSummary.fromJson(m);
        if (ridToNameMap.containsKey(summary.rid)) {
          contexts.add(new Context()
            ..name = ridToNameMap[summary.rid]['orgName'] +
                ridToNameMap[summary.rid]['recName']
            ..orgName = ridToNameMap[summary.rid]['orgName']
            ..recName = ridToNameMap[summary.rid]['recName']
            ..summary = summary);
        } else {
          contexts.add(new Context()
            ..name = summary.rid.toString()
            ..orgName = ''
            ..recName = summary.rid.toString()
            ..summary = summary);
        }
      });

      contexts
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      contexts.forEach((Context c) {
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
        final int shortCalls = c.summary.agentSummaries
            .fold(0, (acc, model.CdrAgentSummary a) => acc + a.shortCalls);

        totalAnswered += answered;
        totalInbound += (answered +
            c.summary.notifiedNotAnswered +
            c.summary.inboundNotNotified);
        totalInboundBillSec += inboundBillSeconds;
        totalInboundNotNotified += c.summary.inboundNotNotified;
        totalLongCalls += longCalls;
        totalNotifiedNotAnswered += c.summary.notifiedNotAnswered;
        totalOutboundCost += c.summary.outboundCost;
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
            new TableCellElement()..text = c.recName,
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
    }).whenComplete(() {
      fetchButton.disabled = false;
      fetchButton.style.backgroundColor = '';
    });
  }

  /**
   *
   */
  Future loadOrgsAndReceptions() async {
    List<model.Reception> receptions;

    Future loadO() async {
      return _orgCtrl.list().then((Iterable<model.Organization> orgs) {
        return Future.forEach(orgs, (model.Organization org) {
          return _orgCtrl.receptions(org.id).then((Iterable<int> rids) {
            return Future.forEach(rids, (int rid) {
              if (!ridToNameMap.containsKey(rid)) {
                ridToNameMap[rid] = {'orgName': org.fullName, 'recName': ''};
              }
            });
          });
        });
      });
    }

    Future loadR() async {
      receptions = await _recCtrl.list();
    }

    await Future.wait([loadO(), loadR()]);

    await Future.forEach(receptions, (model.Reception rec) {
      if (ridToNameMap.containsKey(rec.ID)) {
        ridToNameMap[rec.ID]['recName'] = rec.fullName;
      } else {
        ridToNameMap[rec.ID] = {'orgName': '', 'recName': rec.fullName};
      }
    });

    fetchButton.hidden = false;
  }

  /**
   * Observers.
   */
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
}
