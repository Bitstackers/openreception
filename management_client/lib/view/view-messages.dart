part of management_tool.view;

class Messages {
  final Logger _log = new Logger('$_libraryName.Messages');

  final controller.Message _msgController;
  final DivElement element = new DivElement()..classes.add('full-width');

  Function onDelete;

  final TableElement _table = new TableElement()..style.width = '100%';

  void set loading(bool isLoading) {
    if (isLoading) {
      _table.children.clear();

      element.children = [
        new SpanElement()
          ..text = 'Henter beskeder...'
          ..classes.add('centered-info')
      ];
      _observers();
    }
  }

  Messages(controller.Message this._msgController) {
    _table.children.clear();

    element.children = [
      new SpanElement()
        ..text = 'Ingen beskeder fundet'
        ..classes.add('centered-info')
    ];
    _observers();
  }

  /**
   *
   */
  void set messages(Iterable<model.Message> msgs) {
    _table.children.clear();

    if (msgs.isEmpty) {
      element.children = [
        new SpanElement()
          ..text = 'Ingen beskeder fundet'
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
              ..text = 'Modtaget'
              ..style.width = '10%',
            new TableCellElement()
              ..text = 'Kontekst'
              ..style.width = '15%',
            new TableCellElement()
              ..text = 'Besked'
              ..style.width = '40%',
            new TableCellElement()
              ..text = 'Opkalderinfo'
              ..style.width = '25%',
            new TableCellElement()
              ..text = 'Status'
              ..style.width = '5%',
            new TableCellElement()
              ..text = ''
              ..style.width = '5%',
          ]
      ];
    _table.createTBody()
      ..classes.add('zebra-even')
      ..children = ([]..addAll(msgs.map(_entryToRow)));
    element.children = [_table];
  }

  /**
   *
   */
  void _observers() {}

  TableRowElement _entryToRow(model.Message msg) {
    //final changeCell = new TableCellElement();
    final ButtonElement deleteButton = new ButtonElement()
      ..text = 'Slet'
      ..classes.add('delete');
    final deleteCell = new TableCellElement()..children = [deleteButton];

    deleteButton.onClick.listen((_) async {
      final confirmText = 'Bekræft sletning af mid${msg.id}?';

      if (deleteButton.text == confirmText) {
        await _msgController.remove(msg.id);
        notify.success('Slettede besked', 'mid:${msg.id}');

        onDelete != null ? onDelete() : '';
      } else {
        deleteButton.text = confirmText;
      }
    });

    List<String> status = [];

    if (msg.closed) {
      status.add('Lukket');
    }
    if (msg.enqueued) {
      status.add('I kø');
    }
    if (msg.manuallyClosed) {
      status.add('Manuelt lukket');
    }
    if (msg.sent) {
      status.add('Afsendt');
    }

    if (msg.state == model.MessageState.saved) {
      status.add('Gemt');
    }

    if (msg.state == model.MessageState.unknown) {
      status.add('Ukendt');
    }

    SpanElement contextInfo(model.MessageContext mc) => new SpanElement()
      ..text = mc.contactName +
          '${mc.receptionName.isNotEmpty ? '@${mc.receptionName}': ''}';

    SpanElement callerInfo(model.CallerInfo ci) => new SpanElement()
      ..text = ci.name + '${ci.company.isNotEmpty ? '@${ci.company}': ''}';

    return new TableRowElement()
      ..children = [
        new TableCellElement()..text = rfc3339.format(msg.createdAt),
        new TableCellElement()..children = [contextInfo(msg.context)],
        new TableCellElement()..text = msg.body,
        new TableCellElement()..children = [callerInfo(msg.callerInfo)],
        new TableCellElement()..text = status.join(', '),
        deleteCell
      ];
  }

  LIElement _changeToLI(model.Commit change, String prefix) {
    LIElement li = new LIElement()
      ..children = [
        new SpanElement()
          ..text = '$prefix '
          ..style.fontWeight = 'bold',
        new SpanElement()
          ..text =
              rfc3339.format(change.changedAt) + ' - ${change.authorIdentity}'
      ];

    return li;
  }
}
