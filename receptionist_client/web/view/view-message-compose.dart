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
  final Model.AppClientState _appState;
  final Model.UIContactSelector _contactSelector;
  final Controller.DistributionList _distributionListController;
  final Controller.Endpoint _endpointController;
  final Map<String, String> _langMap;
  ORModel.Contact _latestContact = new ORModel.Contact.empty();
  final Logger _log = new Logger('$libraryName.MessageCompose');
  final Controller.Message _messageController;
  final Controller.Destination _myDestination;
  final Controller.Notification _notification;
  final List<ORModel.Call> _pickedUpCalls = new List<ORModel.Call>();
  final Controller.Popup _popup;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIMessageArchive _uiMessageArchive;
  final Model.UIMessageCompose _uiModel;

  /**
   * Constructor.
   */
  MessageCompose(
      Model.UIMessageCompose this._uiModel,
      Model.UIMessageArchive this._uiMessageArchive,
      Model.AppClientState this._appState,
      Controller.Destination this._myDestination,
      Model.UIContactSelector this._contactSelector,
      Model.UIReceptionSelector this._receptionSelector,
      Controller.Message this._messageController,
      Controller.Notification this._notification,
      Controller.DistributionList this._distributionListController,
      Controller.Endpoint this._endpointController,
      Controller.Popup this._popup,
      Map<String, String> this._langMap) {
    _ui.setHint('alt+b | ctrl+space | ctrl+s | ctrl+enter');

    _observers();
  }

  @override Controller.Destination get _destination => _myDestination;
  @override Model.UIMessageCompose get _ui => _uiModel;

  @override void _onBlur(Controller.Destination _) {}
  @override void _onFocus(Controller.Destination _) {}

  /**
   * Simply navigate to my [_myDestination]. Matters not if this widget is
   * already focused.
   */
  void _activateMe() {
    _navigateToMyDestination();
  }

  /**
   * Return a [ORModel.Message] build from the form data and the currently
   * selected contact.
   */
  ORModel.Message get _message {
    final ORModel.Message message = _ui.message;
    final ORModel.MessageContext messageContext = new ORModel.MessageContext.fromContact(
        _contactSelector.selectedContact, _receptionSelector.selectedReception);

    message.context = messageContext;

    return message;
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _ui.onClick.listen((MouseEvent _) => _activateMe());
    _hotKeys.onAltB.listen((KeyboardEvent _) => _activateMe());

    _contactSelector.onSelect.listen((Model.ContactWithFilterContext c) => _render(c.contact));

    _notification.onAnyCallStateChange.listen((OREvent.CallEvent event) {
      if (event.call.assignedTo == _appState.currentUser.id &&
          event.call.state == ORModel.CallState.Hungup) {
        _pickedUpCalls.removeWhere((ORModel.Call c) => c.ID == event.call.ID);
      }
    });

    _appState.activeCallChanged.listen((ORModel.Call newCall) {
      if (newCall != ORModel.Call.noCall &&
          newCall.inbound &&
          !_pickedUpCalls.any((ORModel.Call c) => c.ID == newCall.ID)) {
        _pickedUpCalls.add(newCall);

        _ui.reset(pristine: true);
      }
    });

    _ui.onSave.listen((MouseEvent _) => _save());
    _ui.onSend.listen((MouseEvent _) => _send());

    _uiMessageArchive.onMessageCopy.listen((ORModel.Message msg) {
      /**
       * Hack alert!
       * For some odd reason we're forced to wrap the _activateMe() call in a Future, else the
       * HTML textarea will not focus. I've no idea why.
       */
      new Future(() {
        _activateMe();

        _ui.message = msg;
      });
    });
  }

  /**
   * Render the widget with [Contact].
   */
  void _render(ORModel.Contact contact) {
    if (_latestContact.ID != contact.ID) {
      _latestContact = contact;

      _ui.headerExtra = contact.fullName.isEmpty ? '' : ': ${contact.fullName}';

      if (contact.isEmpty) {
        _ui.resetOnEmptyContact();
      } else {
        final Set<ORModel.MessageRecipient> recipients = new Set<ORModel.MessageRecipient>();

        _distributionListController
            .list(contact.receptionID, contact.ID)
            .then((ORModel.DistributionList dList) {
          Future.forEach(dList, (ORModel.DistributionListEntry dle) {
            return _endpointController
                .list(dle.receptionID, dle.contactID)
                .then((Iterable<ORModel.MessageEndpoint> meps) {
              final List<ORModel.MessageRecipient> mrl = new List<ORModel.MessageRecipient>();

              for (ORModel.MessageEndpoint mep in meps) {
                mrl.add(new ORModel.MessageRecipient(mep, dle));
              }

              recipients.addAll(mrl);
            });
          }).whenComplete(() {
            _ui.recipients = recipients;
          });
        });

        _ui.messagePrerequisites = contact.messagePrerequisites;
      }
    }
  }

  /**
   * Save message in the message archive.
   */
  dynamic _save() async {
    final ORModel.Message message = _message;

    try {
      ORModel.Message savedMessage = await _messageController.save(message);

      _ui.reset();
      _ui.focusOnCurrentFocusElement();

      _log.info('Message id ${savedMessage.ID} successfully saved');
      _popup.success(_langMap[Key.messageSaveSuccessTitle], 'ID ${savedMessage.ID}');
    } catch (error) {
      _log.shout('Could not save ${message.asMap} $error');
      _popup.error(_langMap[Key.messageSaveErrorTitle], 'ID ${message.ID}');
    }
  }

  /**
   * Send message. This entails first saving and then enqueueing the message.
   */
  dynamic _send() async {
    final ORModel.Message message = _message;

    try {
      ORModel.Message savedMessage = await _messageController.save(message);
      ORModel.MessageQueueItem response = await _messageController.enqueue(savedMessage);

      _ui.reset();
      _ui.focusOnCurrentFocusElement();

      _log.info('Message id ${response.messageID} successfully enqueued');
      _popup.success(_langMap[Key.messageSaveSendSuccessTitle], 'ID ${response.messageID}');
    } catch (error) {
      _log.shout('Could not save/enqueue ${message.asMap} $error');
      _popup.error(_langMap[Key.messageSaveSendErrorTitle], 'ID ${message.ID}');
    }
  }
}
