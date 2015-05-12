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
class ReceptionCalendar extends ViewWidget {
  final Controller.Destination    _myDestination;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIReceptionCalendar _ui;
  final Controller.Reception      _receptionController;

  /**
   * Constructor.
   */
  ReceptionCalendar(Model.UIModel this._ui,
                    Controller.Destination this._myDestination,
                    Model.UIReceptionSelector this._receptionSelector,
                    Controller.Reception this._receptionController) {
    _ui.setHint('alt+a');
    observers();
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
   * If a contact is selected in [_contactSelector], then navigate to the
   * calendar editor with [cmd] set.
   */
  void _maybeNavigateToEditor(Cmd cmd) {
    if(_receptionSelector.selectedReception.isNotEmpty) {
      _navigate.goCalendarEdit(from: _myDestination..cmd = cmd);
    }
  }

  /**
   * Observers.
   */
  void observers() {
    _navigate.onGo.listen(setWidgetState);

    _hotKeys.onAltA.listen(activateMe);

    _ui.onClick.listen(activateMe);
    _ui.onEdit .listen((_) => _maybeNavigateToEditor(Cmd.EDIT));
    _ui.onNew  .listen((_) => _maybeNavigateToEditor(Cmd.NEW));

    _receptionSelector.onSelect.listen(render);
  }

  /**
   * Render the widget with [reception].
   */
  void render(Model.Reception reception) {
    if(reception.isEmpty) {
      _ui.clear();
    } else {
      _ui.headerExtra = 'for ${reception.name}';

      _receptionController.calendar(reception)
        .then ((Iterable<Model.ReceptionCalendarEntry> entries) {
          _ui.calendarEntries = entries.toList()
              ..sort((a,b) => a.start.compareTo(b.start));
        });
    }
  }
}
