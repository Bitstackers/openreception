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
  final DivElement _myRoot;
  Map<int, String> _users = new Map<int, String>();
  final ORUtil.WeekDays _weekDays;

  /**
   * Constructor.
   */
  UIMessageArchive(DivElement this._myRoot, ORUtil.WeekDays this._weekDays) {
    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _body;
  @override HtmlElement get _focusElement => _body;
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
   *
   */
  TableCellElement _buildButtonCell(ORModel.Message msg) {
    final ButtonElement buttonSend = new ButtonElement()..text = 'Send';
    final ButtonElement buttonDelete = new ButtonElement()..text = 'Slet';
    final ButtonElement buttonCopy = new ButtonElement()..text = 'Kopier';

    return new TableCellElement()
      ..classes.addAll(['td-center', 'button-cell'])
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
  }

  /**
   *
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
   * Return the [ORModel.MessageContext.contactString] if there are messages in
   * the not saved list.
   * Return empty String if there are no messages in the not saved list.
   */
  String get notSavedLastContactString {
    if (_notSavedTbody.children.isNotEmpty) {
      return _notSavedTbody.children.last.dataset['contact-string'];
    } else {
      return '';
    }
  }

  /**
   *
   */
  set notSavedMessages(Iterable<ORModel.Message> list) {
    list.forEach((ORModel.Message msg) {
      _notSavedTbody.children.add(_buildRow(msg));
    });
  }

  /**
   * Observers.
   */
  void _observers() {
    _root.onKeyDown.listen(_keyboard.press);
    _root.onClick.listen((_) => _body.focus());

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
   *
   */
  set savedMessages(Iterable<ORModel.Message> list) {
    _savedTbody.children.clear();

    list.forEach((ORModel.Message msg) {
      _savedTbody.children.add(_buildRow(msg));
    });
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
   *
   */
  set users(Iterable<ORModel.User> list) {
    list.forEach((ORModel.User user) {
      _users[user.ID] = user.name;
    });
  }
}
