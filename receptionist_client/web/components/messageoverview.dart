part of components;

class MessageOverview {
  Box box;
  Context context;
  DivElement element;
  TableElement table;
  TableSectionElement tableBody;

  MessageOverview(DivElement this.element, Context this.context) {
    String html = '''
      <table>
        <thead>
          <tr>
            <th> <input type="checkbox" tabindex="-1"> </th>
            <th> Tidspunkt </th>
            <th> Agent </th>
            <th> Opkalder </th>
            <th> Status </th>
            <th> Metode </th>
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
    return new TableRowElement()
      ..children.addAll(
        [new TableCellElement()..children.add(new CheckboxInputElement())..style.textAlign = 'center'..onClick.listen((_) => messageCheckboxClick(message)),
         new TableCellElement()..text = message['time'].toString()..style.textAlign = 'center',
         new TableCellElement()..text = message['agent'],
         new TableCellElement()..text = message['caller'],
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
