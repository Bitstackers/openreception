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

part of model;

class UserStatus extends ORModel.UserStatus {

  Bus<UserStatus> _statusChange = new Bus<UserStatus>();

  Stream<UserStatus> get onStateChange => this._statusChange.stream;

  UserStatus.fromMap(Map map) : super.fromMap(map);

  UserStatus._null() : super();

  void update (UserStatus newValues) {
    this.lastState = this.state;
    this.state = newValues.state;
    this.callsHandled = newValues.callsHandled;
    this.lastActivity = newValues.lastActivity;

    this._statusChange.fire(this);
  }
}
