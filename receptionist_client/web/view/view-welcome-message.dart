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
class WelcomeMessage extends ViewWidget {
  final Map<String, String>       _langMap;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIWelcomeMessage    _ui;

  /**
   * Constructor.
   */
  WelcomeMessage(Model.UIModel this._ui,
                 Model.UIReceptionSelector this._receptionSelector,
                 Map<String, String> this._langMap) {
    _observers();
  }

  @override Controller.Destination get myDestination => null;
  @override Model.UIModel          get ui            => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Observers.
   */
  void _observers() {
    _receptionSelector.onSelect.listen(render);
    Model.Call.activeCallChanged.listen((Model.Call newCall) {
      this._ui.inActiveCall = newCall != Model.Call.noCall;
    });
  }

  /**
   * Render the widget with [reception].
   */
  void render(Model.Reception reception) {
    if(reception.isEmpty) {
      _ui.clear();
      _ui.greeting = _langMap[Key.standardGreeting];
    } else {
      if (Model.Call.activeCall != Model.Call.noCall) {
        _ui.greeting = Model.Call.activeCall.greetingPlayed
           ? reception.greeting
           : reception.shortGreeting;
      } else {
        _ui.greeting = reception.greeting;
      }

    }
  }
}
