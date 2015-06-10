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
 * Component for creating/editing and saving/sending messages.
 */
class MessageCompose extends ViewWidget {
  final Model.UIContactSelector   _contactSelector;
  final Map<String, String>       _langMap;
  final Logger                    _log = new Logger('$libraryName.MessageCompose');
  final Controller.Message        _messageController;
  final Controller.Destination    _myDestination;
  final Popup                     _popup;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIMessageCompose    _uiModel;

  /**
   * Constructor.
   */
  MessageCompose(Model.UIMessageCompose this._uiModel,
                 Controller.Destination this._myDestination,
                 Model.UIContactSelector this._contactSelector,
                 Model.UIReceptionSelector this._receptionSelector,
                 Controller.Message this._messageController,
                 Popup this._popup,
                 Map<String, String> this._langMap) {
    _ui.setHint('alt+b | ctrl+space | ctrl+s | ctrl+enter');

    _observers();
  }

  @override Controller.Destination get _destination => _myDestination;
  @override Model.UIMessageCompose get _ui          => _uiModel;

  @override void _onBlur(_) {}
  @override void _onFocus(_) {}

  /**
   * Simply navigate to my [_myDestination]. Matters not if this widget is already
   * focused.
   */
  void _activateMe(_) {
    _navigateToMyDestination();
  }

  /**
   * Return a [ORModel.Message] build from the form data and the currently selected
   * contact.
   */
  ORModel.Message get _message {
    final ORModel.Contact contact    = _contactSelector.selectedContact;
    final Map             messageMap = _ui.messageDataFromForm;
    final ORModel.Reception reception  = _receptionSelector.selectedReception;

    final ORModel.MessageContext messageContext =
      new ORModel.MessageContext.fromContact(contact, reception);

    final ORModel.MessageCaller callerInfo =
      new ORModel.MessageCaller.fromMap(messageMap['caller']);

    final ORModel.MessageRecipientList recipients = _ui.recipients;

    return new ORModel.Message()
      ..recipients = recipients
      ..context    = messageContext
      ..body       = messageMap['message']
      ..flags      = messageMap['flags']
      ..createdAt  = new DateTime.now()
      ..caller     = callerInfo
      ..sender     = ORModel.User.currentUser;
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _ui.onClick.listen(_activateMe);

    _hotKeys.onAltB.listen(_activateMe);

    _contactSelector.onSelect.listen(_render);
    _receptionSelector.onSelect.listen(_resetOnEmpty);

    _ui.onSave.listen(_save);
    _ui.onSend.listen(_send);
  }

  /**
   * Render the widget with [Contact].
   */
  void _render(ORModel.Contact contact) {
    if(contact.isEmpty) {
      _log.info('Got an empty contact - undecided on what to do');
    } else {
      _ui.recipients = contact.distributionList;
      _ui.messagePrerequisites = contact.messagePrerequisites;
    }
  }

  /**
   * If we get an empty reception then reset the widget to it's pristine state.
   */
  void _resetOnEmpty(ORModel.Reception reception) {
    if(reception.isEmpty) {
      _ui.reset(pristine: true);
    }
  }

  /**
   * Save message in the message archive.
   */
  void _save(_) {
    final ORModel.Message message = _message;

    _messageController.save(message).then((ORModel.Message savedMessage) {
      _ui.reset();
      _ui.focusOnCurrentFocusElement();
      _log.info('Message id ${savedMessage.ID} successfully saved');
      _popup.success(_langMap[Key.messageSaveSuccessTitle], 'ID ${savedMessage.ID}');
    })
    .catchError((error) {
      _log.shout('Could not save ${message.asMap} $error');
      _popup.error(_langMap[Key.messageSaveErrorTitle], 'ID ${message.ID}');
    });
  }

  /**
   * Send message. This entails first saving and the enqueueing the message.
   */
  void _send(_) {
    final ORModel.Message message = _message;

    _messageController.save(message).then((ORModel.Message savedMessage) {
      _messageController.enqueue(savedMessage).then((ORModel.MessageQueueItem response) {
        _ui.reset();
        _ui.focusOnCurrentFocusElement();
        _log.info('Message id ${response.messageID} successfully enqueued');
        _popup.success(_langMap[Key.messageSendSuccessTitle], 'ID ${savedMessage.ID}');
      })
      .catchError((error) {
        _log.shout('$error Could not enqueue ${savedMessage.asMap} $error');
        _popup.error(_langMap[Key.messageSendErrorTitle], 'ID ${savedMessage.ID}');
      });
    })
    .catchError((error) {
      _log.shout('Could not save ${message.asMap} $error');
      _popup.error(_langMap[Key.messageSaveErrorTitle], 'ID ${message.ID}');
    });
  }
}
