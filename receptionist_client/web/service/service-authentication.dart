/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of service;

class Authentication {

  static Authentication _instance = null;

  static Authentication get instance {
    if (_instance == null) {
      _instance = new Authentication();
    }

    return _instance;
  }

  ORService.Authentication _store = null;

  Authentication () {
    this._store = new ORService.Authentication
          (configuration.authBaseUrl,
           configuration.token,
           new ORServiceHTML.Client());
    }

  Future<Model.User> userOf (String token) =>
    this._store.userOf(token).then((ORModel.User user) =>
        new Model.User.fromORModel(user));

}
