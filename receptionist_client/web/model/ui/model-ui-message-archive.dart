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
  ORModel.MessageContext _currentContext;
  final Map<String, String> _langMap;
  final Bus<ORModel.Message> _messageCloseBus = new Bus<ORModel.Message>();
  final Bus<ORModel.Message> _messageCopyBus = new Bus<ORModel.Message>();
  final Bus<ORModel.Message> _messageDeleteBus = new Bus<ORModel.Message>();
  final Bus<ORModel.Message> _messageSendBus = new Bus<ORModel.Message>();
  final DivElement _myRoot;
  final Bus<int> _scrollBus = new Bus<int>();
  Map<int, String> _users = new Map<int, String>();
  final ORUtil.WeekDays _weekDays;

  /**
   * Constructor.
   */
  UIMessageArchive(DivElement this._myRoot, ORUtil.WeekDays this._weekDays, this._langMap) {
    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _body;
  @override HtmlElement get _focusElement => _tableContainer;
  @override HtmlElement get _lastTabElement => _body;
  @override HtmlElement get _root => _myRoot;

  DivElement get _body => _root.querySelector('.generic-widget-body');
  String get header => _root.querySelector('h4 span.extra-header').text;
  TableSectionElement get _savedTbody => _root.querySelector('table tbody.saved-messages-tbody');
  TableSectionElement get _notSavedTbody =>
      _root.querySelector('table tbody.not-saved-messages-tbody');
  DivElement get _tableContainer => _body.querySelector('div');

  /**
   * Construct the send | delete | copy | close <td> cell.
   */
  TableCellElement _buildActionsCell(ORModel.Message message) {
    final DivElement actionsContainer = new DivElement()..classes.add('actions-container');
    final DivElement buttonBox = new DivElement()..classes.add('button-box');
    final TableCellElement cell = new TableCellElement()..classes.add('actions');
    final DivElement yesNoBox = new DivElement()..classes.add('yes-no-box');

    buttonBox.children.addAll([
      new ImageElement()
        ..src = 'images/copy.svg'
        ..title = _langMap['copy'].toLowerCase()
        ..onClick.listen((_) => _yesNo(buttonBox, yesNoBox, message, _messageCopyBus)),
      new ImageElement()
        ..src = 'images/send.svg'
        ..title = _langMap['send'].toLowerCase()
        ..style.visibility = message.closed ? 'hidden' : 'visible'
        ..onClick.listen((_) => _yesNo(buttonBox, yesNoBox, message, _messageSendBus)),
      new ImageElement()
        ..src = 'images/bin.svg'
        ..title = _langMap['delete'].toLowerCase()
        ..style.visibility = message.closed ? 'hidden' : 'visible'
        ..onClick.listen((_) => _yesNo(buttonBox, yesNoBox, message, _messageDeleteBus)),
      new ImageElement()
        ..src = 'images/close.svg'
        ..title = _langMap['close'].toLowerCase()
        ..style.visibility = message.closed ? 'hidden' : 'visible'
        ..onClick.listen((_) => _yesNo(buttonBox, yesNoBox, message, _messageCloseBus))
    ]);

    actionsContainer.children.addAll([buttonBox, yesNoBox]);

    cell.children.add(actionsContainer);
    return cell;
  }

  /**
   * Construct the message <td> cell.
   */
  TableCellElement _buildMessageCell(ORModel.Message msg) {
    final DivElement div = new DivElement()
      ..classes.add('slim')
      ..appendHtml(msg.body.replaceAll("\n", '<br>'));
    div.onClick.listen((MouseEvent _) => div.classes.toggle('slim'));

    return new TableCellElement()..classes.add('message-cell')..children.add(div);
  }

  /**
   * Construct a <tr> element from [message]
   */
  TableRowElement _buildRow(ORModel.Message message, bool saved) {
    final TableRowElement row = new TableRowElement()
      ..dataset['message-id'] = message.ID.toString()
      ..dataset['contact-string'] = message.context.contactString;

    row.children.add(
        new TableCellElement()..text = ORUtil.humanReadableTimestamp(message.createdAt, _weekDays));

    if (saved) {
      row.children.addAll([
        new TableCellElement()..text = message.context.contactName,
        new TableCellElement()..text = message.context.receptionName,
      ]);
    }

    row.children.addAll([
      new TableCellElement()..text = _users[message.senderId] ?? message.senderId.toString(),
      new TableCellElement()..text = message.callerInfo.name,
      new TableCellElement()..text = message.callerInfo.company,
      new TableCellElement()..text = message.callerInfo.phone,
      new TableCellElement()..text = message.callerInfo.cellPhone,
      new TableCellElement()..text = message.callerInfo.localExtension,
      _buildMessageCell(message),
      _buildStatusCell(message, saved),
      _buildActionsCell(message)
    ]);

    return row;
  }

  /**
   * Build the status column for those
   */
  TableCellElement _buildStatusCell(ORModel.Message message, bool saved) {
    final TableCellElement td = new TableCellElement()
      ..classes.add('td-center')
      ..text = _getStatus(message);

    if (saved) {
      td.classes.add('saved-alert');
    }

    return td;
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
   * Get rid of all the Yes/No confirmation boxes.
   */
  void hideYesNoBoxes() {
    _body.querySelectorAll('.yes-no-box').forEach((Element yesNoBox) {
      yesNoBox.style.display = 'none';
      yesNoBox.children.clear();
      yesNoBox.previousElementSibling.style.display = 'flex';
    });
  }

  /**
   * Set the current message context. This MUST be defined by the currently selected reception and
   * contact. It is used to decide whether delete/close actions move the message in question from
   * the saved list to the not saved list.
   */
  set context(ORModel.MessageContext context) {
    _currentContext = context;
  }

  /**
   * Return the String status of [msg].
   */
  String _getStatus(ORModel.Message msg) {
    if (msg.flag.manuallyClosed) {
      return _langMap[Key.closed].toUpperCase();
    }

    if (msg.sent) {
      return _langMap[Key.sent].toUpperCase();
    }

    if (msg.enqueued) {
      return _langMap[Key.queued].toUpperCase();
    }

    if (!msg.sent && !msg.enqueued) {
      return _langMap[Key.saved].toUpperCase();
    }

    return _langMap[Key.unknown].toUpperCase();
  }

  /**
   * Move the [message] from the saved list to the not saved list and update the actions cell
   * according to the state of the [message]. [message] is ALWAYS moved to the top of the not saved
   * list to make it clear that the move has happened.
   *
   * NOTE: This is a visual only action. It does not perform any actions on the server.
   */
  void moveMessage(ORModel.Message message) {
    final TableRowElement tr = _savedTbody.querySelector('[data-message-id="${message.ID}"]');

    if (tr != null) {
      tr.classes.add('fade-out');
      tr.onTransitionEnd.listen((TransitionEvent event) {
        if (event.propertyName == 'opacity') {
          tr.remove();
          _savedTbody.parent.hidden = _savedTbody.children.isEmpty;
          if (_currentContext == message.context) {
            _notSavedTbody.insertBefore(_buildRow(message, false), _notSavedTbody.firstChild);
          }
        }
      });
    }
  }

  /**
   * Add the [list] of [ORModel.Message] to the widgets "not saved messages"
   * table.
   */
  set notSavedMessages(Iterable<ORModel.Message> list) {
    final List<TableRowElement> rows = new List<TableRowElement>();
    list.forEach((ORModel.Message msg) {
      rows.add(_buildRow(msg, false));
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
      if (_tableContainer.getBoundingClientRect().height + _tableContainer.scrollTop >=
          _tableContainer.scrollHeight) {
        if (_notSavedTbody.children.isNotEmpty) {
          _scrollBus.fire(int.parse(_notSavedTbody.children.last.dataset['message-id']));
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
   * Removes a saved [message] from the archive list.
   *
   * NOTE: This is a visual only action. It does not perform any actions on the server.
   */
  void removeMessage(ORModel.Message message) {
    final TableRowElement tr = _savedTbody.querySelector('[data-message-id="${message.ID}"]');

    if (tr != null) {
      tr.classes.add('fade-out');
      tr.onTransitionEnd.listen((TransitionEvent event) {
        if (event.propertyName == 'opacity') {
          tr.remove();
          _savedTbody.parent.hidden = _savedTbody.children.isEmpty;
        }
      });
    }
  }

  /**
   * Add the [list] of [ORModel.Message] to the widgets "saved messages" table.
   */
  set savedMessages(Iterable<ORModel.Message> list) {
    final List<TableRowElement> rows = new List<TableRowElement>();
    _savedTbody.children.clear();

    list.forEach((ORModel.Message msg) {
      rows.add(_buildRow(msg, true));
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
      _users[user.id] = user.name;
    });
  }

  /**
   * Setup the yes|no action confirmation box.
   */
  void _yesNo(DivElement actionBox, DivElement yesNoBox, ORModel.Message message, Bus bus) {
    yesNoBox.children.addAll([
      new SpanElement()
        ..text = _langMap[Key.yes]
        ..onClick.listen((_) {
          bus.fire(message);
        }),
      new SpanElement()
        ..text = _langMap[Key.no]
        ..onClick.listen((_) {
          yesNoBox.style.display = 'none';
          yesNoBox.children.clear();
          actionBox.style.display = 'flex';
        })
    ]);

    yesNoBox.style.width = '${actionBox.borderEdge.width.toString()}px';
    actionBox.style.display = 'none';
    yesNoBox.style.display = 'flex';
  }
}
