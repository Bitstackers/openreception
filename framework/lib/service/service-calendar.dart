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

part of openreception.framework.service;

/**
 * Client for contact service.
 */
class RESTCalendarStore implements storage.Calendar {
  static final Logger log = new Logger('${libraryName}.RESTCalendarStore');

  final WebService _backend;
  final Uri _host;
  final String _token;

  /**
   *
   */
  RESTCalendarStore(Uri this._host, String this._token, this._backend);

  /**
   *
   */
  Future<Iterable<model.CalendarEntry>> list(model.Owner owner) {
    Uri url = resource.Calendar.ownerBase(_host, owner);

    url = _appendToken(url, this._token);

    Iterable<model.CalendarEntry> convertMaps(Iterable<Map> maps) =>
        maps.map(model.CalendarEntry.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }

  /**
   *
   */
  Future<model.CalendarEntry> get(int id, model.Owner owner) {
    Uri url = resource.Calendar.single(_host, id, owner);
    url = _appendToken(url, this._token);

    return this
        ._backend
        .get(url)
        .then(JSON.decode)
        .then(model.CalendarEntry.decode);
  }

  /**
   *
   */
  Future<model.CalendarEntry> create(
      model.CalendarEntry entry, model.Owner owner, model.User user) {
    Uri url = resource.Calendar.ownerBase(_host, owner);
    url = _appendToken(url, this._token);

    return this
        ._backend
        .post(url, JSON.encode(entry))
        .then(JSON.decode)
        .then(model.CalendarEntry.decode);
  }

  /**
   *
   */
  Future<model.CalendarEntry> update(
      model.CalendarEntry entry, model.Owner owner, model.User modifier) {
    Uri url = resource.Calendar.single(_host, entry.id, owner);
    url = _appendToken(url, this._token);

    return _backend
        .put(url, JSON.encode(entry))
        .then(JSON.decode)
        .then(model.CalendarEntry.decode);
  }

  /**
   *
   */
  Future remove(int eid, model.Owner owner, model.User user) {
    Uri url = resource.Calendar.single(_host, eid, owner);
    url = _appendToken(url, this._token);

    return this._backend.delete(url);
  }

  /**
   *
   */
  Future<Iterable<model.Commit>> changes(model.Owner owner, [int eid]) {
    Uri url = resource.Calendar.changeList(_host, owner, eid);
    url = _appendToken(url, this._token);

    Iterable<model.Commit> convertMaps(Iterable<Map> maps) =>
        maps.map(model.Commit.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }

  /**
   *
   */
  Future<String> changelog(model.Owner owner) {
    Uri url = resource.Calendar.changelog(_host, owner);
    url = _appendToken(url, this._token);

    return _backend.get(url);
  }
}
