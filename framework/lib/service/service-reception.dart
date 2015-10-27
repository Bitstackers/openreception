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

class RESTReceptionStore implements Storage.Reception {
  static final String className = '${libraryName}.RESTReceptionStore';

  WebService _backend = null;
  Uri _host;
  String _token = '';

  RESTReceptionStore(Uri this._host, String this._token, this._backend);

  /**
   * Retrieves and autocasts a calendar list from the store.
   */
  @deprecated
  Future<Iterable<Model.CalendarEntry>> calendar(int receptionID) {
    Uri url = Resource.Reception.calendar(this._host, receptionID);
    url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) {
      Iterable decodedData = JSON.decode(response);

      return decodedData.map(
          (Map calendarMap) => new Model.CalendarEntry.fromMap(calendarMap));
    });
  }

  /**
   *
   */
  @deprecated
  Future<Model.CalendarEntry> calendarEvent(int receptionID, int eventID) {
    Uri url =
        Resource.Reception.calendarEvent(this._host, receptionID, eventID);
    url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        new Model.CalendarEntry.fromMap(JSON.decode(response)));
  }

  /**
   *
   */
  @deprecated
  Future<Model.CalendarEntry> calendarEventCreate(Model.CalendarEntry event) {
    Uri url = Resource.Reception.calendar(this._host, event.receptionID);
    url = appendToken(url, this._token);

    String data = JSON.encode(event);

    return this._backend.post(url, data).then((String response) =>
        new Model.CalendarEntry.fromMap(JSON.decode(response)));
  }

  /**
   *
   */
  @deprecated
  Future<Model.CalendarEntry> calendarEventUpdate(Model.CalendarEntry event) {
    Uri url = Resource.Reception.calendarEvent(
        this._host, event.receptionID, event.ID);
    url = appendToken(url, this._token);

    String data = JSON.encode(event);
    return this._backend.put(url, data).then((String response) =>
        new Model.CalendarEntry.fromMap(JSON.decode(response)));
  }

  /**
   *
   */
  @deprecated
  Future calendarEventRemove(Model.CalendarEntry event) {
    Uri url = Resource.Reception.calendarEvent(
        this._host, event.receptionID, event.ID);
    url = appendToken(url, this._token);

    return this._backend.delete(url);
  }

  /**
   *
   */
  @deprecated
  Future<Iterable<Model.CalendarEntryChange>> calendarEntryChanges(entryID) {
    Uri url = Resource.Reception.calendarEventChanges(this._host, entryID);
    url = appendToken(url, this._token);

    return this._backend.get(url).then(JSON.decode).then((Iterable<Map> maps) =>
        maps.map((Map map) => new Model.CalendarEntryChange.fromMap(map)));
  }

  /**
   *
   */
  @deprecated
  Future<Model.CalendarEntryChange> calendarEntryLatestChange(entryID) {
    Uri url = Resource.Reception.calendarEventLatestChange(this._host, entryID);
    url = appendToken(url, this._token);

    return this._backend
        .get(url)
        .then(JSON.decode)
        .then((Map map) => new Model.CalendarEntryChange.fromMap(map));
  }

  /**
   * Returns a reception as a pure map.
   */
  Future<Model.Reception> create(Model.Reception reception) {
    Uri url = Resource.Reception.root(this._host);
    url = appendToken(url, this._token);

    String data = JSON.encode(reception.asMap);

    return this._backend.post(url, data).then((String response) =>
        new Model.Reception.fromMap(JSON.decode(response)));
  }

  /**
   *
   */
  Future<Model.Reception> get(int receptionID) {
    Uri url = Resource.Reception.single(this._host, receptionID);
    url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        new Model.Reception.fromMap(JSON.decode(response)));
  }

  /**
   *
   */
  Future<Model.Reception> getByExtension(String extension) {
    Uri url = Resource.Reception.byExtension(this._host, extension);
    url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        new Model.Reception.fromMap(JSON.decode(response)));
  }

  /**
   * Returns a reception list.
   */
  Future<Iterable<Model.Reception>> list() {
    Uri url = Resource.Reception.list(this._host);
    url = appendToken(url, this._token);

    return this._backend.get(url).then(
        (String response) => (JSON.decode(response) as Iterable)
            .map((Map map) => new Model.Reception.fromMap(map)));
  }

  /**
   *
   */
  Future remove(int receptionID) {
    Uri url = Resource.Reception.single(this._host, receptionID);
    url = appendToken(url, this._token);

    return this._backend.delete(url).then(JSON.decode);
  }

  /**
   *
   */
  Future<Model.Reception> save(Model.Reception reception) {
    if (reception.ID != null && reception.ID != Model.Reception.noID) {
      return this.update(reception);
    } else {
      return this.create(reception);
    }
  }

  /**
   *
   */
  Future<Model.Reception> update(Model.Reception reception) {
    Uri url = Resource.Reception.single(this._host, reception.ID);
    url = appendToken(url, this._token);

    String data = JSON.encode(reception.asMap);

    return this._backend.put(url, data).then((String response) =>
        new Model.Reception.fromMap(JSON.decode(response)));
  }
}
