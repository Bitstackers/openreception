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

abstract class Organization {
  /**
   *
   */
  Future<Iterable<model.ContactReference>> contacts(int oid);

  /**
   *
   */
  Future<model.OrganizationReference> create(
      model.Organization organization, model.User modifier);

  /**
   *
   */
  Future<model.Organization> get(int oid);

  /**
   *
   */
  Future<Iterable<model.OrganizationReference>> list();

  /**
   *
   */
  Future remove(int oid, model.User modifier);

  /**
   *
   */
  Future<model.OrganizationReference> update(
      model.Organization organization, model.User modifier);

  /**
   *
   */
  Future<Iterable<model.ReceptionReference>> receptions(int oid);
}
