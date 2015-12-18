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

/**
 *
 */
abstract class Calendar {
  /**
   *
   */
  Future<Iterable<Model.CalendarEntryChange>> changes(entryId);

  /**
   *
   */
  Future<Model.CalendarEntry> create(Model.CalendarEntry entry, int userId);

  /**
   *
   */
  Future<Model.CalendarEntry> get(int entryId, {bool deleted: false});

  /**
   *
   */
  Future<Model.CalendarEntryChange> latestChange(entryID);

  /**
   *
   */
  Future<Iterable<Model.CalendarEntry>> list(Model.Owner owner,
      {bool deleted: false});

  /**
   * Completely wipes the [Model.CalendarEntry] associated with [entryId]
   * from the database.
   */
  Future purge(int entryId);

  /**
   * Trashes the [Model.CalendarEntry] associated with [entryId] in the
   * database, but keeps the object (in a hidden state) in the database.
   * The action is logged to be performed by user with ID [userId].
   */
  Future remove(int entryId, int userId);

  /**
   *
   */
  Future<Model.CalendarEntry> update(Model.CalendarEntry entry, int userId);
}
