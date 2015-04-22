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
 * LogBox widget.
 */
class LogBox {
  DivElement      element;
  TableElement    table;

  LogBox(DivElement this.element, Model.CallList observedCallList) {
    // TODO (TL): Move as much as this to bob.html as possible
    table = new TableElement()
      ..id = Id.logBoxTable
      ..children.add(new TableRowElement()
        ..innerHtml = '''
          <th class="log-box-time-header">Tidspunkt</th>
          <th class="log-box-level-header">Niveau</th>
          <th class="log-box-message-header">Besked</th>
        ''');

    registerEventListeners(observedCallList);
  }

  void registerEventListeners(Model.CallList observedCallList) {

    observedCallList.onInsert.listen(this._pushCallRecord);
  }

  void _pushCallRecord(Model.Call newCall) {
    TableRowElement tr = new TableRowElement();
    tr.children
      ..add(new TableCellElement()
              ..text = dateFormat.format(newCall.arrived)
              ..style.textAlign = 'center')
      ..add(new TableCellElement()
              ..text = newCall.callerID
              ..style.textAlign = 'center')
      ..add(new TableCellElement()..text = newCall.receptionID.toString());
    table.children.insert(1, tr);
  }


  void push(LogRecord record) {
    TableRowElement tr = new TableRowElement();
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
}
