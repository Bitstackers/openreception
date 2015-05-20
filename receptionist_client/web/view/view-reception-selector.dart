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
class ReceptionSelector extends ViewWidget {
  final Controller.Destination    _myDestination;
  final Model.UIReceptionSelector _ui;
  final Controller.Reception      _receptionController;

  /**
   * Constructor.
   */
  ReceptionSelector(Model.UIModel this._ui,
                    Controller.Destination this._myDestination,
                    Controller.Reception this._receptionController) {
    _ui.setHint('alt+v');
    _observers();

    /// TODO (TL): Move this outside, so grabbing the initial list is a part of
    /// the app loading time.
    this._receptionController.list()
      .then((Iterable<Model.Reception> receptions) {

      Iterable<Model.Reception> sortedReceptions = receptions.toList()
          ..sort((x,y) => x.name.compareTo(y.name));

      this._ui.receptions = sortedReceptions;
    });
  }

  @override Controller.Destination get myDestination => _myDestination;
  @override Model.UIModel          get ui            => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Activate this widget if it's not already activated.
   */
  void activateMe(_) {
    navigateToMyDestination();
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _hotKeys.onAltV.listen(activateMe);

    _ui.onClick.listen(activateMe);

    Model.Call.activeCallChanged.listen((Model.Call newCall) {
      if (newCall != Model.Call.noCall) {
        _ui.changeActiveReception(newCall.receptionID);
      }
    });
  }
}
