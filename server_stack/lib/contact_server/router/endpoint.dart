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

part of openreception.contact_server.router;

abstract class Endpoint {

  /**
   *
   */
  static Future<shelf.Response> create(shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return request.readAsString()
      .then(JSON.decode)
      .then(Model.MessageEndpoint.decode)
      .then((Model.MessageEndpoint ep) =>
        _endpointDB.create(receptionID, contactID, ep)
          .then(JSON.encode)
          .then((String encodedString) =>
              new shelf.Response.ok(encodedString)))
      .catchError((error, stacktrace) {
        log.severe(error, stacktrace);
        new shelf.Response.internalServerError(body: '${error}');
    });
  }

  /**
   *
   */
  static Future<shelf.Response>  remove(shelf.Request request) {
    int eid = int.parse(shelf_route.getPathParameter(request, 'eid'));

    return _endpointDB.remove(eid).then((_) =>
        new shelf.Response.ok(JSON.encode(const {})))
      .catchError((error, stacktrace) {
        log.severe(error, stacktrace);
        new shelf.Response.internalServerError(body: '${error}');
    });
  }

  /**
   *
   */
  static Future<shelf.Response>  update(shelf.Request request) =>
      request.readAsString()
        .then(JSON.decode)
        .then(Model.MessageEndpoint.decode)
        .then((Model.MessageEndpoint ep) =>
          _endpointDB.update(ep)
            .then(JSON.encode)
            .then((String encodedString) =>
                new shelf.Response.ok(encodedString)))
        .catchError((error, stacktrace) {
          log.severe(error, stacktrace);
          new shelf.Response.internalServerError(body: '${error}');
      });

  /**
   *
   */
  static Future<Iterable<shelf.Response>> ofContact(shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return _endpointDB
        .list(receptionID, contactID)
        .then((Iterable<Model.MessageEndpoint> endpoints) {
      return new shelf.Response.ok(JSON.encode(endpoints.toList()));
    }).catchError((error, stacktrace) {
      log.severe(error, stacktrace);
      new shelf.Response.internalServerError(body: '${error}');
    });
  }
}