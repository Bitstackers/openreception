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
abstract class User extends ORModel.User {

  static final className = '${libraryName}.User';

  /* Singleton representing the current user. */
  static ORModel.User _currentUser = null;
  //static User _currentUser = ORModel.User.noUser;

  Map identityMap () {
    return {UserConstants.ID : this.ID, UserConstants.NAME : this.name};
  }

  /*
   * Getter and setters for the singleton user object.
   */
  static ORModel.User get currentUser => _currentUser;
  static              set currentUser (ORModel.User newUser) => _currentUser = newUser;

  /**
   * Null object constructor.
   */
  User._null() : super.fromMap({});
}
