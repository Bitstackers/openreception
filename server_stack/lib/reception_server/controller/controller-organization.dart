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

part of openreception.reception_server.controller;

void _validate(model.Organization org) {
  if (org.fullName.isEmpty)
    throw new ArgumentError.value(
        org.fullName, 'organization.fullName', 'Must not be empty');
}

class Organization {
  final Logger _log = new Logger('$_libraryName.Organization');
  final database.Organization _organizationDB;
  final service.NotificationService _notification;

  Organization(this._organizationDB, this._notification);

  Future<shelf.Response> list(shelf.Request request) => _organizationDB
      .list()
      .then((Iterable<model.Organization> organizations) =>
          new shelf.Response.ok(
              JSON.encode(organizations.toList(growable: false))));

  Future<shelf.Response> receptionMap(shelf.Request request) =>
      _organizationDB.receptionMap().then((Map map) {
        return new shelf.Response.ok(JSON.encode(map));
      });

  /**
   *
   */
  Future<shelf.Response> get(shelf.Request request) async {
    final int oid = int.parse(shelf_route.getPathParameter(request, 'oid'));

    try {
      return _okJson(await _organizationDB.get(oid));
    } on storage.NotFound catch (error) {
      return _notFound(error.toString());
    }
  }

  /**
   * shelf request handler for listing every contact associated with the
   * organization.
   */
  Future contacts(shelf.Request request) {
    int organizationID =
        int.parse(shelf_route.getPathParameter(request, 'oid'));

    return _organizationDB.contacts(organizationID).then(
        (Iterable<model.BaseContact> contacts) => new shelf.Response.ok(
            JSON.encode(contacts.toList(growable: false))));
  }

  /**
   * shelf request handler for listing every reception associated with the
   * organization.
   */
  Future receptions(shelf.Request request) {
    int organizationID =
        int.parse(shelf_route.getPathParameter(request, 'oid'));

    return _organizationDB.receptions(organizationID).then(
        (Iterable<int> receptionIDs) => new shelf.Response.ok(
            JSON.encode(receptionIDs.toList(growable: false))));
  }

  /**
   * shelf request handler for creating a new organization.
   */
  Future create(shelf.Request request) {
    return request.readAsString().then((String content) {
      model.Organization organization;

      try {
        organization = new model.Organization.fromMap(JSON.decode(content));

        _validate(organization);
      } catch (error) {
        Map response = {
          'status': 'bad request',
          'description': 'passed organization argument '
              'is too long, missing or invalid',
          'error': error.toString()
        };
        return new shelf.Response(400, body: JSON.encode(response));
      }

      return _organizationDB
          .create(organization)
          .then((model.Organization createdOrganization) {
        event.OrganizationChange changeEvent = new event.OrganizationChange(
            createdOrganization.id, event.OrganizationState.CREATED);

        _notification.broadcastEvent(changeEvent);

        return new shelf.Response.ok(JSON.encode(createdOrganization));
      }).catchError((error, stackTrace) {
        _log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(
            body: 'Failed to update organization in database');
      });
    });
  }

  /**
   * Update an organization.
   */
  Future update(shelf.Request request) {
    int organizationID =
        int.parse(shelf_route.getPathParameter(request, 'oid'));

    return request.readAsString().then((String content) {
      model.Organization organization;

      try {
        organization = new model.Organization.fromMap(JSON.decode(content));
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
        event.OrganizationChange changeEvent = new event.OrganizationChange(
            organizationID, event.OrganizationState.UPDATED);

        _notification.broadcastEvent(changeEvent);

        return new shelf.Response.ok(JSON.encode(organization));
      }).catchError((error, stackTrace) {
        if (error is storage.NotFound) {
          return new shelf.Response.notFound(
              'Organization with id $organizationID not found');
        }

        _log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(
            body: 'Failed to update event in database');
      });
    });
  }

  /**
   * Removes a single organization from the data store.
   */
  Future remove(shelf.Request request) {
    int organizationID =
        int.parse(shelf_route.getPathParameter(request, 'oid'));

    return _organizationDB.remove(organizationID).then((_) {
      event.OrganizationChange changeEvent = new event.OrganizationChange(
          organizationID, event.OrganizationState.DELETED);

      _notification.broadcastEvent(changeEvent);

      return new shelf.Response.ok(
          JSON.encode({'status': 'ok', 'description': 'Organization deleted'}));
    }).catchError((error, stackTrace) {
      if (error is storage.NotFound) {
        return new shelf.Response.notFound(JSON.encode(
            {'description': 'No organization found with ID $organizationID'}));
      }
      _log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(
          body: 'Failed to execute database query');
    });
  }
}
