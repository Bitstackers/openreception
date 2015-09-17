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

abstract class Phone {

  /**
   *
   */
  static shelf.Response add(shelf.Request request) =>
      new shelf.Response.internalServerError(
          body: 'Not implemented');

  /**
   *
   */
  static shelf.Response remove(shelf.Request request) =>
      new shelf.Response.internalServerError(
          body: 'Not implemented');

  /**
   *
   */
  static shelf.Response update(shelf.Request request) =>
      new shelf.Response.internalServerError(
          body: 'Not implemented');

  /**
   *
   */
  static Future<shelf.Response> ofContact(shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return _contactDB
        .phones(contactID, receptionID)
        .then((Iterable<Model.PhoneNumber> phones) {
      return new shelf.Response.ok(JSON.encode(phones.toList()));
    }).catchError((error, stacktrace) {
      log.severe(error, stacktrace);
      new shelf.Response.internalServerError(body: '${error}');
    });
  }
}