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

part of openreception.reception_server.router;

abstract class Reception {

  static final Logger log = new Logger ('$libraryName.Reception');

  static Future<shelf.Response> list(shelf.Request request) {
    return _receptionDB.list().then((Iterable<Model.Reception> receptions) {
      return new shelf.Response.ok(JSON.encode(receptions.toList(growable : false)));
    })
    .catchError((error, stackTrace) {
      log.severe (error, stackTrace);
      return new shelf.Response.internalServerError (body : 'reception listing failed: $error');
    });
  }


  static Future<shelf.Response> getByExtension(shelf.Request request) {
    String extension = shelf_route.getPathParameter(request, 'exten');

    return _receptionDB.getByExtension(extension)
      .then((Model.Reception reception) {
        return new shelf.Response.ok (JSON.encode(reception));
      })
      .catchError((error, stackTrace) {
      if(error is Storage.NotFound) {
        return new shelf.Response.notFound
        (JSON.encode({'description' : 'No reception '
          'found on extension extension'}));
        }

      log.severe (error, stackTrace);
        return new shelf.Response.internalServerError
          (body : 'receptionserver.router.getReception: $error');
      });
  }

  static Future<shelf.Response> extensionOf(shelf.Request request) {
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return _receptionDB.get(receptionID)
      .then((Model.Reception reception) {
        return new shelf.Response.ok (reception.extension);
      })
      .catchError((error, stackTrace) {
      if(error is Storage.NotFound) {
        return new shelf.Response.notFound
        (JSON.encode({'description' : 'No reception '
          'found with ID $receptionID'}));
        }

      log.severe (error, stackTrace);
        return new shelf.Response.internalServerError
          (body : 'receptionserver.router.getReception: $error');
      });
  }

  static Future<shelf.Response> get(shelf.Request request) {
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return _receptionDB.get(receptionID)
      .then((Model.Reception reception) {
        return new shelf.Response.ok (JSON.encode(reception));
      })
      .catchError((error, stackTrace) {
      if(error is Storage.NotFound) {
        return new shelf.Response.notFound
        (JSON.encode({'description' : 'No reception '
          'found with ID $receptionID'}));
        }

      log.severe (error, stackTrace);
        return new shelf.Response.internalServerError
          (body : 'receptionserver.router.getReception: $error');
      });
  }

  /**
   * shelf request handler for creating a new reception.
   */
  static Future create(shelf.Request request) {
    return request.readAsString().then((String content) {
      Model.Reception reception;

      try {
        reception = new Model.Reception.fromMap(JSON.decode(content));
      } catch (error) {
        Map response = {
          'status': 'bad request',
          'description': 'passed reception argument '
              'is too long, missing or invalid',
          'error': error.toString()
        };
        return new shelf.Response(400, body: JSON.encode(response));
      }

      return _receptionDB.create(reception).then((Model.Reception createdReception) {
        Event.ReceptionChange changeEvent =
            new Event.ReceptionChange(createdReception.ID,
                Event.ReceptionState.CREATED);

        _notification.broadcastEvent(changeEvent);

        return new shelf.Response.ok(JSON.encode(createdReception));
      }).catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(
            body: 'Failed to update reception in database');
      });
    });
  }

  /**
   * Update a reception.
   */
  static Future update(shelf.Request request) {
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'oid'));

    return request.readAsString().then((String content) {
      Model.Reception reception;

      try {
        reception = new Model.Reception.fromMap(JSON.decode(content));
      } catch (error) {
        Map response = {
          'status': 'bad request',
          'description': 'passed reception argument '
              'is too long, missing or invalid',
          'error': error.toString()
        };
        return new shelf.Response(400, body: JSON.encode(response));
      }

      return _receptionDB.update(reception).then((_) {
        Event.ReceptionChange changeEvent =
            new Event.ReceptionChange(receptionID, Event.ReceptionState.UPDATED);

        _notification.broadcastEvent(changeEvent);

        return new shelf.Response.ok(JSON.encode(reception));
      }).catchError((error, stackTrace) {
        if (error is Storage.NotFound) {
          return new shelf.Response.notFound(
              'Reception with id $receptionID not found');
        }

        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(
            body: 'Failed to update event in database');
      });
    });
  }

  /**
   * Removes a single reception from the data store.
   */
  static Future remove(shelf.Request request) {
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'oid'));

    return _receptionDB.remove(receptionID).then((_) {
      Event.ReceptionChange changeEvent =
          new Event.ReceptionChange(receptionID, Event.ReceptionState.DELETED);

      _notification.broadcastEvent(changeEvent);

      return new shelf.Response.ok(
          JSON.encode({'status': 'ok', 'description': 'Reception deleted'}));
    }).catchError((error, stackTrace) {
      if (error is Storage.NotFound) {
        return new shelf.Response.notFound(JSON
            .encode({'description': 'No reception found with ID $receptionID'}));
      }
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(
          body: 'Failed to execute database query');
    });
  }
}