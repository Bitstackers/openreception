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

class Calendar {
  final ORService.RESTContactStore _contactStore;
  final ORService.RESTReceptionStore _receptionStore;

  /**
   * Constructor.
   */
  Calendar(this._contactStore, this._receptionStore);

  /**
   * Return the latest entry change information for the [entryId]
   * calendar entry.
   */
  Future<Iterable<ORModel.CalendarEntryChange>> calendarEntryChanges
    (ORModel.CalendarEntry entry) =>
      entry.isOwnedByContact
          ? _contactStore.calendarEntryChanges(entry.ID)
          : _receptionStore.calendarEntryChanges(entry.ID);

  /**
   * Return the latest entry change information for the [entryId]
   * calendar entry.
   */
  Future<ORModel.CalendarEntryChange> calendarEntryLatestChange
    (ORModel.CalendarEntry entry) =>
      entry.isOwnedByContact
          ? _contactStore.calendarEntryLatestChange(entry.ID)
          : _receptionStore.calendarEntryLatestChange(entry.ID);

  /**
   * Save [entry] to the database.
   */
  Future createCalendarEvent(ORModel.CalendarEntry entry) =>
      entry.isOwnedByContact
          ? _contactStore.calendarEventCreate(entry)
          : _receptionStore.calendarEventCreate(entry);

  /**
   * Delete [entry] from the database.
   */
  Future deleteCalendarEvent(ORModel.CalendarEntry entry) =>
      entry.isOwnedByContact
          ? _contactStore.calendarEventRemove(entry)
          : _receptionStore.calendarEventRemove(entry);

  /**
   * Return all the [ORModel.CalendarEntry]'s of a [reception].
   */
  Future<Iterable<ORModel.CalendarEntry>> receptionCalendar
    (ORModel.Reception reception) => _receptionStore.calendar(reception.ID);

  /**
   * Return all the [contact] [ORModel.CalendarEntry]'s.
   */
  Future<Iterable<ORModel.CalendarEntry>> contactCalendar
    (ORModel.Contact contact) =>
      _contactStore.calendar(contact.ID, contact.receptionID);

  /**
   * Save [entry] to the database.
   */
  Future saveCalendarEvent(ORModel.CalendarEntry entry) =>
      entry.isOwnedByContact
          ? _contactStore.calendarEventUpdate(entry)
          : _receptionStore.calendarEventUpdate(entry);


}
