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

part of openreception.cdr_server.controller;

class Cdr {
  final database.Cdr _cdrStore;
  final Logger _log = new Logger('cdr_server.controller.cdr');

  Cdr(this._cdrStore);

  /**
   *
   */
  Future<shelf.Response> list(shelf.Request request) async {
    if (!shelf_route.getPathParameters(request).containsKey('date_from')) {
      return _clientError('Missing parameter: date_from');
    }

    if (!shelf_route.getPathParameters(request).containsKey('date_to')) {
      return _clientError('Missing parameter: date_to');
    }

    DateTime start, end;
    try {
      start = util.unixTimestampToDateTime(
          int.parse(shelf_route.getPathParameter(request, 'date_from')));
      end = util.unixTimestampToDateTime(
          int.parse(shelf_route.getPathParameter(request, 'date_to')));
    } catch (error, stackTrace) {
      _log.warning('Bad client request', error, stackTrace);
      return _clientError('Bad parameter: ${error}');
    }

    final bool inbound = shelf_route
            .getPathParameters(request)
            .containsKey('inbound')
        ? shelf_route.getPathParameter(request, 'inbound') == 'true'
        : false;

    return _cdrStore.list(inbound, start, end).then(
        (List orgs) => _okJson({'cdr_stats': orgs.toList(growable: false)}));
  }

  /**
   *
   */
  Future<shelf.Response> createCheckpoint(shelf.Request request) async {
    model.CDRCheckpoint checkpoint;

    try {
      checkpoint = await request
          .readAsString()
          .then(JSON.decode)
          .then((map) => new model.CDRCheckpoint.fromMap(map));
    } catch (error, stackTrace) {
      _log.warning('Failed to process body', error, stackTrace);
      return _clientError('Failed to process body');
    }

    return _cdrStore.createCheckpoint(checkpoint).then((_) => _okJson({}));
  }

  /**
   *
   */
  Future<shelf.Response> checkpoints(shelf.Request request) =>
      _cdrStore.checkpointList().then((checkpoints) =>
          _okJson({'checkpoints': checkpoints.toList(growable: false)}));

  /**
   *
   */
  Future<shelf.Response> addCdrEntry(shelf.Request request) async {
    model.FreeSWITCHCDREntry entry;

    try {
      entry = await request
          .readAsString()
          .then(JSON.decode)
          .then((map) => new model.FreeSWITCHCDREntry.fromJson(map));
    } catch (error, stackTrace) {
      _log.warning('Failed to process body', error, stackTrace);
      return _clientError('Failed to process body');
    }

    return _cdrStore.create(entry).then((_) => _okJson({}));
  }
}
