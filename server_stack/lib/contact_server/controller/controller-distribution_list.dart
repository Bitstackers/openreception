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

part of openreception.contact_server.controller;

class DistributionList {
  final Logger _log = new Logger('$_libraryName.DistributionList');

  final database.DistributionList _dlistDB;

  DistributionList(this._dlistDB);

  /**
   *
   */
  Future<shelf.Response> addRecipient(shelf.Request request) {
    int cid = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return request
        .readAsString()
        .then(JSON.decode)
        .then(model.DistributionListEntry.decode)
        .then((model.DistributionListEntry rcp) => _dlistDB
            .addRecipient(rid, cid, rcp)
            .then(JSON.encode)
            .then(
                (String encodedString) => new shelf.Response.ok(encodedString)))
        .catchError((error, stacktrace) {
      _log.severe(error, stacktrace);
      new shelf.Response.internalServerError(body: '${error}');
    });
  }

  /**
   *
   */
  Future<shelf.Response> removeRecipient(shelf.Request request) {
    int did = int.parse(shelf_route.getPathParameter(request, 'did'));

    return _dlistDB
        .removeRecipient(did)
        .then((_) => new shelf.Response.ok(JSON.encode(const {})))
        .catchError((error, stacktrace) {
      _log.severe(error, stacktrace);
      new shelf.Response.internalServerError(body: '${error}');
    });
  }

  /**
   *
   */
  Future<Iterable<shelf.Response>> ofContact(shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return _dlistDB
        .list(receptionID, contactID)
        .then((model.DistributionList dlist) {
      return new shelf.Response.ok(JSON.encode(dlist));
    }).catchError((error, stacktrace) {
      _log.severe(error, stacktrace);
      new shelf.Response.internalServerError(body: '${error}');
    });
  }
}
