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
  final service.Authentication _authservice;
  final filestore.Contact _contactStore;
  final service.NotificationService _notification;

  Contact(this._contactStore, this._notification, this._authservice);

  /**
   * Retrives a single base contact based on contactID.
   */
  Future<shelf.Response> base(shelf.Request request) async {
    final int cid = int.parse(shelf_route.getPathParameter(request, 'cid'));

    try {
      return okJson(await _contactStore.get(cid));
    } on storage.NotFound catch (e) {
      return notFound(e.toString());
    }
  }

  /**
   * Creates a new base contact.
   */
  Future<shelf.Response> create(shelf.Request request) async {
    model.BaseContact contact;
    model.User creator;

    try {
      contact = await request
          .readAsString()
          .then(JSON.decode)
          .then(model.BaseContact.decode);
    } on FormatException {
      return clientError('Failed to parse contact object');
    }

    try {
      creator = await _authservice.userOf(tokenFrom(request));
    } catch (e) {
      return authServerDown();
    }

    final rRef = await _contactStore.create(contact, creator);

    _notification.broadcastEvent(
        new event.ContactChange(rRef.id, event.ContactState.CREATED));

    return okJson(rRef);
  }

  /**
   * Retrives a single base contact based on contactID.
   */
  Future<shelf.Response> listBase(shelf.Request request) async =>
      okJson((await _contactStore.list()).toList(growable: false));

  /**
   * Retrives a list of base contacts associated with the provided
   * organization id.
   */
  Future<shelf.Response> listByOrganization(shelf.Request request) async {
    final int oid = int.parse(shelf_route.getPathParameter(request, 'oid'));

    return okJson((await _contactStore.organizationContacts(oid))
        .toList(growable: false));
  }

  /**
   * Retrives a single contact based on receptionID and contactID.
   */
  Future<shelf.Response> get(shelf.Request request) async {
    final int cid = int.parse(shelf_route.getPathParameter(request, 'cid'));
    final int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

    try {
      final attr = await _contactStore.getByReception(cid, rid);
      return okJson((attr));
    } on storage.NotFound catch (e) {
      return notFound(e.toString());
    }
  }

  /**
   * Returns the id's of all organizations that a contact is associated to.
   */
  Future<shelf.Response> organizations(shelf.Request request) async {
    final int cid = int.parse(shelf_route.getPathParameter(request, 'cid'));

    return okJson(
        ((await _contactStore.organizations(cid)).toList(growable: false)));
  }

  /**
   * Returns the id's of all receptions that a contact is associated to.
   */
  Future<shelf.Response> receptions(shelf.Request request) async {
    final int cid = int.parse(shelf_route.getPathParameter(request, 'cid'));

    return okJson(
        (await _contactStore.receptions(cid)).toList(growable: false));
  }

  /**
   * Removes a single contact from the data store.
   */
  Future<shelf.Response> remove(shelf.Request request) async {
    final int cid = int.parse(shelf_route.getPathParameter(request, 'cid'));
    model.User modifier;

    try {
      modifier = await _authservice.userOf(tokenFrom(request));
    } catch (e) {
      return authServerDown();
    }

    try {
      await _contactStore.remove(cid, modifier);
      event.ContactChange changeEvent =
          new event.ContactChange(cid, event.ContactState.DELETED);

      _notification.broadcastEvent(changeEvent);
      return okJson(const {});
    } on storage.NotFound catch (e) {
      return notFound(e.toString());
    }
  }

  /**
   * Update the base information of a contact
   */
  Future<shelf.Response> update(shelf.Request request) async {
    final int cid = int.parse(shelf_route.getPathParameter(request, 'cid'));

    model.User modifier;
    try {
      modifier = await _authservice.userOf(tokenFrom(request));
    } catch (e) {
      return authServerDown();
    }

    model.BaseContact contact;

    try {
      contact = await request
          .readAsString()
          .then(JSON.decode)
          .then(model.BaseContact.decode);
    } catch (error) {
      final Map response = {
        'status': 'bad request',
        'description': 'passed contact argument '
            'is too long, missing or invalid',
        'error': error.toString()
      };
      return clientErrorJson(response);
    }

    try {
      final ref = await _contactStore.update(contact, modifier);
      event.ContactChange changeEvent =
          new event.ContactChange(cid, event.ContactState.UPDATED);

      _notification.broadcastEvent(changeEvent);

      return okJson(ref);
    } on storage.NotFound catch (e) {
      return notFound(e.toString());
    }
  }

  /**
   * Gives a lists of every contact in an reception.
   */
  Future<shelf.Response> listByReception(shelf.Request request) async {
    final String rid = shelf_route.getPathParameter(request, 'rid');
    final int receptionID = int.parse(rid);

    try {
      Iterable<model.ReceptionAttributes> contacts =
          await _contactStore.listByReception(receptionID);

      return okJson(contacts.toList());
    } on storage.SqlError catch (error) {
      new shelf.Response.internalServerError(body: error);
    }
  }

  /**
   *
   */
  Future<shelf.Response> addToReception(shelf.Request request) async {
    final int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

    model.ReceptionAttributes attr;
    model.User modifier;

    try {
      Map data = JSON.decode(await request.readAsString());
      attr = new model.ReceptionAttributes.fromMap(data);
    } catch (error) {
      final Map response = {
        'status': 'bad request',
        'description': 'passed contact argument '
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

    final ref = await _contactStore.addToReception(attr, modifier);

    event.ContactChange changeEvent =
        new event.ContactChange(attr.contactId, event.ContactState.UPDATED);

    _notification.broadcastEvent(changeEvent);

    return okJson(ref);
  }

  /**
   *
   */
  Future<shelf.Response> updateInReception(shelf.Request request) async {
    final int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

    model.User modifier;
    try {
      modifier = await _authservice.userOf(tokenFrom(request));
    } catch (e) {
      return authServerDown();
    }

    model.ReceptionAttributes attr;
    try {
      attr = await request
          .readAsString()
          .then(JSON.decode)
          .then(model.ReceptionAttributes.decode);
    } catch (error) {
      Map response = {
        'status': 'bad request',
        'description': 'passed contact argument '
            'is too long, missing or invalid',
        'error': error.toString()
      };

      return clientErrorJson(response);
    }

    try {
      final ref = await _contactStore.updateInReception(attr, modifier);
      event.ContactChange changeEvent =
          new event.ContactChange(attr.contactId, event.ContactState.UPDATED);

      _notification.broadcastEvent(changeEvent);

      return okJson(ref);
    } on storage.NotFound catch (e) {
      return notFound(e.toString());
    }
  }

  /**
   *
   */
  Future<shelf.Response> removeFromReception(shelf.Request request) async {
    final int cid = int.parse(shelf_route.getPathParameter(request, 'cid'));
    final int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

    model.User modifier;
    try {
      modifier = await _authservice.userOf(tokenFrom(request));
    } catch (e) {
      return authServerDown();
    }

    try {
      await _contactStore.removeFromReception(cid, rid, modifier);
      event.ContactChange changeEvent =
          new event.ContactChange(cid, event.ContactState.UPDATED);
      _notification.broadcastEvent(changeEvent);

      return okJson(const {});
    } on storage.NotFound catch (e) {
      return notFound(e.toString());
    }
  }
}
