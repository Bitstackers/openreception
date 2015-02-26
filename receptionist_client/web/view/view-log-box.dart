/*                  This file is part of OpenReception
                   Copyright (C) 2012-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/
part of view;

/**
 * LogBox widget. Subscribes into the [userLogStream] of the [logger] and
 * appends each log entry to the body of the widget.
 */
class LogBox {
  Box             box;
  DivElement      element;
  List<LogRecord> messages = new List<LogRecord>();
  TableElement    table;

  LogBox(DivElement this.element) {

    table = new TableElement()
      ..id = Id.logBoxTable
      ..children.add(new TableRowElement()
        ..innerHtml = '''
          <th class="logbox-time-header">Tidspunkt</th>
          <th class="logbox-level-header">Niveau</th>
          <th class="logbox-message-header">Besked</th>
        ''');

    box = new Box.noChrome(element, table);
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
    TableRowElement tr = new TableRowElement();
    tr.classes.add('logbox-row');
    tr.children
      ..add(new TableCellElement()
              ..text = dateFormat.format(record.time)
              ..style.textAlign = 'center')
      ..add(new TableCellElement()
              ..text = record.level.name
              ..style.textAlign = 'center')
      ..add(new TableCellElement()..text = record.message);
    table.children.insert(1, tr);
  }

  LogRecord pop() {
    table.children.removeLast();
    return messages.removeLast();
  }

}
