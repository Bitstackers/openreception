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
  final Controller.Message _message;
  final Controller.Destination _myDestination;
  final ORModel.MessageFilter _notSavedFilter =
      new ORModel.MessageFilter.empty()
        ..limitCount = 100
        ..messageState = ORModel.MessageState.NotSaved;
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
      Controller.Message this._message,
      Controller.User this._user,
      Model.UIContactSelector this._contactSelector,
      Model.UIReceptionSelector this._receptionSelector) {
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

      _message.list(_savedFilter).then(
          (Iterable<ORModel.Message> messages) => _ui.savedMessages = messages);

      if (header != _ui.header) {
        _ui.headerExtra = header;
        _ui.clearNotSavedList();
        if (_receptionSelector.selectedReception.isNotEmpty &&
            _contactSelector.selectedContact.isNotEmpty) {
          _notSavedFilter.contactID = _contactSelector.selectedContact.ID;
          _notSavedFilter.receptionID = _receptionSelector.selectedReception.ID;

          _message.list(_notSavedFilter).then(
              (Iterable<ORModel.Message> messages) =>
                  _ui.notSavedMessages = messages);
        }
      }
    });
  }

  /**
   * Simply navigate to my [_myDestination]. Matters not if this widget is already
   * focused.
   */
  void _activateMe(_) {
    _navigateToMyDestination();
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

      _message
          .list(filter)
          .then((Iterable<ORModel.Message> messages) =>
              _ui.notSavedMessages = messages)
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

    _ui.onClick.listen(_activateMe);

    _ui.scrolledToBottom.listen(_handleScrolling);
  }
}
