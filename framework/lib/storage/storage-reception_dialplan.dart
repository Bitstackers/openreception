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

part of openreception.storage;

/**
 *
 */
abstract class ReceptionDialplan {
  /**
   *
   */
  Future<model.ReceptionDialplan> create(
      model.ReceptionDialplan rdp, model.User user);

  /**
   *
   */
  Future<model.ReceptionDialplan> get(String extension);

  /**
   *
   */
  Future<Iterable<model.ReceptionDialplan>> list();

  /**
   *
   */
  Future<model.ReceptionDialplan> update(
      model.ReceptionDialplan rdp, model.User user);

  /**
   *
   */
  Future remove(String extension, model.User user);
}
