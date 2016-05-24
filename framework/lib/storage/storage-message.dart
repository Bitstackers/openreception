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

part of openreception.framework.storage;

abstract class Message {
  /**
   *
   */
  Future<model.Message> get(int mid);

  /**
   *
   */
  Future<Iterable<model.Message>> getByIds(Iterable<int> ids);

  /**
   *
   */
  @deprecated
  Future<Iterable<model.Message>> list({model.MessageFilter filter});

  /**
   *
   */
  Future<Iterable<model.Message>> listDay(DateTime day);

  /**
   *
   */
  Future<model.Message> create(model.Message message, model.User modifier);

  /**
   *
   */
  Future<model.Message> update(model.Message message, model.User modifier);

  /**
   *
   */
  Future remove(int mid, model.User modifier);

  /**
   *
   */
  Future<Iterable<model.Commit>> changes([int mid]);
}
