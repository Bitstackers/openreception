part of management_tool.view;

class Calendar {
  final Logger _log = new Logger('$_libraryName.Calendar');

  final bool _containsDeleted;
  final controller.Calendar _calendarController;
  final DivElement element = new DivElement()..classes.add('full-width');

  Function onDelete;

  final TableElement _table = new TableElement()..style.width = '100%';

  Calendar(controller.Calendar this._calendarController, this._containsDeleted);

  void set entries(Iterable<model.CalendarEntry> es) {
    _table.children.clear();

    if (es.isEmpty) {
      element.children = [
        new SpanElement()
          ..text = 'Ingen kalenderposter'
          ..classes.add('centered-info')
      ];
      return;
    }

    _table.createTHead()
      ..children = [
        new TableRowElement()
          ..classes.add('zebra-even')
          ..children = [
            new TableCellElement()
              ..text = 'Start'
              ..style.width = '15%',
            new TableCellElement()
              ..text = 'Stop'
              ..style.width = '15%',
            new TableCellElement()
              ..text = 'Aftale'
              ..style.width = '33%',
            new TableCellElement()
              ..text = 'Ændringer'
              ..style.width = '30%',
            new TableCellElement()
              ..text = ''
              ..style.width = '8%',
          ]
      ];
    _table.createTBody()
      ..classes.add('zebra-even')
      ..children = ([]..addAll(es.map(_entryToRow)));
    element.children = [_table];
  }

  TableRowElement _entryToRow(model.CalendarEntry entry) {
    final changeCell = new TableCellElement();
    final ButtonElement deleteButton = new ButtonElement()
      ..text = _containsDeleted ? 'Ryd' : 'Slet'
      ..classes.add('delete');
    final deleteCell = new TableCellElement()..children = [deleteButton];

    deleteButton.onClick.listen((_) async {
      final confirmText = 'Bekræft ${_containsDeleted ? 'fuldstændig' :''}'
          ' sletning af eid${entry.id}?';

      if (deleteButton.text == confirmText) {
        await _calendarController.remove(entry);
        notify.success('Slettede kalenderpost', 'eid:${entry.id}');

        onDelete != null ? onDelete() : '';
      } else {
        deleteButton.text = confirmText;
      }
    });

    _calendarController
        .changes(entry.id)
        .then((Iterable<model.CalendarEntryChange> changes) {
      UListElement changeUl = new UListElement();
      List changeList = changes.toList();
      LIElement creation;

      try {
        creation = _changeToLI(changeList.removeLast(), 'Oprettet');
      } catch (e) {
        creation = new LIElement()
          ..classes.add('error')
          ..text = 'Oprettelse ikke fundet';
      }

      if (_containsDeleted) {
        LIElement deletion;

        try {
          deletion = _changeToLI(changeList.removeAt(0), 'Slettet');
        } catch (e) {
          creation = new LIElement()
            ..classes.add('error')
            ..text = 'Sletning ikke fundet';
        }

        changeUl.children.add(deletion);
      }

      changeUl.children
        ..addAll(changeList.map((change) => _changeToLI(change, 'Ændret')));
      changeUl.children.add(creation);

      changeCell.children = [changeUl];
    });

    return new TableRowElement()
      ..children = [
        new TableCellElement()..text = rfc3339.format(entry.start),
        new TableCellElement()..text = rfc3339.format(entry.stop),
        new TableCellElement()..text = entry.content,
        changeCell,
        deleteCell
      ];
  }

  LIElement _changeToLI(model.CalendarEntryChange change, String prefix) {
    LIElement li = new LIElement()
      ..children = [
        new SpanElement()
          ..text = '$prefix '
          ..style.fontWeight = 'bold',
        new SpanElement()
          ..text = rfc3339.format(change.changedAt) + ' - ${change.author}'
      ];

    return li;
  }
}
