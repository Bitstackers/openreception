part of contactserver.router;

abstract class Contact {

  static final Logger log = new Logger('$libraryName.Contact');

  /**
   * Retrives a single base contact based on contactID.
   */
  static Future base(shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));

    return _contactDB
        .get(contactID)
        .then((Model.BaseContact contact) =>
            new shelf.Response.ok(JSON.encode(contact)))
        .catchError((error, stacktrace) {

      if (error is Storage.NotFound) {
        return new shelf.Response.notFound('$error');

      }

      log.severe(error, stacktrace);
      return new shelf.Response.internalServerError(
          body: 'contactserver.router._fetchAndCacheContact() ${error}');
    });
  }

  /**
   * Creates a new base contact.
   */
  static Future create(shelf.Request request) {
    return request.readAsString().then((String content) {
      Model.BaseContact contact;

      try {
        Map data = JSON.decode(content);
        contact = new Model.BaseContact.fromMap(data);
      } catch (error) {
        Map response = {
          'status': 'bad request',
          'description': 'passed contact argument '
              'is too long, missing or invalid',
          'error': error.toString()
        };
        return new shelf.Response(400, body: JSON.encode(response));
      }

      return _contactDB.create(contact).then((Model.BaseContact createdContact) {
        Event.ContactChange changeEvent =
            new Event.ContactChange(createdContact.id, Event.ContactState.CREATED);

        Notification.broadcastEvent(changeEvent);

        return new shelf.Response.ok(JSON.encode(contact));
      }).catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(
            body: 'Failed to update event in database');
      });
    });
  }


  /**
   * Retrives a single base contact based on contactID.
   */
  static Future listBase(shelf.Request request) {
    return _contactDB
        .list()
        .then((Iterable<Model.BaseContact> contacts) => new shelf.Response.ok(
            JSON.encode(contacts.toList(growable: false))))
        .catchError((error, stacktrace) {
      log.severe(error, stacktrace);
      return new shelf.Response.internalServerError(
          body: 'contactserver.router._fetchAndCacheContact() ${error}');
    });
  }

  /**
   * Retrives a list of base contacts associated with the provided
   * organization id.
   */
  static Future listByOrganization(shelf.Request request) {
    int organizationID =
        int.parse(shelf_route.getPathParameter(request, 'oid'));

    return _contactDB
        .organizationContacts(organizationID)
        .then((Iterable<Model.BaseContact> contacts) => new shelf.Response.ok(
            JSON.encode(contacts.toList(growable: false))))
        .catchError((error, stacktrace) {
      log.severe(error, stacktrace);
      return new shelf.Response.internalServerError(
          body: 'contactserver.router._fetchAndCacheContact() ${error}');
    });
  }

  /**
   * Retrives a single contact based on receptionID and contactID.
   */
  static Future get(shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return _contactDB.getByReception(receptionID, contactID).then((Model.Contact contact) {
      if (contact == Model.Contact.noContact) {
        return new shelf.Response.notFound(
            {'description': 'no contact $contactID@$receptionID'});
      } else {
        return new shelf.Response.ok(JSON.encode(contact.asMap));
      }
    }).catchError((error, stacktrace) {
      log.severe(error, stacktrace);
      new shelf.Response.internalServerError(
          body: 'contactserver.router._fetchAndCacheContact() ${error}');
    });
  }

  /**
   * Returns the id's of all organizations that a contact is associated to.
   */
  static Future<int> organizations(shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));

    return _contactDB.organizations(contactID).then((Iterable<int> organizationsIds) {
      return new shelf.Response.ok(JSON.encode(organizationsIds.toList()));
    }).catchError((error, stacktrace) {
      log.severe(error, stacktrace);
      new shelf.Response.internalServerError(
          body: 'contactserver.router._fetchAndCacheContact() ${error}');
    });
  }

  /**
   * Returns the id's of all receptions that a contact is associated to.
   */
  static Future<int> receptions(shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));

    return _contactDB.receptions(contactID).then((Iterable<int> receptionIDs) {
      return new shelf.Response.ok(JSON.encode(receptionIDs.toList()));
    }).catchError((error, stacktrace) {
      log.severe(error, stacktrace);
      new shelf.Response.internalServerError(
          body: 'contactserver.router._fetchAndCacheContact() ${error}');
    });
  }

  /**
   * Removes a single contact from the data store.
   */
  static Future remove(shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));

    return _contactDB.remove(contactID).then((_) {
      Event.ContactChange changeEvent =
          new Event.ContactChange(contactID, Event.ContactState.DELETED);

      Notification.broadcastEvent(changeEvent);

      return new shelf.Response.ok(
          JSON.encode({'status': 'ok', 'description': 'Contact deleted'}));
    }).catchError((error, stackTrace) {
      if (error is Storage.NotFound) {
        return new shelf.Response.notFound(JSON
            .encode({'description': 'No contact found with ID $contactID'}));
      }
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(
          body: 'Failed to execute database query');
    });
  }

  /**
   * Update the base information of a contact
   */
  static Future update(shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));

    return request.readAsString().then((String content) {
      Model.BaseContact contact;

      try {
        Map data = JSON.decode(content);
        contact = new Model.BaseContact.fromMap(data);
      } catch (error) {
        Map response = {
          'status': 'bad request',
          'description': 'passed contact argument '
              'is too long, missing or invalid',
          'error': error.toString()
        };
        return new shelf.Response(400, body: JSON.encode(response));
      }

      return _contactDB.update(contact).then((_) {
        Event.ContactChange changeEvent =
            new Event.ContactChange(contactID, Event.ContactState.UPDATED);

        Notification.broadcastEvent(changeEvent);

        return new shelf.Response.ok(JSON.encode(contact));
      }).catchError((error, stackTrace) {
        if (error is Storage.NotFound) {
          return new shelf.Response.notFound(
              'Contact with id $contactID not found');
        }

        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(
            body: 'Failed to update event in database');
      });
    });
  }

  /**
   * Gives a lists of every contact in an reception.
   */
  static Future listByReception(shelf.Request request) {
    var rid = shelf_route.getPathParameter(request, 'rid');
    int receptionID = int.parse(rid);

    return _contactDB
        .listByReception(receptionID)
        .then((Iterable<Model.Contact> contacts) {
      return new shelf.Response.ok(JSON.encode(contacts.toList()));
    }).catchError((error) {}).catchError((error, stacktrace) {
      log.severe(error, stacktrace);
      new shelf.Response.internalServerError(body: '${error}');
    });
  }

  /**
   *
   */
  static Future addToReception(shelf.Request request) {
    int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return request.readAsString().then((String content) {
      Model.Contact contact;

      try {
        Map data = JSON.decode(content);
        contact = new Model.Contact.fromMap(data);
      } catch (error) {
        Map response = {
          'status': 'bad request',
          'description': 'passed contact argument '
              'is too long, missing or invalid',
          'error': error.toString()
        };
        return new shelf.Response(400, body: JSON.encode(response));
      }

      return _contactDB.addToReception(contact, rid)
        .then((Model.Contact createdContact) {
        Event.ContactChange changeEvent =
            new Event.ContactChange(createdContact.ID, Event.ContactState.UPDATED);

        Notification.broadcastEvent(changeEvent);

        return new shelf.Response.ok(JSON.encode(contact));
      }).catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(
            body: 'Failed to update event in database');
      });
    });
  }

  /**
   *
   */
  static Future updateInReception(shelf.Request request) {
    int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return request.readAsString().then((String content) {
      Model.Contact contact;

      try {
        Map data = JSON.decode(content);
        contact = new Model.Contact.fromMap(data);
        contact.receptionID = rid;
      } catch (error) {
        Map response = {
          'status': 'bad request',
          'description': 'passed contact argument '
              'is too long, missing or invalid',
          'error': error.toString()
        };
        return new shelf.Response(400, body: JSON.encode(response));
      }

      return _contactDB.updateInReception(contact).then((Model.Contact createdContact) {
        Event.ContactChange changeEvent =
            new Event.ContactChange(contact.ID, Event.ContactState.UPDATED);

        Notification.broadcastEvent(changeEvent);

        return new shelf.Response.ok(JSON.encode(contact));
      }).catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(
            body: 'Failed to update event in database');
      });
    });
  }

  /**
   *
   */
  static Future removeFromReception(shelf.Request request) {
    int cid = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return _contactDB.removeFromReception(cid, rid)
      .then((_) {
        Event.ContactChange changeEvent =
            new Event.ContactChange(cid, Event.ContactState.UPDATED);

        Notification.broadcastEvent(changeEvent);

        return new shelf.Response.ok(JSON.encode(const {}));
      }).catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(
            body: 'Failed to update event in database');
      });
   }
}
