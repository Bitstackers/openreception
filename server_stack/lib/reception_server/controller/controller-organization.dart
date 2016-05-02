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
  if (org.name.isEmpty)
    throw new FormatException('organization.name must not be empty');
}

class Organization {
  final filestore.Organization _orgStore;
  final service.Authentication _authservice;
  final service.NotificationService _notification;

  /**
   * Default constructor.
   */
  Organization(this._orgStore, this._notification, this._authservice);

  /**
   *
   */
  Future<shelf.Response> list(shelf.Request request) async =>
      okJson((await _orgStore.list()).toList(growable: false));

  /**
   *
   */
  Future<shelf.Response> receptionMap(shelf.Request request) async =>
      okJson(await _orgStore.receptionMap());

  /**
   *
   */
  Future<shelf.Response> get(shelf.Request request) async {
    final int oid = int.parse(shelf_route.getPathParameter(request, 'oid'));

    try {
      return okJson(await _orgStore.get(oid));
    } on storage.NotFound catch (error) {
      return notFound(error.toString());
    }
  }

  /**
   * shelf request handler for listing every contact associated with the
   * organization.
   */
  Future contacts(shelf.Request request) async {
    final int oid = int.parse(shelf_route.getPathParameter(request, 'oid'));

    return okJson((await _orgStore.contacts(oid)).toList(growable: false));
  }

  /**
   * shelf request handler for listing every reception associated with the
   * organization.
   */
  Future receptions(shelf.Request request) async {
    final int orgid = int.parse(shelf_route.getPathParameter(request, 'oid'));

    return okJson((await _orgStore.receptions(orgid)).toList(growable: false));
  }

  /**
   * shelf request handler for creating a new organization.
   */
  Future create(shelf.Request request) async {
    model.Organization organization;
    model.User creator;

    try {
      organization = await request
          .readAsString()
          .then(JSON.decode)
          .then(model.Organization.decode);
      _validate(organization);
    } on FormatException catch (error) {
      Map response = {
        'status': 'bad request',
        'description': 'passed organization argument '
            'is too long, missing or invalid',
        'error': error.toString()
      };
      return clientErrorJson(response);
    }

    try {
      creator = await _authservice.userOf(tokenFrom(request));
    } catch (e) {
      return authServerDown();
    }

    final oRef = await _orgStore.create(organization, creator);
    _notification.broadcastEvent(
        new event.OrganizationChange.create(oRef.id, creator.id));

    return okJson(oRef);
  }

  /**
   * Update an organization.
   */
  Future update(shelf.Request request) async {
    model.Organization org;
    model.User modifier;
    try {
      org = await request
          .readAsString()
          .then(JSON.decode)
          .then(model.Organization.decode);
      _validate(org);
    } on FormatException catch (error) {
      Map response = {
        'status': 'bad request',
        'description': 'passed organization argument '
            'is too long, missing or invalid',
        'error': error.toString()
      };
      return clientErrorJson(response);
    }

    try {
      modifier = await _authservice.userOf(tokenFrom(request));
    } catch (e) {
      return authServerDown();
    }

    try {
      final rRef = await _orgStore.update(org, modifier);
      _notification.broadcastEvent(
          new event.OrganizationChange.update(rRef.id, modifier.id));
      return okJson(rRef);
    } on storage.NotFound catch (e) {
      return notFound(e.toString());
    } on storage.ClientError catch (e) {
      return clientError(e.toString());
    }
  }

  /**
   * Removes a single organization from the data store.
   */
  Future remove(shelf.Request request) async {
    final int oid = int.parse(shelf_route.getPathParameter(request, 'oid'));
    model.User modifier;

    try {
      modifier = await _authservice.userOf(tokenFrom(request));
    } catch (e) {
      return authServerDown();
    }

    try {
      await _orgStore.remove(oid, modifier);
      _notification.broadcastEvent(
          new event.OrganizationChange.delete(oid, modifier.id));

      return okJson({'status': 'ok', 'description': 'Organization deleted'});
    } on storage.NotFound {
      return notFoundJson(
          {'description': 'No Organization found with ID $oid'});
    }
  }

  /**
   *
   */
  Future<shelf.Response> history(shelf.Request request) async =>
      okJson((await _orgStore.changes()).toList(growable: false));

  /**
   *
   */
  Future<shelf.Response> objectHistory(shelf.Request request) async {
    final String oidParam = shelf_route.getPathParameter(request, 'oid');
    int oid;
    try {
      oid = int.parse(oidParam);
    } on FormatException {
      return clientError('Bad oid: $oidParam');
    }

    return okJson((await _orgStore.changes(oid)).toList(growable: false));
  }
}
