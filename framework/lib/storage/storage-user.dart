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

part of openreception.storage;

abstract class User {
  Future<Model.User> get(int userID);

  Future<Model.User> getByIdentity(String identity);

  Future<Iterable<Model.User>> list();

  Future<Model.User> create(Model.User user);

  Future<Model.User> update(Model.User user);

  Future remove(int userId);

  Future<Iterable<Model.UserGroup>> userGroups(int userId);

  Future<Iterable<Model.UserGroup>> groups();

  Future joinGroup(int userId, int groupId);

  Future leaveGroup(int userId, int groupId);

  Future<Iterable<Model.UserIdentity>> identities(int userId);

  Future<Model.UserIdentity> addIdentity(Model.UserIdentity identity);

  Future removeIdentity(Model.UserIdentity identity);
}
