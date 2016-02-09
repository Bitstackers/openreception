library billing.view;

import 'dart:html';

import 'package:intl/intl.dart';

import 'package:management_tool/controller.dart' as Controller;
import '../lib/eventbus.dart';
import 'package:management_tool/notification.dart' as notify;
import 'package:openreception_framework/model.dart' as ORModel;

final DateFormat inputDateFormat = new DateFormat('yyyy-MM-dd');

class BillingView {
  static const String viewName = 'billing';

  final Controller.CDR _cdrController;

  Iterable<ORModel.CDRCheckpoint> checkpoints;

  DivElement element;
  TableSectionElement dataTable;
  DateInputElement fromInput, toInput;
  SelectElement checkpointSelector;
  ButtonElement saveCheckpointButton;
  TextInputElement checkpointName;

  BillingView(DivElement this.element, Controller.CDR this._cdrController) {
    dataTable = element.querySelector('#billing-data-body');
    fromInput = element.querySelector('#billing-from-input');
    toInput = element.querySelector('#billing-to-input');
    checkpointSelector = element.querySelector('#billing-checkpoint-selector');
    saveCheckpointButton = element.querySelector('#billing-checkpoint-save');
    checkpointName = element.querySelector('#billing-checkpoint-name');

    DateTime tmp = new DateTime.now();
    DateTime now = new DateTime(tmp.year, tmp.month, tmp.day, 0, 0, 0);
    fromInput.value = inputDateFormat.format(now.subtract(new Duration(days: 30)));
    toInput.value   = inputDateFormat.format(now);

    refreshCdrList();
    registrateEventHandlers();

    reloadCheckpoints();
  }

  void registrateEventHandlers() {
    bus.on(WindowChanged).listen((WindowChanged event) {
      element.classes.toggle('hidden', event.window != viewName);
    });

    fromInput.onChange.listen((_) {
      refreshCdrList();
    });

    toInput.onChange.listen((_) {
      refreshCdrList();
    });

    saveCheckpointButton.onClick.listen((_) {
      saveCheckpoint();
    });

    checkpointSelector.onChange.listen((_) {
      if(checkpointSelector.selectedIndex > 0) {
        loadCheckpoint(checkpoints.toList()[checkpointSelector.selectedIndex-1]);
      }
    });
  }

  void refreshCdrList() {
    //The valueAsDate returns the date and adds the timezone to it.
    DateTime from = fromInput.valueAsDate != null
        ? DateTime.parse(fromInput.value)
        : new DateTime(2014, 1, 1);
    DateTime to = toInput.valueAsDate != null
        ? DateTime.parse(toInput.value)
        : from.add(new Duration(days: 1));
    if(from.isAfter(to)) {
      notify.info('Fra tidspunktet skal være før Til tidspunktet');
    } else {
      renderList(from, to);
    }
  }

  void renderList(DateTime from, DateTime to) {
    _cdrController.listEntries (from, to).then((Iterable<ORModel.CDREntry> entries) {
          dataTable.children
            ..clear()
            ..addAll(entries.map((ORModel.CDREntry entry) {
                return new TableRowElement()
                  ..children.addAll(
                      [new TableCellElement()..text = '${entry.orgId}',
                       new TableCellElement()..text = '${entry.flag}',
                       new TableCellElement()..text = '${entry.billingType}',
                       new TableCellElement()..text = '${entry.orgName}',
                       new TableCellElement()..text = '${entry.callCount}',
                       new TableCellElement()..text = '${(entry.duration/1000).toStringAsFixed(2)}',
                       new TableCellElement()..text = '${(entry.totalWait/1000).toStringAsFixed(2)}',
                       new TableCellElement()..text = '${entry.smsCount}',
                       new TableCellElement()..text = '${(entry.avgDuration/1000).toStringAsFixed(2)}']);
              }));
        });
  }

  void reloadCheckpoints() {
    _cdrController.checkpoints().then((Iterable<ORModel.CDRCheckpoint> checkpoints) {
      this.checkpoints = checkpoints;
      //this.checkpoints.sort();

      checkpointSelector.children.clear();
      checkpointSelector.children.add(new OptionElement(data: 'Ingen valgt'));
      checkpointSelector.children.addAll(this.checkpoints.map(
              (ORModel.CDRCheckpoint point) => new OptionElement(data: '${point.name}', value: '${point.name}')));
    });
  }

  void saveCheckpoint() {
    DateTime start = DateTime.parse(fromInput.value);
    DateTime end   = DateTime.parse(toInput.value);
    String name    = checkpointName.value;

    ORModel.CDRCheckpoint newCheckpoint = new ORModel.CDRCheckpoint.empty()
      ..start = start
      ..end = end
      ..name = name;
    _cdrController.createCheckpoint(newCheckpoint).then((_) {
      reloadCheckpoints();
    });
  }

  void loadCheckpoint(ORModel.CDRCheckpoint checkpoint) {
    fromInput.value = inputDateFormat.format(checkpoint.start);
    toInput.value = inputDateFormat.format(checkpoint.end);
    refreshCdrList();
  }
}
