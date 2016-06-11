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

part of view;

class _CachedMessages {
  DateTime lastFetched;
  List<ORModel.Message> list;

  _CachedMessages(DateTime this.lastFetched, List<ORModel.Message> this.list);
}

/**
 * The message archive list.
 */
class MessageArchive extends ViewWidget {
  Map<String, _CachedMessages> _cache = new Map<String, _CachedMessages>();
  final Model.UIContactSelector _contactSelector;
  ORModel.MessageContext _context;
  final Map<String, String> _langMap;
  DateTime _lastFetched;
  final Logger _log = new Logger('$libraryName.MessageArchive');
  final Controller.Message _messageController;
  final Model.UIMessageCompose _messageCompose;
  final Controller.Destination _myDestination;
  final Controller.Popup _popup;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIMessageArchive _uiModel;
  final Controller.User _user;

  /**
   * Constructor.
   */
  MessageArchive(
      Model.UIMessageArchive this._uiModel,
      Controller.Destination this._myDestination,
      Controller.Message this._messageController,
      Controller.User this._user,
      Model.UIContactSelector this._contactSelector,
      Model.UIReceptionSelector this._receptionSelector,
      Model.UIMessageCompose this._messageCompose,
      Controller.Popup this._popup,
      Map<String, String> this._langMap) {
    _observers();
  }

  @override
  Controller.Destination get _destination => _myDestination;
  @override
  Model.UIMessageArchive get _ui => _uiModel;

  @override
  void _onBlur(Controller.Destination _) {
    _ui.hideYesNoBoxes();
    _ui.clearNotSavedList();
    _ui.hideTables();
  }

  @override
  void _onFocus(Controller.Destination _) {
    _lastFetched = new DateTime.now();

    _context = new ORModel.MessageContext.empty()
      ..cid = _contactSelector.selectedContact.contact.id
      ..contactName = _contactSelector.selectedContact.contact.name
      ..rid = _receptionSelector.selectedReception.id
      ..receptionName = _receptionSelector.selectedReception.name;

    _ui.currentContext = _context;

    if (_receptionSelector.selectedReception.isEmpty) {
      _ui.headerExtra = '';
      _ui.clearNotSavedList();
    } else {
      _ui.headerExtra =
          '(${_contactSelector.selectedContact.contact.name} @ ${_receptionSelector.selectedReception.name})';
    }

    _user.list().then((Iterable<ORModel.UserReference> users) {
      _ui.users = users;

      _messageController.listSaved().then(
          (Iterable<ORModel.Message> messages) => _ui.savedMessages = messages);

      if (_cache[_ui.currentContext.contactString] != null) {
        _ui.setMessages(_cache[_ui.currentContext.contactString].list);
        _lastFetched = _cache[_ui.currentContext.contactString].lastFetched;
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
  dynamic _closeMessage(ORModel.Message message) async {
    try {
      message.recipients = new Set();
      message.flag.manuallyClosed = true;

      ORModel.Message savedMessage = await _messageController.save(message);

      _ui.moveMessage(savedMessage);

      _popup.success(
          _langMap[Key.messageCloseSuccessTitle], 'ID ${message.id}');
    } catch (error) {
      _log.shout('Could not close ${message.asMap} $error');
      _popup.error(_langMap[Key.messageCloseErrorTitle], 'ID ${message.id}');
    }
  }

  /**
   * Delete [message] and update the UI.
   */
  dynamic _deleteMessage(ORModel.Message message) async {
    try {
      await _messageController.remove(message.id);

      _ui.removeMessage(message);

      _log.info('Message id ${message.id} successfully deleted');
      _popup.success(
          _langMap[Key.messageDeleteSuccessTitle], 'ID ${message.id}');
    } catch (error) {
      _log.shout('Could not delete ${message.asMap} $error');
      _popup.error(_langMap[Key.messageDeleteErrorTitle], 'ID ${message.id}');
    }
  }

  /**
   * Load more messages.
   *
   * This will never look more than 7 days back, and it will stop as soon as
   * more than 50 messages have been found.
   *
   * Ignores saved messages.
   */
  Future _loadMoreMessages() async {
    if (!_ui.loading) {
      int counter = 0;
      final ORModel.MessageFilter filter = new ORModel.MessageFilter.empty()
        ..contactId = _contactSelector.selectedContact.contact.id
        ..receptionId = _receptionSelector.selectedReception.id;
      final List<ORModel.Message> messages = new List<ORModel.Message>();

      _ui.loading = true;

      while (counter < 7 && messages.length < 50) {
        final List<ORModel.Message> list =
            (await _messageController.list(_lastFetched, filter))
                .where((ORModel.Message msg) =>
                    !msg.saved || (msg.saved && msg.closed))
                .toList();

        if (list.isNotEmpty) {
          messages.addAll(list);
        } else {
          final ORModel.Message emptyMessage = new ORModel.Message.empty()
            ..createdAt = _lastFetched;
          list.add(emptyMessage);
          messages.add(emptyMessage);
        }

        if (_cache[_ui.currentContext.contactString] == null) {
          _cache[_ui.currentContext.contactString] =
              new _CachedMessages(_lastFetched, new List<ORModel.Message>());
        }

        _cache[_ui.currentContext.contactString].list.addAll(list);

        _lastFetched = _lastFetched.subtract(new Duration(days: 1));

        _cache[_ui.currentContext.contactString].lastFetched = _lastFetched;

        counter++;
      }

      _ui.setMessages(messages, addToExisting: true);

      _ui.loading = false;
    }
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _messageCompose.onSave.listen((MouseEvent _) {
      _ui.headerExtra = '';
      _cache.clear();
      _ui.cacheClear();
    });
    _messageCompose.onSend.listen((MouseEvent _) {
      _ui.headerExtra = '';
      _cache.clear();
      _ui.cacheClear();
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

    _receptionSelector.onSelect.listen((_) {
      _cache.clear();
      _ui.cacheClear();
    });
  }

  /**
   * Queue/send [message] and update the UI.
   */
  dynamic _sendMessage(ORModel.Message message) async {
    try {
      ORModel.Message savedMessage = await _messageController.save(message);
      ORModel.MessageQueueEntry response =
          await _messageController.enqueue(savedMessage);

      _ui.moveMessage(savedMessage);

      _log.info('Message id ${response.message.id} successfully enqueued');
      _popup.success(_langMap[Key.messageSaveSendSuccessTitle],
          'ID ${response.message.id}');
    } catch (error) {
      _log.shout('Could not save/enqueue ${message.asMap} $error');
      _popup.error(_langMap[Key.messageSaveSendErrorTitle], 'ID ${message.id}');
    }
  }
}
