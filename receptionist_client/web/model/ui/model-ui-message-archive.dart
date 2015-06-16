/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of model;

/**
 * TODO (TL): Comment
 */
class UIMessageArchive extends UIModel {
  final DivElement      _myRoot;
  final ORUtil.WeekDays _weekDays;

  /**
   * Constructor.
   */
  UIMessageArchive(DivElement this._myRoot,
                   ORUtil.WeekDays this._weekDays) {
    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _body;
  @override HtmlElement get _focusElement    => _body;
  @override HtmlElement get _lastTabElement  => _body;
  @override HtmlElement get _root            => _myRoot;

  DivElement get _body                => _root.querySelector('.generic-widget-body');
  TableElement get _savedTable        => _root.querySelector('table.saved-messages-table');
  TableSectionElement get _savedTbody => _root.querySelector('table tbody.saved-messages-tbody');

  /**
   *
   */
  TableCellElement _buildAgentCell(ORModel.Message msg) =>
      new TableCellElement();

  /**
   *
   */
  TableCellElement _buildButtonCell(ORModel.Message msg) {
    final ButtonElement buttonSend = new ButtonElement()..text = 'Send';
    final ButtonElement buttonDelete = new ButtonElement()..text = 'Slet';
    final ButtonElement buttonCopy = new ButtonElement()..text = 'Kopier';

    return new TableCellElement()
                ..classes.addAll(['td-center',  'button-cell'])
                ..children.addAll([buttonSend, buttonDelete, buttonCopy]);
    }

  /**
   *
   */
  TableCellElement _buildMessageCell(ORModel.Message msg) {
    final DivElement div = new DivElement()
                                ..classes.add('slim')
                                ..appendHtml(msg.body.replaceAll("\n", '<br>'));
    div.onClick.listen((_) => div.classes.toggle('slim'));

    return new TableCellElement()
                ..classes.add('message-cell')
                ..children.add(div);
  }

  /**
   *
   */
  TableRowElement _buildRow(ORModel.Message msg) {
    final TableRowElement row = new TableRowElement();

    final TableCellElement dateCell = new TableCellElement()
                                            ..text = ORUtil.humanReadableTimestamp(msg.createdAt, _weekDays);
    final TableCellElement receptionCell = new TableCellElement();
    final TableCellElement contactCell = new TableCellElement();
    final TableCellElement agentCell = new TableCellElement();

    row.children.addAll([dateCell,
                         receptionCell,
                         contactCell,
                         agentCell,
                         _buildMessageCell(msg),
                         _buildStatusCell(msg),
                         _buildButtonCell(msg)]);

    return row;
  }

  /**
   *
   */
  TableCellElement _buildStatusCell(ORModel.Message msg) =>
      new TableCellElement()
            ..classes.add('td-center')
            ..text = _getStatus(msg);

  /**
   * Remove all data from the body and clear the header.
   */
  void clear() {
    _headerExtra.text = '';
    _body.text = '';
  }

  /**
   *
   */
  String _getStatus(ORModel.Message msg) {
    if(msg.sent) {
      return 'SENT';
    }

    if(msg.enqueued) {
      return 'QUEUED';
    }

    if(!msg.sent && !msg.enqueued) {
      return 'SAVED';
    }

    return 'UNKNOWN';
  }

  /**
   *
   */
  set messages(Iterable<ORModel.Message> list) {
    list.where((ORModel.Message msg) => !msg.sent && !msg.enqueued).forEach((ORModel.Message msg) {
      _savedTbody.children.add(_buildRow(msg));
    });

    print('!!!!!!!!!!!! Other Messages !!!!!!!!!!!!!!');
    list.where((ORModel.Message msg) => msg.sent || msg.enqueued).forEach((ORModel.Message msg) {
      print('${ORUtil.humanReadableTimestamp(msg.createdAt, _weekDays)} - ${msg.ID}');
    });
  }

  /**
   * Observers.
   */
  void _observers() {
    _root.onKeyDown.listen(_keyboard.press);
    _root.onClick.listen((_) => _body.focus());

//    _messageBody.onClick.listen((MouseEvent event) {
//      _messageBody.classes.toggle('slim');
//    });
  }

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    _hotKeys.registerKeysPreventDefault(_keyboard, _defaultKeyMap());
  }
}
