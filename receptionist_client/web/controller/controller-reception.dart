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

class Reception {
  final ORService.RESTReceptionStore _store;

  Reception (this._store);

  Future<Iterable<Model.ReceptionCalendarEntry>> calendar(Model.Reception reception) =>
    this._store.calendarMap(reception.ID).then((Iterable<Map> maps) =>
      maps.map((Map map) => new Model.ReceptionCalendarEntry.fromMap(map)));

  Future<Iterable<Model.Reception>> list() {
    return this._store.listMap()
      .then((Iterable<Map> receptionMaps) =>
        receptionMaps.map ((Map map) {
          return new Model.Reception.fromMap(map);
        }));
  }
  
  Future deleteCalendarEvent (Model.ReceptionCalendarEntry entry) =>
    this._store.calendarEventRemove (entry);
  
  Future saveCalendarEvent (Model.ReceptionCalendarEntry entry) =>
    this._store.calendarEventUpdate(entry);

  Future createCalendarEvent (Model.ReceptionCalendarEntry entry) =>
    this._store.calendarEventCreate (entry);

}
