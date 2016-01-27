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

/**
 * The message archive list.
 */
class MessageArchive extends ViewWidget {
  final Model.UIContactSelector _contactSelector;
  bool _getMessagesOnScroll = true;
  final Map<String, String> _langMap;
  final Logger _log = new Logger('$libraryName.MessageArchive');
  final Controller.Message _messageController;
  final Model.UIMessageCompose _messageCompose;
  final Controller.Destination _myDestination;
  final ORModel.MessageFilter _notSavedFilter = new ORModel.MessageFilter.empty()
    ..limitCount = 100
    ..messageState = ORModel.MessageState.NotSaved;
  final Controller.Popup _popup;
  final Model.UIReceptionSelector _receptionSelector;
  final ORModel.MessageFilter _savedFilter = new ORModel.MessageFilter.empty()
    ..limitCount = 1000
    ..messageState = ORModel.MessageState.Saved;
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

  @override Controller.Destination get _destination => _myDestination;
  @override Model.UIMessageArchive get _ui => _uiModel;

  @override void _onBlur(Controller.Destination _) {
    _ui.hideYesNoBoxes();
  }

  @override void _onFocus(Controller.Destination _) {
    _ui.context = new ORModel.MessageContext.empty()
      ..contactID = _contactSelector.selectedContact.ID
      ..receptionID = _receptionSelector.selectedReception.ID;

    String header =
        '(${_contactSelector.selectedContact.fullName} @ ${_receptionSelector.selectedReception.name})';

    if (_receptionSelector.selectedReception == ORModel.Reception.noReception) {
      header = '';
      _ui.headerExtra = '';
      _ui.clearNotSavedList();
    }

    _user.list().then((Iterable<ORModel.User> users) {
      _ui.users = users;

      _messageController
          .list(_savedFilter)
          .then((Iterable<ORModel.Message> messages) => _ui.savedMessages = messages);

      if (header != _ui.header) {
        _ui.headerExtra = header;
        _ui.clearNotSavedList();
        if (_receptionSelector.selectedReception.isNotEmpty &&
            _contactSelector.selectedContact.isNotEmpty) {
          _notSavedFilter.contactID = _contactSelector.selectedContact.ID;
          _notSavedFilter.receptionID = _receptionSelector.selectedReception.ID;

          _messageController
              .list(_notSavedFilter)
              .then((Iterable<ORModel.Message> messages) => _ui.notSavedMessages = messages);
        }
      }
    });
  }

  /**
   * Simply navigate to my [_myDestination]. Matters not if this widget is already
   * focused.
   */
  void _activateMe(MouseEvent event) {
    if (event.target is! ButtonElement) {
      _navigateToMyDestination();
    }
  }

  /**
   * Close [message] and update the UI.
   */
  dynamic _closeMessage(ORModel.Message message) async {
    try {
      message.recipients = new Set();

      ORModel.Message savedMessage = await _messageController.save(message);
      ORModel.MessageQueueItem response = await _messageController.enqueue(savedMessage);

      message.flag.manuallyClosed = true;

      _ui.moveMessage(savedMessage);

      _log.info('Message id ${response.messageID} successfully enqueued');
      _popup.success(_langMap[Key.messageCloseSuccessTitle], 'ID ${response.messageID}');
    } catch (error) {
      _log.shout('Could not close ${message.asMap} $error');
      _popup.error(_langMap[Key.messageCloseErrorTitle], 'ID ${message.ID}');
    }
  }

  /**
   * Delete [message] and update the UI.
   */
  dynamic _deleteMessage(ORModel.Message message) async {
    try {
      await _messageController.remove(message.ID);

      _ui.removeMessage(message);

      _log.info('Message id ${message.ID} successfully deleted');
      _popup.success(_langMap[Key.messageDeleteSuccessTitle], 'ID ${message.ID}');
    } catch (error) {
      _log.shout('Could not delete ${message.asMap} $error');
      _popup.error(_langMap[Key.messageDeleteErrorTitle], 'ID ${message.ID}');
    }
  }

  /**
   * Fetch more messages when the user scroll to the bottom of the messages
   * list.
   *
   * NOTE: No matter how frantically the user spams his/her scroll wheel, this
   * method caps the load on the server to one hit per 1 second.
   */
  void _handleScrolling(int messageId) {
    if (messageId > 1 && _getMessagesOnScroll) {
      _getMessagesOnScroll = false;

      final ORModel.MessageFilter filter = new ORModel.MessageFilter.empty()
        ..limitCount = 100
        ..messageState = ORModel.MessageState.NotSaved
        ..upperMessageID = messageId - 1
        ..contactID = _contactSelector.selectedContact.ID
        ..receptionID = _receptionSelector.selectedReception.ID;

      _messageController
          .list(filter)
          .then((Iterable<ORModel.Message> messages) => _ui.notSavedMessages = messages)
          .whenComplete(() {
        new Timer(new Duration(seconds: 1), () {
          _getMessagesOnScroll = true;
        });
      });
    }
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _messageCompose.onSave.listen((MouseEvent _) => _ui.headerExtra = '');
    _messageCompose.onSend.listen((MouseEvent _) => _ui.headerExtra = '');

    _ui.onClick.listen(_activateMe);

    _ui.scrolledToBottom.listen(_handleScrolling);

    /* We don't need to listen on the onMessageCopy stream here. It is handled in MessageCompose. */
    _ui.onMessageClose.listen(_closeMessage);
    _ui.onMessageDelete.listen(_deleteMessage);
    _ui.onMessageSend.listen(_sendMessage);
  }

  /**
   * Queue/send [message] and update the UI.
   */
  dynamic _sendMessage(ORModel.Message message) async {
    try {
      ORModel.Message savedMessage = await _messageController.save(message);
      ORModel.MessageQueueItem response = await _messageController.enqueue(savedMessage);

      savedMessage.enqueued = true;

      _ui.moveMessage(savedMessage);

      _log.info('Message id ${response.messageID} successfully enqueued');
      _popup.success(_langMap[Key.messageSaveSendSuccessTitle], 'ID ${response.messageID}');
    } catch (error) {
      _log.shout('Could not save/enqueue ${message.asMap} $error');
      _popup.error(_langMap[Key.messageSaveSendErrorTitle], 'ID ${message.ID}');
    }
  }
}
