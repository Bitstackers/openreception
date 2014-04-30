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
            <th id="message-overview-header-timestamp"> Tidspunkt </th>
            <th id="message-overview-header-caller"> Opkalder </th>
            <th id="message-overview-header-context"> Kontekst </th>
            <th id="message-overview-header-agent"> Agent </th>
            <th id="message-overview-header-status"> Status </th>
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
    String time   = dateFormat.format(new DateTime.fromMillisecondsSinceEpoch(message['created_at']));
    String status = "Pending";
    if (message['pending_messages'] == 0) {
      status = "Sent";
    }
    
    return new TableRowElement()
      ..children.addAll(
        [new TableCellElement()..children.add(new CheckboxInputElement()..tabIndex = -1)..style.textAlign = 'center'..onClick.listen((_) => messageCheckboxClick(message)),
         new TableCellElement()..text = time
                               ..style.textAlign = 'center',
         new TableCellElement()..text = '${message['caller']['name']} (${message['caller']['company']})'
                               ..style.paddingLeft = '3px'
                               ..style.textAlign = 'left',
         new TableCellElement()..text = message['context']['contact']['name']
                               ..style.paddingLeft = '3px'
                               ..style.textAlign = 'center',
         new TableCellElement()..text = message['taken_by_agent']['name']
                                   ..style.paddingLeft = '3px'
                                   ..style.textAlign = 'center',
         new TableCellElement()..text = (message['pending_messages'] > 0 ? 'Venter' : 'Afsendt')
                               ..style.textAlign = 'center'
        ]);
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
