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

part of orc.view;

/**
 * The message archive list.
 */
class MessageArchive extends ViewWidget {
  Map<String, DateTime> _lastFetchedCache = new Map<String, DateTime>();
  final ui_model.UIContactSelector _contactSelector;
  model.MessageContext _context;
  final Map<String, String> _langMap;
  DateTime _lastFetched;
  final Logger _log = new Logger('$libraryName.MessageArchive');
  final controller.Message _messageController;
  final ui_model.UIMessageCompose _messageCompose;
  final controller.Destination _myDestination;
  final controller.Popup _popup;
  final ui_model.UIReceptionSelector _receptionSelector;
  final ui_model.UIMessageArchive _uiModel;
  final controller.User _user;

  /**
   * Constructor.
   */
  MessageArchive(
      ui_model.UIMessageArchive this._uiModel,
      controller.Destination this._myDestination,
      controller.Message this._messageController,
      controller.User this._user,
      ui_model.UIContactSelector this._contactSelector,
      ui_model.UIReceptionSelector this._receptionSelector,
      ui_model.UIMessageCompose this._messageCompose,
      controller.Popup this._popup,
      Map<String, String> this._langMap) {
    _observers();
  }

  @override
  controller.Destination get _destination => _myDestination;
  @override
  ui_model.UIMessageArchive get _ui => _uiModel;

  @override
  void _onBlur(controller.Destination _) {
    _ui.hideYesNoBoxes();
    _ui.hideTables();
  }

  @override
  void _onFocus(controller.Destination _) {
    _lastFetched = new DateTime.now();

    _context = new model.MessageContext.empty()
      ..cid = _contactSelector.selectedContact.contact.id
      ..contactName = _contactSelector.selectedContact.contact.name
      ..rid = _receptionSelector.selectedReception.id
      ..receptionName = _receptionSelector.selectedReception.name;

    _ui.currentContext = _context;

    if (_context.rid == model.Reception.noId) {
      _ui.headerExtra = '';
    } else if (_context.cid == model.BaseContact.noId) {
      _ui.headerExtra = '(${_receptionSelector.selectedReception.name})';
    } else {
      _ui.headerExtra =
          '(${_contactSelector.selectedContact.contact.name} @ ${_receptionSelector.selectedReception.name})';
    }

    _user.list().then((Iterable<model.UserReference> users) {
      _ui.users = users;

      _messageController.listDrafts().then((Iterable<model.Message> messages) {
        final List<model.Message> list = messages.toList(growable: false);
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        _ui.drafts = list;
      });

      if (_lastFetchedCache[_ui.currentContext.contactString] != null) {
        _lastFetched = _lastFetchedCache[_ui.currentContext.contactString];
      } else {
        _loadMoreMessages();
      }
    });
  }

  /**
   * Simply navigate to my [_myDestination].
   */
  void _activateMe(MouseEvent event) {
    if (!_ui.isFocused && event.target is! ButtonElement) {
      _navigateToMyDestination();
    }
  }

  /**
   * Close [message] and update the UI.
   */
  dynamic _closeMessage(model.Message message) async {
    try {
      message.recipients = new Set();
      message.state = model.MessageState.closed;

      model.Message savedMessage = await _messageController.save(message);

      _ui.moveMessage(savedMessage);

      _popup.success(
          _langMap[Key.messageCloseSuccessTitle], 'ID ${message.id}');
    } catch (error) {
      _log.shout('Could not close ${message.toJson()} $error');
      _popup.error(_langMap[Key.messageCloseErrorTitle], 'ID ${message.id}');
    }
  }

  /**
   * Delete [message] and update the UI.
   */
  dynamic _deleteMessage(model.Message message) async {
    try {
      await _messageController.remove(message.id);

      _ui.removeMessage(message);

      _log.info('Message id ${message.id} successfully deleted');
      _popup.success(
          _langMap[Key.messageDeleteSuccessTitle], 'ID ${message.id}');
    } catch (error) {
      _log.shout('Could not delete ${message.toJson()} $error');
      _popup.error(_langMap[Key.messageDeleteErrorTitle], 'ID ${message.id}');
    }
  }

  /**
   * Load more messages.
   *
   * This will never look more than 7 days back, and it will stop as soon as
   * more than 50 messages have been found.
   *
   * Ignores drafts.
   */
  Future _loadMoreMessages() async {
    if (!_ui.loading &&
        _context.cid != model.BaseContact.noId &&
        _context.rid != model.Reception.noId) {
      int counter = 0;
      final model.MessageFilter filter = new model.MessageFilter.empty()
        ..contactId = _contactSelector.selectedContact.contact.id
        ..receptionId = _receptionSelector.selectedReception.id;
      final List<model.Message> messages = new List<model.Message>();

      _ui.loading = true;

      while (counter < 7 && messages.length < 50) {
        final List<model.Message> list =
            (await _messageController.list(_lastFetched))
                .where((model.Message msg) =>
                    filter.appliesTo(msg) && !msg.isDraft ||
                    (msg.isDraft && msg.isClosed))
                .toList();

        if (list.isNotEmpty) {
          messages.addAll(list);
        } else {
          final model.Message emptyMessage = new model.Message.empty()
            ..createdAt = _lastFetched;
          list.add(emptyMessage);
          messages.add(emptyMessage);
        }

        _lastFetched = _lastFetched.subtract(new Duration(days: 1));

        _lastFetchedCache[_ui.currentContext.contactString] = _lastFetched;

        counter++;
      }

      messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _ui.setMessages(messages, addToExisting: true);

      _ui.loading = false;
    }
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _messageCompose.onDraft.listen((MouseEvent _) {
      _ui.headerExtra = '';
      _ui.cacheClear();
      _lastFetchedCache.clear();
    });
    _messageCompose.onSend.listen((MouseEvent _) {
      _ui.headerExtra = '';
      _ui.cacheClear();
      _lastFetchedCache.clear();
    });

    _receptionSelector.onSelect.listen((_) {
      _ui.cacheClear();
      _lastFetchedCache.clear();
      if (_ui.isFocused) {
        _navigate.goHome();
      }
    });

    _ui.onClick.listen(_activateMe);

    _ui.onLoadMoreMessages.listen((_) {
      _loadMoreMessages();
    });

    /// We don't need to listen on the onMessageCopy stream here. It is handled
    /// in MessageCompose.
    _ui.onMessageClose.listen(_closeMessage);
    _ui.onMessageDelete.listen(_deleteMessage);
    _ui.onMessageSend.listen(_sendMessage);
  }

  /**
   * Queue/send [message] and update the UI.
   */
  dynamic _sendMessage(model.Message message) async {
    try {
      model.Message savedMessage = await _messageController.save(message);
      model.MessageQueueEntry response =
          await _messageController.enqueue(savedMessage);

      _ui.moveMessage(savedMessage);

      _log.info('Message id ${response.message.id} successfully enqueued');
      _popup.success(_langMap[Key.messageSaveSendSuccessTitle],
          'ID ${response.message.id}');
    } catch (error) {
      _log.shout('Could not save/enqueue ${message.toJson()} $error');
      _popup.error(_langMap[Key.messageSaveSendErrorTitle], 'ID ${message.id}');
    }
  }
}
