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
 * Show the global call queue and registers keyboard shortcuts for call handling.
 *
 * This reloads the call queue list at a fixed refresh rate of [_refreshRate].
 */
class GlobalCallQueue extends ViewWidget {
  final Controller.Destination  _myDestination;
  final Model.UIGlobalCallQueue _uiModel;
  final Controller.Call         _callController;
  final Controller.Notification _notifications;

  /**
   * Constructor.
   */
  GlobalCallQueue(Model.UIGlobalCallQueue this._uiModel,
                  Controller.Destination this._myDestination,
                  Controller.Notification this._notifications,
                  Controller.Call this._callController) {
    _loadCallList();
    _observers();
  }

  @override Controller.Destination  get _destination => _myDestination;
  @override Model.UIGlobalCallQueue get _ui          => _uiModel;

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
   * Load the list of calls not currently assigned to anybody.
   */
  void _loadCallList() {
    bool unassigned(Model.Call call) => call.assignedTo == Model.User.noID;

    _callController.listCalls().then((Iterable<Model.Call> calls) {
      _ui.calls = calls.where(unassigned).toList(growable: false);
    });
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _ui.onClick.listen(_activateMe);

    /// TODO (KRC): Do stuff here...
    _notifications.onAnyCallStateChange.listen((Model.Call call) {
      switch(call.state) {
        case ORModel.CallState.Created:
          this._ui.appendCall(call);
          break;

        case ORModel.CallState.Hungup:
          this._ui.removeCall(call);
          break;

        case ORModel.CallState.Speaking:
          this._ui.removeCall(call);
          break;

        default:
          this._ui.updateCall(call);
          break;
      }
    });

    _hotKeys.onNumPlus.listen((_) => _callController.pickupNext());

    _hotKeys.onNumDiv.listen((_) => _callController.hangup(Model.Call.activeCall));

    _hotKeys.onF7.listen((_) => _callController.park(Model.Call.activeCall));

    _hotKeys.onF8.listen((_) => _callController.pickupFirstParkedCall());
  }
}
