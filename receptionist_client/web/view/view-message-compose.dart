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
  final Controller.Destination    _myDestination;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIMessageCompose    _uiModel;

  /**
   * Constructor.
   */
  MessageCompose(Model.UIMessageCompose this._uiModel,
                 Controller.Destination this._myDestination,
                 Model.UIContactSelector this._contactSelector,
                 Model.UIReceptionSelector this._receptionSelector) {
    _ui.setHint('alt+b | ctrl+space');

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
   * Cancel sending a message.
   */
  void _cancel(_) {
    print('MessageCompose.cancel() not implemented yet');
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _hotKeys.onAltB.listen(_activateMe);

    _contactSelector.onSelect.listen(_render);

    _ui.onCancel.listen(_cancel);
    _ui.onClick .listen(_activateMe);
    _ui.onSave  .listen(_save);
    _ui.onSend  .listen(_send);
  }

  /**
   * Render the widget with [Contact].
   */
  void _render(Model.Contact contact) {
    if(contact.isEmpty) {
      print('View.MessageCompose got an empty contact - undecided on what to do');
      /// TODO (TL): What should we do here?
    } else {
      _ui.recipients = contact.distributionList;
    }
  }

  /**
   * Save message in the message archive.
   */
  void _save(_) {
    print('MessageCompose.save() not fully implemented yet');
    print(_ui.harvestMessageDataFromForm());
  }

  /**
   * Send message.
   */
  void _send(_) {
    print('MessageCompose.send() not implemented yet');
    print(_ui.harvestMessageDataFromForm());
  }
}
