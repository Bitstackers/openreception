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
 * TODO (TL): Comment
 */
class MyCallQueue extends ViewWidget {
  final Controller.Destination _myDestination;
  final Model.UIMyCallQueue    _ui;
  final Controller.Call         _callController;
  final Controller.Notification    _notifications;

  /**
   * Constructor.
   */
  MyCallQueue(Model.UIMyCallQueue this._ui,
              Controller.Destination this._myDestination,
              Controller.Notification this._notifications,
              Controller.Call this._callController) {

    this._reloadCallList();

    _observers();
  }

  @override Controller.Destination get myDestination => _myDestination;
  @override Model.UIModel          get ui            => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Simply navigate to my [Destination]. Matters not if this widget is already
   * focused.
   */
  void activateMe(_) {
    navigateToMyDestination();
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onClick.listen(activateMe);

    ///Call Observers
    this._notifications.onAnyCallStateChange.listen((Model.Call call) {
      _reloadCallList();
    });
  }

  Future _reloadCallList() {

    bool isMine(Model.Call call) =>
      call.assignedTo == Model.User.currentUser.ID;

    return this._callController.listCalls()
      .then((Iterable<Model.Call> calls) {
        _ui.calls = calls.where(isMine).toList(growable: false);
    });
  }
}
