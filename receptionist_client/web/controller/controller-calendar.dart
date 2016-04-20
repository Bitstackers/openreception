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

part of controller;

/**
 * Exposes methods for calendar CRUD operations.
 */
class Calendar {
  final ORService.RESTCalendarStore _calendarStore;
  final ORModel.User _user;

  /**
   * Constructor.
   */
  Calendar(this._calendarStore, this._user);

  /**
   * Return the latest entry change information for the [entryId] calendar entry.
   */
  Future<Iterable<ORModel.Commit>> calendarEntryChanges(
          ORModel.CalendarEntry entry) =>
      _calendarStore.changes(entry.owner);

  /**
   * Return the latest entry change information for the [entryId] calendar entry.
   */
  Future<ORModel.Commit> calendarEntryLatestChange(
          ORModel.CalendarEntry entry) async =>
      (await _calendarStore.changes(entry.owner)).first;

  /**
   * Save [entry] to the database.
   */
  Future createCalendarEvent(ORModel.CalendarEntry entry) =>
      _calendarStore.create(entry, _user);

  /**
   * Return all the [contact] [ORModel.CalendarEntry]s.
   */
  Future<Iterable<ORModel.CalendarEntry>> contactCalendar(
          ORModel.ContactReference cRef) =>
      _calendarStore.list(new ORModel.OwningContact(cRef.id));

  /**
   * Delete [entry] from the database.
   */
  Future deleteCalendarEvent(ORModel.CalendarEntry entry) =>
      _calendarStore.removeEntry(entry);

  /**
   * Return all the [ORModel.CalendarEntry]s of a [reception].
   */
  Future<Iterable<ORModel.CalendarEntry>> receptionCalendar(
          ORModel.ReceptionReference reception) =>
      _calendarStore.list(new ORModel.OwningReception(reception.id));

  /**
   * Save [entry] to the database.
   */
  Future saveCalendarEvent(ORModel.CalendarEntry entry) =>
      entry.id == ORModel.CalendarEntry.noId
          ? createCalendarEvent(entry)
          : _calendarStore.update(entry, _user);
}
