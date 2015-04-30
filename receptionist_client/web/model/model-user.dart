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

part of model;

abstract class UserConstants {
  static final String ID   = "id";
  static final String NAME = "name";
}

/**
 * TODO: Write up documentation for this class and refer to wiki page.
 */
class User extends ORModel.User {
  static final String className    = '${libraryName}.User';
  static       User   _currentUser = null; // Singleton User
  final        Bus    _idle        = new Bus();
  static final int    noID         = ORModel.User.nullID;
  final        Bus    _pause       = new Bus();

  /**
   * Constructor fromMap.
   */
  User.fromMap(Map map) : super.fromMap(map);

  /**
   * Constructor fromORModel.
   */
  User.fromORModel(ORModel.User user) : this.fromMap (user.toJson());

  /**
   * Get the current user.
   */
  static ORModel.User get currentUser => _currentUser;

  /**
   * Set the current user.
   */
  static set currentUser (ORModel.User newUser) => _currentUser = newUser;

  /**
   * Fires when [currentUser] goes idle.
   */
  Stream get onIdle => this._idle.stream;

  /**
   * Fires when [currentUser] pauses.
   */
  Stream get onPause => this._pause.stream;

  /**
   * Returne the identity map for the [currentUser]. This contains the user Id
   * and the user name.
   */
  Map identityMap() => {UserConstants.ID : this.ID, UserConstants.NAME : this.name};
}
