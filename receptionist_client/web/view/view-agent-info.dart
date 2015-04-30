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
class AgentInfo extends ViewWidget {
  final Logger            _log = new Logger('$libraryName.AgentInfo');
  final Model.UIAgentInfo _ui;

  /**
   * Constructor.
   * Add Iterable<UserStatus> as parameter for extraction of global user state.
   */
  AgentInfo(Model.UIModel this._ui) {
    _ui.activeCount = 0;
    _ui.pausedCount = 0;
    _ui.agentState = AgentState.UNKNOWN;
    _ui.alertState = AlertState.ON;
    _ui.portrait = 'images/face.png';

    /// TODO (TL): Add a portrait getter to Model.User.
    _ui.portrait = Model.User.currentUser.toJson()['remote_attributes']['picture'];

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
    /// TODO (TL): Add relevant listeners
    ///   _ui.activeCount = active count
    ///   _ui.agentState = agent state
    ///   _ui.alertState = alert state
    ///   _ui.pausedCount = paused count
    ///   Listen on Notification socket UserStatus events and update DOM
    ///   accordingly
    ///
  }
}
