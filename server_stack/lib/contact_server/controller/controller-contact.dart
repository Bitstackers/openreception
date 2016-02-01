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

class Contact {
  final Logger _log = new Logger('$_libraryName.Contact');
  final database.Contact _contactDB;
  final service.NotificationService _notification;

  Contact(this._contactDB, this._notification);

  /**
   * Retrives a single base contact based on contactID.
   */
  Future base(shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));

    return _contactDB
        .get(contactID)
        .then((model.BaseContact contact) =>
            new shelf.Response.ok(JSON.encode(contact)))
        .catchError((error, stacktrace) {
      if (error is storage.NotFound) {
        return new shelf.Response.notFound('$error');
      }

      _log.severe(error, stacktrace);
      return new shelf.Response.internalServerError(
          body: 'contactserver.router._fetchAndCacheContact() ${error}');
    });
  }

  /**
   * Creates a new base contact.
   */
  Future create(shelf.Request request) {
    return request.readAsString().then((String content) {
      model.BaseContact contact;

      try {
        Map data = JSON.decode(content);
        contact = new model.BaseContact.fromMap(data);
      } catch (error) {
        Map response = {
          'status': 'bad request',
          'description': 'passed contact argument '
              'is too long, missing or invalid',
          'error': error.toString()
        };
        return new shelf.Response(400, body: JSON.encode(response));
      }

      return _contactDB
          .create(contact)
          .then((model.BaseContact createdContact) {
        event.ContactChange changeEvent = new event.ContactChange(
            createdContact.id, event.ContactState.CREATED);

        _notification.broadcastEvent(changeEvent);

        return new shelf.Response.ok(JSON.encode(contact));
      }).catchError((error, stackTrace) {
        _log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(
            body: 'Failed to update event in database');
      });
    });
  }

  /**
   * Retrives a single base contact based on contactID.
   */
  Future listBase(shelf.Request request) {
    return _contactDB
        .list()
        .then((Iterable<model.BaseContact> contacts) => new shelf.Response.ok(
            JSON.encode(contacts.toList(growable: false))))
        .catchError((error, stacktrace) {
      _log.severe(error, stacktrace);
      return new shelf.Response.internalServerError(
          body: 'contactserver.router._fetchAndCacheContact() ${error}');
    });
  }

  /**
   * Retrives a list of base contacts associated with the provided
   * organization id.
   */
  Future listByOrganization(shelf.Request request) {
    int organizationID =
        int.parse(shelf_route.getPathParameter(request, 'oid'));

    return _contactDB
        .organizationContacts(organizationID)
        .then((Iterable<model.BaseContact> contacts) => new shelf.Response.ok(
            JSON.encode(contacts.toList(growable: false))))
        .catchError((error, stacktrace) {
      _log.severe(error, stacktrace);
      return new shelf.Response.internalServerError(
          body: 'contactserver.router._fetchAndCacheContact() ${error}');
    });
  }

  /**
   * Retrives a single contact based on receptionID and contactID.
   */
  Future get(shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return _contactDB
        .getByReception(receptionID, contactID)
        .then((model.Contact contact) {
      if (contact == model.Contact.noContact) {
        return new shelf.Response.notFound(
            {'description': 'no contact $contactID@$receptionID'});
      } else {
        return new shelf.Response.ok(JSON.encode(contact.asMap));
      }
    }).catchError((error, stacktrace) {
      _log.severe(error, stacktrace);
      new shelf.Response.internalServerError(
          body: 'contactserver.router._fetchAndCacheContact() ${error}');
    });
  }

  /**
   * Returns the id's of all organizations that a contact is associated to.
   */
  Future<int> organizations(shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));

    return _contactDB
        .organizations(contactID)
        .then((Iterable<int> organizationsIds) {
      return new shelf.Response.ok(JSON.encode(organizationsIds.toList()));
    }).catchError((error, stacktrace) {
      _log.severe(error, stacktrace);
      new shelf.Response.internalServerError(
          body: 'contactserver.router._fetchAndCacheContact() ${error}');
    });
  }

  /**
   * Returns the id's of all receptions that a contact is associated to.
   */
  Future<int> receptions(shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));

    return _contactDB.receptions(contactID).then((Iterable<int> receptionIDs) {
      return new shelf.Response.ok(JSON.encode(receptionIDs.toList()));
    }).catchError((error, stacktrace) {
      _log.severe(error, stacktrace);
      new shelf.Response.internalServerError(
          body: 'contactserver.router._fetchAndCacheContact() ${error}');
    });
  }

  /**
   * Removes a single contact from the data store.
   */
  Future remove(shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));

    return _contactDB.remove(contactID).then((_) {
      event.ContactChange changeEvent =
          new event.ContactChange(contactID, event.ContactState.DELETED);

      _notification.broadcastEvent(changeEvent);

      return new shelf.Response.ok(
          JSON.encode({'status': 'ok', 'description': 'Contact deleted'}));
    }).catchError((error, stackTrace) {
      if (error is storage.NotFound) {
        return new shelf.Response.notFound(JSON
            .encode({'description': 'No contact found with ID $contactID'}));
      }
      _log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(
          body: 'Failed to execute database query');
    });
  }

  /**
   * Update the base information of a contact
   */
  Future update(shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));

    return request.readAsString().then((String content) {
      model.BaseContact contact;

      try {
        Map data = JSON.decode(content);
        contact = new model.BaseContact.fromMap(data);
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
        event.ContactChange changeEvent =
            new event.ContactChange(contactID, event.ContactState.UPDATED);

        _notification.broadcastEvent(changeEvent);

        return new shelf.Response.ok(JSON.encode(contact));
      }).catchError((error, stackTrace) {
        if (error is storage.NotFound) {
          return new shelf.Response.notFound(
              'Contact with id $contactID not found');
        }

        _log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(
            body: 'Failed to update event in database');
      });
    });
  }

  /**
   * Gives a lists of every contact in an reception.
   */
  Future listByReception(shelf.Request request) async {
    final String rid = shelf_route.getPathParameter(request, 'rid');
    final int receptionID = int.parse(rid);

    try {
      Iterable<model.Contact> contacts =
          await _contactDB.listByReception(receptionID);

      return _okJson(contacts.toList());
    } on storage.SqlError catch (error) {
      new shelf.Response.internalServerError(body: error);
    }
  }

  /**
   *
   */
  Future addToReception(shelf.Request request) {
    int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return request.readAsString().then((String content) {
      model.Contact contact;

      try {
        Map data = JSON.decode(content);
        contact = new model.Contact.fromMap(data);
      } catch (error) {
        Map response = {
          'status': 'bad request',
          'description': 'passed contact argument '
              'is too long, missing or invalid',
          'error': error.toString()
        };
        return new shelf.Response(400, body: JSON.encode(response));
      }

      return _contactDB
          .addToReception(contact, rid)
          .then((model.Contact createdContact) {
        event.ContactChange changeEvent = new event.ContactChange(
            createdContact.ID, event.ContactState.UPDATED);

        _notification.broadcastEvent(changeEvent);

        return new shelf.Response.ok(JSON.encode(contact));
      }).catchError((error, stackTrace) {
        _log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(
            body: 'Failed to update event in database');
      });
    });
  }

  /**
   *
   */
  Future updateInReception(shelf.Request request) {
    int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return request.readAsString().then((String content) {
      model.Contact contact;

      try {
        Map data = JSON.decode(content);
        contact = new model.Contact.fromMap(data);
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

      return _contactDB
          .updateInReception(contact)
          .then((model.Contact createdContact) {
        event.ContactChange changeEvent =
            new event.ContactChange(contact.ID, event.ContactState.UPDATED);

        _notification.broadcastEvent(changeEvent);

        return new shelf.Response.ok(JSON.encode(contact));
      }).catchError((error, stackTrace) {
        _log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(
            body: 'Failed to update event in database');
      });
    });
  }

  /**
   *
   */
  Future removeFromReception(shelf.Request request) {
    int cid = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return _contactDB.removeFromReception(cid, rid).then((_) {
      event.ContactChange changeEvent =
          new event.ContactChange(cid, event.ContactState.UPDATED);

      _notification.broadcastEvent(changeEvent);

      return new shelf.Response.ok(JSON.encode(const {}));
    }).catchError((error, stackTrace) {
      _log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(
          body: 'Failed to update event in database');
    });
  }
}
