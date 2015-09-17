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

abstract class Organization {

  static final Logger log = new Logger ('$libraryName.Organization');

  static Future<shelf.Response> list(shelf.Request request) =>
    _organizationDB.list()
      .then((Iterable<Model.Organization> organizations) =>
        new shelf.Response.ok
          (JSON.encode(organizations.toList(growable : false))));

  static Future<shelf.Response> get(shelf.Request request) {
    int organizationID = int.parse(shelf_route.getPathParameter(request, 'oid'));

    return _organizationDB.get(organizationID)
      .then((Model.Organization organization) =>
        new shelf.Response.ok (JSON.encode(organization)))

      .catchError((error, stackTrace) {
        if(error is Storage.NotFound) {
          return new shelf.Response.notFound
          (JSON.encode({'description' : 'No organization '
           'found with ID $organizationID'}));
        }

        log.severe (error, stackTrace);
          return new shelf.Response.internalServerError
            (body : 'receptionserver.router.getReception: $error');
      });
  }

  /**
   * shelf request handler for listing every contact associated with the
   * organization.
   */
  static Future contacts(shelf.Request request) {
    int organizationID = int.parse(shelf_route.getPathParameter(request, 'oid'));

    return _organizationDB.contacts(organizationID)
      .then((Iterable<Model.BaseContact> contacts) =>
        new shelf.Response.ok
          (JSON.encode(contacts.toList(growable : false))));
  }

  /**
   * shelf request handler for listing every reception associated with the
   * organization.
   */
  static Future receptions(shelf.Request request) {
    int organizationID = int.parse(shelf_route.getPathParameter(request, 'oid'));

    return _organizationDB.receptions(organizationID)
      .then((Iterable<int> receptionIDs) =>
        new shelf.Response.ok
          (JSON.encode(receptionIDs.toList(growable : false))));
  }

  /**
   * shelf request handler for creating a new organization.
   */
  static Future create(shelf.Request request) {
    return request.readAsString().then((String content) {
      Model.Organization organization;

      try {
        organization = new Model.Organization.fromMap(JSON.decode(content));
      } catch (error) {
        Map response = {
          'status': 'bad request',
          'description': 'passed organization argument '
              'is too long, missing or invalid',
          'error': error.toString()
        };
        return new shelf.Response(400, body: JSON.encode(response));
      }

      return _organizationDB.create(organization).then((Model.Organization createdOrganization) {
        Event.OrganizationChange changeEvent =
            new Event.OrganizationChange(createdOrganization.id,
                Event.OrganizationState.CREATED);

        Notification.broadcastEvent(changeEvent);

        return new shelf.Response.ok(JSON.encode(createdOrganization));
      }).catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(
            body: 'Failed to update organization in database');
      });
    });
  }

  /**
   * Update an organization.
   */
  static Future update(shelf.Request request) {
    int organizationID = int.parse(shelf_route.getPathParameter(request, 'oid'));

    return request.readAsString().then((String content) {
      Model.Organization organization;

      try {
        organization = new Model.Organization.fromMap(JSON.decode(content));
      } catch (error) {
        Map response = {
          'status': 'bad request',
          'description': 'passed organization argument '
              'is too long, missing or invalid',
          'error': error.toString()
        };
        return new shelf.Response(400, body: JSON.encode(response));
      }

      return _organizationDB.update(organization).then((_) {
        Event.OrganizationChange changeEvent =
            new Event.OrganizationChange(organizationID, Event.OrganizationState.UPDATED);

        Notification.broadcastEvent(changeEvent);

        return new shelf.Response.ok(JSON.encode(organization));
      }).catchError((error, stackTrace) {
        if (error is Storage.NotFound) {
          return new shelf.Response.notFound(
              'Organization with id $organizationID not found');
        }

        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(
            body: 'Failed to update event in database');
      });
    });
  }

  /**
   * Removes a single organization from the data store.
   */
  static Future remove(shelf.Request request) {
    int organizationID = int.parse(shelf_route.getPathParameter(request, 'oid'));

    return _organizationDB.remove(organizationID).then((_) {
      Event.OrganizationChange changeEvent =
          new Event.OrganizationChange(organizationID, Event.OrganizationState.DELETED);

      Notification.broadcastEvent(changeEvent);

      return new shelf.Response.ok(
          JSON.encode({'status': 'ok', 'description': 'Organization deleted'}));
    }).catchError((error, stackTrace) {
      if (error is Storage.NotFound) {
        return new shelf.Response.notFound(JSON
            .encode({'description': 'No organization found with ID $organizationID'}));
      }
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(
          body: 'Failed to execute database query');
    });
  }
}