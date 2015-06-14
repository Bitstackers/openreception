part of receptionserver.router;

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

        Notification.broadcastEvent(changeEvent);

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

        Notification.broadcastEvent(changeEvent);

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

      Notification.broadcastEvent(changeEvent);

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