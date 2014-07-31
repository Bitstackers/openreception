library billing.view;

import 'dart:html';

import 'package:intl/intl.dart';

import '../lib/eventbus.dart';
import '../lib/model.dart';
import '../notification.dart' as notify;
import '../lib/request.dart' as request;

DateFormat inputDateFormat = new DateFormat('yyyy-MM-dd');

class BillingView {
  String viewName = 'billing';
  DivElement element;
  TableSectionElement dataTable;
  DateInputElement fromInput, toInput;

  BillingView(DivElement this.element) {
    dataTable = element.querySelector('#billing-data-body');
    fromInput = element.querySelector('#billing-from-input');
    toInput = element.querySelector('#billing-to-input');

    DateTime now = new DateTime.now();
    fromInput.value = inputDateFormat.format(now.subtract(new Duration(days: 30)));
    toInput.value = inputDateFormat.format(now);

    refreshList();
    registrateEventHandlers();
  }

  void registrateEventHandlers() {
    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
    });

    fromInput.onChange.listen((_) {
      refreshList();
    });

    fromInput.onChange.listen((_) {
      refreshList();
    });
  }

  void refreshList() {
    DateTime from = fromInput.valueAsDate != null ? fromInput.valueAsDate : new DateTime.utc(2014,1,1);
    DateTime to = toInput.valueAsDate != null ? toInput.valueAsDate : new DateTime.now();
    if(from.isAfter(to)) {
      notify.info('Fra tidspunktet skal være før Til tidspunktet');
    } else {
      renderList(from, to);
    }
  }

  void renderList(DateTime from, DateTime to) {
    request.getCdrEntries(from, to).then((List<Cdr_Entry> entries) {
          dataTable.children
            ..clear()
            ..addAll(entries.map((Cdr_Entry entry) {
                return new TableRowElement()
                  ..children.addAll(
                      [new TableCellElement()..text = '${entry.orgId}',
                       new TableCellElement()..text = '${entry.flag}',
                       new TableCellElement()..text = '${entry.billType}',
                       new TableCellElement()..text = '${entry.orgName}',
                       new TableCellElement()..text = '${entry.callCount}',
                       new TableCellElement()..text = '${entry.duration}',
                       new TableCellElement()..text = '${entry.totalWait}',
                       new TableCellElement()..text = '${entry.smsCount}',
                       new TableCellElement()..text = '${entry.avgDuration}']);
              }));
        });
  }
}
