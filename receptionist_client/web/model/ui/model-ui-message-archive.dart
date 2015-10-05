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
 * Provides access to the MessageArchive UX components.
 */
class UIMessageArchive extends UIModel {
  final Bus<int> _scrollBus = new Bus<int>();
  final Map<String, String> _langMap;
  final Bus<ORModel.Message> _messageCloseBus = new Bus<ORModel.Message>();
  final Bus<ORModel.Message> _messageCopyBus = new Bus<ORModel.Message>();
  final Bus<ORModel.Message> _messageDeleteBus = new Bus<ORModel.Message>();
  final Bus<ORModel.Message> _messageSendBus = new Bus<ORModel.Message>();
  final DivElement _myRoot;
  Map<int, String> _users = new Map<int, String>();
  final ORUtil.WeekDays _weekDays;

  /**
   * Constructor.
   */
  UIMessageArchive(
      DivElement this._myRoot, ORUtil.WeekDays this._weekDays, this._langMap) {
    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _body;
  @override HtmlElement get _focusElement => _tableContainer;
  @override HtmlElement get _lastTabElement => _body;
  @override HtmlElement get _root => _myRoot;

  DivElement get _body => _root.querySelector('.generic-widget-body');
  String get header => _root.querySelector('h4 span.extra-header').text;
  TableSectionElement get _savedTbody =>
      _root.querySelector('table tbody.saved-messages-tbody');
  TableSectionElement get _notSavedTbody =>
      _root.querySelector('table tbody.not-saved-messages-tbody');
  DivElement get _tableContainer => _body.querySelector('div');

  /**
   * Construct the button (send, delete, copy) <td> cell.
   */
  TableCellElement _buildButtonCell(ORModel.Message msg) {
    final List<ButtonElement> buttons = new List<ButtonElement>();

    buttons.add(new ButtonElement()
      ..text = _langMap['copy']
      ..onClick.listen((_) => _messageCopyBus.fire(msg)));

    if (!msg.closed) {
      buttons.addAll([
        new ButtonElement()
          ..text = _langMap['send']
          ..onClick.listen((_) => _messageSendBus.fire(msg)),
        new ButtonElement()
          ..text = _langMap['delete']
          ..onClick.listen((_) => _messageDeleteBus.fire(msg)),
        new ButtonElement()
          ..text = _langMap['close']
          ..onClick.listen((_) => _messageCloseBus.fire(msg))
      ]);
    }

    return new TableCellElement()
      ..classes.addAll(['td-center', 'button-cell'])
      ..children.addAll(buttons);
  }

  /**
   * Construct the message <td> cell.
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
   * Construct a <tr> element from [msg]
   */
  TableRowElement _buildRow(ORModel.Message msg) {
    final TableRowElement row = new TableRowElement()
      ..dataset['message-id'] = msg.ID.toString()
      ..dataset['contact-string'] = msg.context.contactString;

    row.children.addAll([
      new TableCellElement()
        ..text = ORUtil.humanReadableTimestamp(msg.createdAt, _weekDays),
      new TableCellElement()
        ..text = _users[msg.senderId] ?? msg.senderId.toString(),
      new TableCellElement()..text = msg.callerInfo.name,
      new TableCellElement()..text = msg.callerInfo.company,
      new TableCellElement()..text = msg.callerInfo.phone,
      new TableCellElement()..text = msg.callerInfo.cellPhone,
      new TableCellElement()..text = msg.callerInfo.localExtension,
      _buildMessageCell(msg),
      new TableCellElement()
        ..classes.add('td-center')
        ..text = _getStatus(msg),
      _buildButtonCell(msg)
    ]);

    return row;
  }

  /**
   * Remove all data from the body and clear the header.
   */
  void clear() {
    _headerExtra.text = '';
    _body.text = '';
  }

  /**
   * Clear the message lists.
   */
  void clearNotSavedList() {
    _notSavedTbody.children.clear();
    _notSavedTbody.parent.hidden = true;
  }

  /**
   * Return the String status of [msg].
   */
  String _getStatus(ORModel.Message msg) {
    if (msg.sent) {
      return 'SENT';
    }

    if (msg.enqueued) {
      return 'QUEUED';
    }

    if (!msg.sent && !msg.enqueued) {
      return 'SAVED';
    }

    return 'UNKNOWN';
  }

  /**
   * Add the [list] of [ORModel.Message] to the widgets "not saved messages"
   * table.
   */
  set notSavedMessages(Iterable<ORModel.Message> list) {
    final List<TableRowElement> rows = new List<TableRowElement>();
    list.forEach((ORModel.Message msg) {
      rows.add(_buildRow(msg));
    });

    _notSavedTbody.children.addAll(rows);
    _notSavedTbody.parent.hidden = _notSavedTbody.children.isEmpty;
  }

  /**
   * Observers.
   */
  void _observers() {
    _root.onKeyDown.listen(_keyboard.press);
    _root.onClick.listen((_) => _tableContainer.focus());

    _tableContainer.onScroll.listen((Event event) {
      if (_tableContainer.getBoundingClientRect().height +
              _tableContainer.scrollTop >=
          _tableContainer.scrollHeight) {
        if (_notSavedTbody.children.isNotEmpty) {
          _scrollBus.fire(
              int.parse(_notSavedTbody.children.last.dataset['message-id']));
        }
      }
    });
  }

  /**
   * Fire a [ORModel.Message] when closing it.
   */
  Stream<ORModel.Message> get onMessageClose => _messageCloseBus.stream;

  /**
   * Fire a [ORModel.Message] when copying it.
   */
  Stream<ORModel.Message> get onMessageCopy => _messageCopyBus.stream;

  /**
   * Fire a [ORModel.Message] when deleting it.
   */
  Stream<ORModel.Message> get onMessageDelete => _messageDeleteBus.stream;

  /**
   * Fire a [ORModel.Message] when sending it.
   */
  Stream<ORModel.Message> get onMessageSend => _messageSendBus.stream;

  /**
   * Add the [list] of [ORModel.Message] to the widgets "saved messages" table.
   */
  set savedMessages(Iterable<ORModel.Message> list) {
    final List<TableRowElement> rows = new List<TableRowElement>();
    _savedTbody.children.clear();

    list.forEach((ORModel.Message msg) {
      rows.add(_buildRow(msg));
    });

    _savedTbody.children.addAll(rows);
    _savedTbody.parent.hidden = _savedTbody.children.isEmpty;
  }

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    _hotKeys.registerKeysPreventDefault(_keyboard, _defaultKeyMap());
  }

  /**
   * Fires the ID of the last ORModel.Message when the message list box is
   * scrolled to the bottom.
   */
  Stream<int> get scrolledToBottom => _scrollBus.stream;

  /**
   * Set the list of users. This is used to map the users id of a message to
   * the users name.
   */
  set users(Iterable<ORModel.User> list) {
    list.forEach((ORModel.User user) {
      _users[user.ID] = user.name;
    });
  }
}
