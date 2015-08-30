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
  final ORService.RESTCalendarStore _calendarStore;

  /**
   * Constructor.
   */
  Calendar(this._calendarStore);

  /**
   * Return the latest entry change information for the [entryId]
   * calendar entry.
   */
  Future<Iterable<ORModel.CalendarEntryChange>> calendarEntryChanges
    (ORModel.CalendarEntry entry) =>
        _calendarStore.calendarEntryChanges(entry.ID);

  /**
   * Return the latest entry change information for the [entryId]
   * calendar entry.
   */
  Future<ORModel.CalendarEntryChange> calendarEntryLatestChange
    (ORModel.CalendarEntry entry) =>
        _calendarStore.calendarEntryLatestChange(entry.ID);

  /**
   * Save [entry] to the database.
   */
  Future createCalendarEvent(ORModel.CalendarEntry entry) =>
      _calendarStore.calendarEntryChanges(entry.ID);

  /**
   * Delete [entry] from the database.
   */
  Future deleteCalendarEvent(ORModel.CalendarEntry entry) =>
      _calendarStore.remove(entry.ID);

  /**
   * Return all the [ORModel.CalendarEntry]'s of a [reception].
   */
  Future<Iterable<ORModel.CalendarEntry>> receptionCalendar
    (ORModel.Reception reception) =>
        _calendarStore.list(new ORModel.Owner.reception(reception.ID));

  /**
   * Return all the [contact] [ORModel.CalendarEntry]'s.
   */
  Future<Iterable<ORModel.CalendarEntry>> contactCalendar
    (ORModel.Contact contact) =>
        _calendarStore.list
          (new ORModel.Owner.contact(contact.ID, contact.receptionID));

  /**
   * Save [entry] to the database.
   */
  Future saveCalendarEvent(ORModel.CalendarEntry entry) =>
      _calendarStore.update(entry);
}
