part of components;

class MessageOverview {
  Box box;
  Context context;
  DivElement element;
  TableElement table;
  TableSectionElement tableBody;

  MessageOverview(DivElement this.element, Context this.context) {
    String html = '''
      <table cellpadding="0" cellspacing="0">
        <thead>
          <tr>
            <th id="message-overview-header-checkbox"> <input type="checkbox" tabindex="-1"> </th>
            <th id="message-overview-header-Timestamp"> Tidspunkt </th>
            <th id="message-overview-header-agent"> Agent </th>
            <th id="message-overview-header-caller"> Opkalder </th>
            <th id="message-overview-header-status"> Status </th>
            <th id="message-overview-header-methode"> Metode </th>
          </tr>
        </thead>
        <tbody>
        </tbody>
      </table>
    ''';

    table = new DocumentFragment.html(html).querySelector('table');
    tableBody = table.querySelector('tbody');
    table.querySelector('input').onClick.listen(headerCheckboxChange);
    box = new Box.noChrome(element, table);
    initialFill();
  }

  void initialFill() {
    protocol.getMessages().then((protocol.Response<Map> response) {
      if(response.data.containsKey('messages')) {
        List<Map> messages = response.data['messages'];
        for(Map message in messages) {
          tableBody.children.add(makeRow(message));
        }
      }
    });
  }

  TableRowElement makeRow(Map message) {
    String time = dateFormat.format(new DateTime.fromMillisecondsSinceEpoch(message['time'] * 1000));
    return new TableRowElement()
      ..children.addAll(
        [new TableCellElement()..children.add(new CheckboxInputElement()..tabIndex = -1)..style.textAlign = 'center'..onClick.listen((_) => messageCheckboxClick(message)),
         new TableCellElement()..text = time
                               ..style.textAlign = 'center',
         new TableCellElement()..text = message['agent']
                               ..style.paddingLeft = '3px',
         new TableCellElement()..text = message['caller']
                               ..style.paddingLeft = '3px',
         new TableCellElement()..text = message['status'],
         new TableCellElement()..text = message['methode']..style.textAlign = 'center']);
  }

  void headerCheckboxChange(Event event) {
    CheckboxInputElement target = event.target;
    bool checked = target.checked;

    for(TableRowElement item in table.children.skip(1).first.children) {
      InputElement e = item.children.first.children.first;
      e.checked = checked;
    }
  }

  void messageCheckboxClick(Map message) {

  }
}
