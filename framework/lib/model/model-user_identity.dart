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

part of openreception.model;

/**
 *
 */
List<FormatException> validateUserIdentity(UserIdentity uiden) {
  final List<FormatException> errors = new List<FormatException>();

  if (uiden.identity == null || uiden.identity.isEmpty) {
    errors.add(new FormatException(
        'Bad value for UserIdentity.identity', uiden.identity));
  }

  if (uiden.userId == null || uiden.userId == User.noID) {
    errors.add(
        new FormatException('Bad value for UserIdentity.userId', uiden.userId));
  }

  return errors;
}

/**
 *
 */
class UserIdentity {
  String identity;
  int userId;

  /**
   *
   */
  UserIdentity.empty();

  /**
   *
   */
  UserIdentity.fromMap(Map map) {
    identity = map['identity'];
    userId = map['user_id'];
  }

  static UserIdentity decode(Map map) => new UserIdentity.fromMap(map);

  /**
   *
   */
  Map toJson() => {'user_id': userId, 'identity': identity};

  /**
   *
   */
  @override
  bool operator ==(UserIdentity other) =>
      this.identity == other.identity && this.userId == other.userId;
}
