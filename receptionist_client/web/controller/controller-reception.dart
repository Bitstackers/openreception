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
 * Provides services to get, delete and update calendar events.
 */
class Reception {
  final ORService.RESTReceptionStore _store;

  /**
   * Constructor.
   */
  Reception (this._store);

  /**
   *
   */
  Future<Iterable<Model.ReceptionCalendarEntry>> calendar(Model.Reception reception) =>
      _store.calendarMap(reception.ID).then((Iterable<Map> maps) =>
          maps.map((Map map) => new Model.ReceptionCalendarEntry.fromMap(map)));

  /**
   * Return the latest entry change information for the [entryId] calendar entry.
   */
  Future<ORModel.CalendarEntryChange> calendarEntryLatestChange(int entryId) =>
      _store.calendarEntryLatestChange(entryId);

  /**
   *
   */
  Future createCalendarEvent(Model.ReceptionCalendarEntry entry) =>
      _store.calendarEventCreate(entry);

  /**
   *
   */
  Future deleteCalendarEvent(Model.ReceptionCalendarEntry entry) =>
      _store.calendarEventRemove(entry);

  /**
   *
   */
  Future<Iterable<Model.Reception>> list() =>
      _store.listMap().then((Iterable<Map> receptionMaps) =>
          receptionMaps.map((Map map) => new Model.Reception.fromMap(map)));

  /**
   *
   */
  Future saveCalendarEvent(Model.ReceptionCalendarEntry entry) =>
      _store.calendarEventUpdate(entry);
}
