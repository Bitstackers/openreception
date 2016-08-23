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

library openreception.server.controller.organization;

import 'dart:async';
import 'dart:convert';

import 'package:openreception.framework/event.dart' as event;
import 'package:openreception.framework/exceptions.dart';
import 'package:openreception.framework/filestore.dart' as filestore;
import 'package:openreception.framework/gzip_cache.dart' as gzip_cache;
import 'package:openreception.framework/model.dart' as model;
import 'package:openreception.framework/service.dart' as service;
import 'package:openreception.framework/validation.dart';
import 'package:openreception.server/response_utils.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_route/shelf_route.dart' as shelf_route;

const String _libraryName = 'openreception.server.controller.organization';

class Organization {
  final filestore.Organization _orgStore;
  final service.Authentication _authservice;
  final service.NotificationService _notification;
  final gzip_cache.OrganizationCache _cache;

  /**
   * Default constructor.
   */
  Organization(
      this._orgStore, this._notification, this._authservice, this._cache);

  /**
   *
   */
  Future<shelf.Response> list(shelf.Request request) async =>
      okGzip(new Stream.fromIterable([await _cache.list()]));
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
      return okGzip(new Stream.fromIterable([await _cache.get(oid)]));
    } on NotFound catch (error) {
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

      final List<ValidationException> errors =
          validateOrganization(organization);

      if (errors.isNotEmpty) {
        throw errors.first;
      }
    } on ValidationException catch (error) {
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
      final List<ValidationException> errors = validateOrganization(org);

      if (errors.isNotEmpty) {
        throw errors.first;
      }
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
    } on NotFound catch (e) {
      return notFound(e.toString());
    } on ClientError catch (e) {
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
    } on NotFound {
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

  /**
   *
   */
  Future<shelf.Response> changelog(shelf.Request request) async {
    final String oidParam = shelf_route.getPathParameter(request, 'oid');
    int oid;
    try {
      oid = int.parse(oidParam);
    } on FormatException {
      return clientError('Bad oid: $oidParam');
    }

    return ok((await _orgStore.changeLog(oid)));
  }
}
