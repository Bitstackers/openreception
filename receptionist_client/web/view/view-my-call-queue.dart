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
 * Show the my call queue and registers keyboard shortcuts for call handling.
 *
 * This reloads the call queue list at a fixed refresh rate of [_refreshRate].
 */
class MyCallQueue extends ViewWidget {
  final Controller.Destination  _myDestination;
  final Model.UIMyCallQueue     _uiModel;
  final Controller.Call         _callController;
  final Controller.Notification _notifications;
  final int                     _refreshRate = 1000;

  /**
   * Constructor.
   */
  MyCallQueue(Model.UIMyCallQueue this._uiModel,
              Controller.Destination this._myDestination,
              Controller.Notification this._notifications,
              Controller.Call this._callController) {
    _observers();
  }

  @override Controller.Destination get _destination => _myDestination;
  @override Model.UIMyCallQueue    get _ui          => _uiModel;

  @override void _onBlur(_){}
  @override void _onFocus(_){}

  /**
   * Simply navigate to my [Destination]. Matters not if this widget is already
   * focused.
   */
  void _activateMe(_) {
    _navigateToMyDestination();
  }

  /**
   * Load the list of calls assigned to current user and not being transferred.
   */
  void _loadCallList() {
    bool isMine(Model.Call call) =>
        call.assignedTo == Model.User.currentUser.ID &&
        call.state != ORModel.CallState.Transferred;

    _callController.listCalls().then((Iterable<Model.Call> calls) {
      _ui.calls = calls.where(isMine).toList(growable: false);
    });
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _ui.onClick.listen(_activateMe);

    /// Load the call list every 1 second.
    new Timer.periodic(new Duration(milliseconds: _refreshRate), (_) {
      _loadCallList();
    });

    _hotKeys.onCtrlNumMinus.listen((_) =>
        _callController.transferToFirstParkedCall(Model.Call.activeCall));

    _notifications.onAnyCallStateChange.listen((Model.Call call) => _loadCallList());
  }
}
