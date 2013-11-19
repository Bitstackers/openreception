/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/
part of components;

class LogBox {
  List<LogRecord> messages = new List<LogRecord>();
  TableElement table;
  DivElement element;

  LogBox(DivElement this.element) {

    table = new TableElement()
      ..children.add(new TableRowElement()
        ..innerHtml = '''
          <th>Tidspunkt</th>
          <th>Niveau</th>
          <th>Besked</th>
        ''');
    element.children.add(table);
    registerEventListeners();
  }

  void registerEventListeners() {
    log.userLogStream.listen((LogRecord record) {
      push(record);
      // TODO: change messages to a Queue or ListQueue

      while (messages.length > configuration.userLogSizeLimit) {
        pop();
      }
    });
  }

  void push(LogRecord record) {
    messages.insert(0, record);
    //TODO Tried with HereDoc but it didn't work
    TableRowElement tr = new TableRowElement();
    tr.children
      ..add(new TableCellElement()..text = record.time.toString())
      ..add(new TableCellElement()..text = record.level.name)
      ..add(new TableCellElement()..text = record.message);
    table.children.insert(1, tr);
  }

  void pop() {
    messages.removeLast();
    table.children.removeLast();
  }

}
