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

abstract class Contact {
  /**
   *
   */
  Future addData(model.ReceptionAttributes attr, model.User modifier);

  /**
   *
   */
  Future<model.ContactReference> create(
      model.BaseContact contact, model.User modifier);

  /**
   *
   */
  Future<model.BaseContact> get(int cid);

  /**
   *
   */
  Future<model.ReceptionAttributes> data(int cid, int rid);

  /**
   *
   */
  Future<Iterable<model.ContactReference>> list();

  /**
   *
   */
  Future<Iterable<model.ContactReference>> receptionContacts(int rid);

  /**
   *
   */
  Future<Iterable<model.ContactReference>> organizationContacts(int oid);

  /**
   *
   */
  Future<Iterable<model.OrganizationReference>> organizations(int cid);

  /**
   *
   */
  Future<Iterable<model.ReceptionReference>> receptions(int cid);

  /**
   *
   */
  Future remove(int cid, model.User modifier);

  /**
   *
   */
  Future removeData(int cid, int rid, model.User modifier);

  /**
   *
   */
  Future update(model.BaseContact contact, model.User modifier);

  /**
   *
   */
  Future updateData(model.ReceptionAttributes attr, model.User modifier);

  /**
   *
   */
  Future changes([int uid, int rid]);
}
