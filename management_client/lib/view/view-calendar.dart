part of orm.view;

class Calendar {
  final Logger _log = new Logger('$_libraryName.Calendar');

  final controller.Calendar _calendarController;
  final DivElement element = new DivElement()..classes.add('full-width');
  Changelog _changelog;

  Function onDelete;

  final TableElement _table = new TableElement()..style.width = '100%';

  Calendar(controller.Calendar this._calendarController) {
    _changelog = new Changelog();
  }

  /**
   *
   */
  Future loadEntries(model.Owner owner) async {
    final es = await _calendarController.list(owner);
    _changelog.content = await _calendarController.changelog(owner);

    _table.children.clear();

    if (es.isEmpty) {
      element.children = [
        new SpanElement()
          ..text = 'Ingen kalenderposter'
          ..classes.add('centered-info'),
        _changelog.element
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
              ..text = 'Sidst ændret af'
              ..style.width = '30%',
            new TableCellElement()
              ..text = ''
              ..style.width = '8%',
          ]
      ];
    _table.createTBody()
      ..classes.add('zebra-even')
      ..children = ([]..addAll(es.map((e) => _entryToRow(e, owner))));
    element.children = [_table, _changelog.element];
  }

  /**
   *
   */
  TableRowElement _entryToRow(model.CalendarEntry entry, model.Owner owner) {
    final changeCell = new TableCellElement();
    final ButtonElement deleteButton = new ButtonElement()
      ..text = 'Slet'
      ..classes.add('delete');
    final deleteCell = new TableCellElement()..children = [deleteButton];

    deleteButton.onClick.listen((_) async {
      final confirmText = 'Bekræft sletning af eid${entry.id}?';

      if (deleteButton.text == confirmText) {
        await _calendarController.remove(entry, owner);
        notify.success('Slettede kalenderpost', 'eid:${entry.id}');

        onDelete != null ? onDelete() : '';
      } else {
        deleteButton.text = confirmText;
      }
    });

    changeCell.text = entry.lastAuthorId.toString();

    return new TableRowElement()
      ..children = [
        new TableCellElement()..text = rfc3339.format(entry.start),
        new TableCellElement()..text = rfc3339.format(entry.stop),
        new TableCellElement()..text = entry.content,
        changeCell,
        deleteCell
      ];
  }
}
