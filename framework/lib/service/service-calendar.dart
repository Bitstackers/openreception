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
class RESTCalendarStore implements Storage.Calendar {
  static final Logger log = new Logger('${libraryName}.RESTCalendarStore');

  WebService _backend = null;
  final Uri _host;
  String _token = '';

  /**
   *
   */
  RESTCalendarStore(Uri this._host, String this._token, this._backend);

  /**
   *
   */
  Future<Iterable<Model.CalendarEntry>> list(Model.Owner owner) {
    Uri url = Resource.Calendar.ownerBase(_host, owner);

    url = _appendToken(url, this._token);

    Iterable<Model.CalendarEntry> convertMaps(Iterable<Map> maps) =>
        maps.map(Model.CalendarEntry.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }

  /**
   *
   */
  Future<Model.CalendarEntry> get(int id, Model.Owner owner) {
    Uri url = Resource.Calendar.single(_host, id, owner);
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
      Model.CalendarEntry entry, Model.Owner owner, Model.User user) {
    Uri url = Resource.Calendar.ownerBase(_host, owner);
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
      Model.CalendarEntry entry, Model.Owner owner, Model.User modifier) {
    Uri url = Resource.Calendar.single(_host, entry.id, owner);
    url = _appendToken(url, this._token);

    return _backend
        .put(url, JSON.encode(entry))
        .then(JSON.decode)
        .then(Model.CalendarEntry.decode);
  }

  /**
   *
   */
  Future remove(int eid, Model.Owner owner, Model.User user) {
    Uri url = Resource.Calendar.single(_host, eid, owner);
    url = _appendToken(url, this._token);

    return this._backend.delete(url);
  }

  /**
   *
   */
  Future<Iterable<Model.Commit>> changes(Model.Owner owner, [int eid]) {
    Uri url = Resource.Calendar.changeList(_host, owner, eid);
    url = _appendToken(url, this._token);

    Iterable<Model.Commit> convertMaps(Iterable<Map> maps) =>
        maps.map(Model.Commit.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }
}
