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

/// Storage interface for persistent storage of [model.BaseContact] and
/// [model.ReceptionAttributes] objects.
abstract class Contact {
  Future addData(model.ReceptionAttributes attr, model.User modifier);

  /// Creates and stores a new [model.BaseContact] object persistently using
  /// [contact] data.
  ///
  /// Returns the [model.BaseContact], now containing the ID of the newly created
  /// [model.BaseContact] object. The [modifier] is required for traceability of
  /// who performed the creation.
  Future<model.BaseContact> create(
      model.BaseContact contact, model.User modifier);

  /// Retrive a previously stored [model.BaseContact] identified by [cid].
  Future<model.BaseContact> get(int cid);

  /// Retrive a previously stored [model.ReceptionAttributes] owned by [cid] and
  /// in the context of reception with ID [rid].
  Future<model.ReceptionAttributes> data(int cid, int rid);

  /// Retrieve a list of all [model.BaseContact] in the store.
  Future<Iterable<model.BaseContact>> list();

  Future<Iterable<model.ReceptionContact>> receptionContacts(int rid);

  Future<Iterable<model.BaseContact>> organizationContacts(int oid);

  Future<Iterable<model.OrganizationReference>> organizations(int cid);

  Future<Iterable<model.ReceptionReference>> receptions(int cid);

  /// Permanently removes the previously stored [model.User] object identified
  /// by [uid].
  ///
  /// The [modifier] is required for traceability of who performed the deletion.
  Future remove(int cid, model.User modifier);

  Future removeData(int cid, int rid, model.User modifier);

  /// Updates the previously stored [model.BaseContact] object with data
  /// from [contact].
  ///
  /// The ID in [contact] must be valid and exist in the store, or a [NotFound]
  /// exception is thrown.
  Future update(model.BaseContact contact, model.User modifier);

  /// Updates the previously stored [model.ReceptionAttributes] object with data
  /// from [attr].
  ///
  /// The ID's in [attr] must be valid and exist in the store, or a [NotFound]
  /// exception is thrown.
  /// The [modifier] is required for traceability of who performed the deletion.
  Future updateData(model.ReceptionAttributes attr, model.User modifier);

  /// List contact and attribute set object changes for the store, optionally
  /// for a single [cid] or [cid] and [rid].
  Future changes([int cid, int rid]);
}
