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
  final Popup _popup;
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
      Popup this._popup,
      Map<String, String> this._langMap) {
    _observers();
  }

  @override Controller.Destination get _destination => _myDestination;
  @override Model.UIMessageArchive get _ui => _uiModel;

  @override void _onBlur(_) {}
  @override void _onFocus(_) {
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
    if(event.target is! ButtonElement) {
      _navigateToMyDestination();
    }
  }

  /**
   *
   */
  dynamic _closeMessage(ORModel.Message msg) async {
    try {
      msg.recipients = new Set();
      msg.flag.manuallyClosed = true;

      ORModel.Message savedMessage = await _messageController.save(msg);
      ORModel.MessageQueueItem response = await _messageController.enqueue(savedMessage);

      /*
       *
       * Update/refresh the message archive
       *
       *
       */

      _log.info('Message id ${response.messageID} successfully enqueued');
      _popup.success(_langMap[Key.messageCloseSuccessTitle], 'ID ${response.ID}');
    } catch (error) {
      _log.shout('Could not close ${msg.asMap} $error');
      _popup.error(_langMap[Key.messageCloseErrorTitle], 'ID ${msg.ID}');
    }
  }

  /**
   *
   */
  dynamic _deleteMessage(ORModel.Message msg) async {
    try {
      await _messageController.remove(msg.ID);

      /*
       *
       * Update/refresh the message archive
       *
       *
       */

      _log.info('Message id ${msg.ID} successfully deleted');
      _popup.success(_langMap[Key.messageDeleteSuccessTitle], 'ID ${msg.ID}');
    } catch(error) {
      _log.shout('Could not delete ${msg.asMap} $error');
      _popup.error(_langMap[Key.messageDeleteErrorTitle], 'ID ${msg.ID}');
    }
  }

  /**
   * Fetch more messages when the user scroll to the bottom of the messages
   * list.
   *
   * NOTE: No matter how frantically the user spams his/her scroll wheel, this
   * method caps the load on the server to one hit per 2 seconds.
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
        new Timer(new Duration(seconds: 2), () {
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

    _messageCompose.onSave.listen((_) => _ui.headerExtra = '');
    _messageCompose.onSend.listen((_) => _ui.headerExtra = '');

    _ui.onClick.listen(_activateMe);

    _ui.scrolledToBottom.listen(_handleScrolling);

    /* We don't need to listen on the onMessageCopy stream here. It is handled in MessageCompose. */
    _ui.onMessageClose.listen(_closeMessage);
    _ui.onMessageDelete.listen(_deleteMessage);
    _ui.onMessageSend.listen(_sendMessage);
  }

  /**
   *
   */
  dynamic _sendMessage(ORModel.Message msg) async {
    try {
      ORModel.Message savedMessage = await _messageController.save(msg);
      ORModel.MessageQueueItem response = await _messageController.enqueue(savedMessage);

      /*
       *
       * Update/refresh the message archive
       *
       *
       */

      _log.info('Message id ${msg.ID} successfully engqueued');
      _popup.success(_langMap[Key.messageSendSuccessTitle], 'ID ${msg.ID}');
    } catch(error) {
      _log.shout('Could not enqueue ${msg.asMap} $error');
      _popup.error(_langMap[Key.messageSendErrorTitle], 'ID ${msg.ID}');
    }
  }
}
