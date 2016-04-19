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
 * The reception selector widget.
 */
class ReceptionSelector extends ViewWidget {
  final Model.AppClientState _appState;
  final Map<String, String> _langMap;
  final Controller.Destination _myDestination;
  final Controller.Notification _notification;
  final List<ORModel.Call> _pickedUpCalls = new List<ORModel.Call>();
  final Controller.Popup _popup;
  final Controller.Reception _receptionController;
  final List<ORModel.Reception> _receptions;
  bool _refreshReceptionsCache = false;
  Timer refreshReceptionsCacheTimer;
  final Model.UIReceptionSelector _uiModel;

  /**
   * Constructor.
   */
  ReceptionSelector(
      Model.UIReceptionSelector this._uiModel,
      Model.AppClientState this._appState,
      Controller.Destination this._myDestination,
      Controller.Notification this._notification,
      List<ORModel.Reception> this._receptions,
      Controller.Reception this._receptionController,
      Controller.Popup this._popup,
      Map<String, String> this._langMap) {
    _ui.setHint('alt+v');

    _ui.receptions = _receptions;

    _observers();
  }

  @override
  Controller.Destination get _destination => _myDestination;
  @override
  Model.UIReceptionSelector get _ui => _uiModel;

  @override
  void _onBlur(Controller.Destination _) {}
  @override
  void _onFocus(Controller.Destination _) {}

  /**
   * Simply navigate to my [Destination]. Matters not if this widget is already
   * focused.
   */
  void _activateMe() {
    _navigateToMyDestination();
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _hotKeys.onAltV.listen((KeyboardEvent _) => _activateMe());
    _ui.onClick.listen((MouseEvent _) => _activateMe());

    _hotKeys.onCtrlAltR.listen((KeyboardEvent _) {
      final ORModel.Reception selected = _ui.selectedReception;
      if (selected.ID != ORModel.Reception.noID) {
        _receptionController.get(selected.ID).then(_ui.refreshReception);
      }
    });

    _hotKeys.onCtrlEsc.listen((KeyboardEvent _) => _ui.resetFilter());

    _notification.onReceptionChange
        .listen((OREvent.ReceptionChange _) => _refreshReceptionsCache = true);

    _notification.onAnyCallStateChange.listen((OREvent.CallEvent event) {
      if (event.call.assignedTo == _appState.currentUser.id &&
          event.call.state == ORModel.CallState.Hungup) {
        _pickedUpCalls.removeWhere((ORModel.Call c) => c.ID == event.call.ID);
      }
    });

    refreshReceptionsCacheTimer =
        new Timer.periodic(new Duration(seconds: 5), (_) {
      if (_refreshReceptionsCache) {
        _refreshReceptionsCache = false;
        _popup.info(_langMap[Key.receptionChanged], '',
            closeAfter: new Duration(seconds: 3));
        _receptionController
            .list()
            .then((Iterable<ORModel.Reception> receptions) {
          _ui.receptionsCache = receptions.toList()
            ..sort(
                (x, y) => x.name.toLowerCase().compareTo(y.name.toLowerCase()));
        });
      }
    });

    _appState.activeCallChanged.listen((ORModel.Call newCall) {
      if (newCall != ORModel.Call.noCall &&
          newCall.inbound &&
          _ui.selectedReception.ID != newCall.receptionID) {
        if (!_pickedUpCalls.any((ORModel.Call c) => c.ID == newCall.ID)) {
          _pickedUpCalls.add(newCall);

          _ui.resetFilter();
          _ui.changeActiveReception(newCall.receptionID);
        }
      }
    });
  }
}
