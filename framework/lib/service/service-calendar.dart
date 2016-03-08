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

part of openreception.service;

/**
 * Client for contact service.
 */
class RESTCalendarStore implements Storage.Calendar {
  static final Logger log = new Logger('${libraryName}.RESTCalendarStore');

  WebService _backend = null;
  final Uri _calendarHost;
  String _token = '';

  RESTCalendarStore(Uri this._calendarHost, String this._token, this._backend);

  Future<Iterable<Model.CalendarEntry>> list(Model.Owner owner,
      {bool deleted: false}) {
    Uri url = Resource.Calendar.list(_calendarHost, owner, deleted: deleted);

    url = _appendToken(url, this._token);

    Iterable<Model.CalendarEntry> convertMaps(Iterable<Map> maps) =>
        maps.map(Model.CalendarEntry.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }

  Future<Model.CalendarEntry> get(int id, {bool deleted: false}) {
    Uri url = Resource.Calendar.single(_calendarHost, id, deleted: deleted);
    url = _appendToken(url, this._token);

    return this
        ._backend
        .get(url)
        .then(JSON.decode)
        .then(Model.CalendarEntry.decode);
  }

  /**
   *
   */
  Future<Model.CalendarEntry> create(
      Model.CalendarEntry entry, Model.User user) {
    Uri url = Resource.Calendar.base(_calendarHost);
    url = _appendToken(url, this._token);

    return this
        ._backend
        .post(url, JSON.encode(entry))
        .then(JSON.decode)
        .then(Model.CalendarEntry.decode);
  }

  /**
   *
   */
  Future<Model.CalendarEntry> update(
      Model.CalendarEntry entry, Model.User modifier) {
    Uri url = Resource.Calendar.single(_calendarHost, entry.id);
    url = _appendToken(url, this._token);

    return _backend
        .put(url, JSON.encode(entry))
        .then(JSON.decode)
        .then(Model.CalendarEntry.decode);
  }

  /**
   *
   */
  Future removeEntry(Model.CalendarEntry entry) {
    Uri url = Resource.Calendar.single(_calendarHost, entry.id);
    url = _appendToken(url, this._token);

    return this._backend.delete(url);
  }

  /**
   *
   */
  Future remove(int eid, Model.User user) {
    Uri url = Resource.Calendar.single(_calendarHost, eid);
    url = _appendToken(url, this._token);

    return this._backend.delete(url);
  }

  /**
   *
   */
  Future<Iterable<Model.CalendarEntryChange>> changes(entryId) {
    Uri url = Resource.Calendar.changeList(_calendarHost, entryId);
    url = _appendToken(url, this._token);

    Iterable<Model.CalendarEntryChange> convertMaps(Iterable<Map> maps) =>
        maps.map(Model.CalendarEntryChange.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }

  /**
   *
   */
  Future<Model.CalendarEntryChange> latestChange(int eid) {
    Uri url = Resource.Calendar.latestChange(_calendarHost, eid);

    url = _appendToken(url, this._token);

    return _backend
        .get(url)
        .then(JSON.decode)
        .then(Model.CalendarEntryChange.decode);
  }
}
