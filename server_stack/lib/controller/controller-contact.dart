/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.server.controller.contact;

import 'dart:async';
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:logging/logging.dart';
import 'package:openreception.framework/event.dart' as event;
import 'package:openreception.framework/filestore.dart' as filestore;
import 'package:openreception.framework/model.dart' as model;
import 'package:openreception.framework/service.dart' as service;
import 'package:openreception.framework/storage.dart' as storage;
import 'package:openreception.server/response_utils.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_route/shelf_route.dart' as shelf_route;

const String _libraryName = 'openreception.server.controller.reception';

List<int> serializeAndCompressObject(Object obj) =>
    new GZipEncoder().encode(UTF8.encode(JSON.encode(obj)));

class ReceptionCache {
  final Logger _log = new Logger('$_libraryName.ReceptionCache');

  final filestore.Reception _receptionStore;

  final Map<int, List<int>> _receptionCache = {};
  final Map<String, int> _extensionToRid = {};
  List<int> _receptionList = [];

  /**
   *
   */
  ReceptionCache(this._receptionStore);

  /**
   *
   */
  Future<List<int>> getByExtension(String extension) async {
    if (!_extensionToRid.containsKey(extension)) {
      final r = await _receptionStore.getByExtension(extension);
      _receptionCache[r.id] = serializeAndCompressObject(r);
      _extensionToRid[extension] = r.id;
    }

    final int rid = _extensionToRid[extension];

    try {
      return get(rid);
    } on storage.NotFound catch (e) {
      /// Clear out the orphan key
      _extensionToRid.remove(extension);

      throw e;
    }
  }

  /**
   *
   */
  Future<List<int>> get(int rid) async {
    final int key = rid;

    if (!_receptionCache.containsKey(key)) {
      _log.finest('Key $key not found in cache. Looking it up.');
      final r = await _receptionStore.get(rid);
      _receptionCache[r.id] = serializeAndCompressObject(r);
      _extensionToRid[r.dialplan] = r.id;
    }
    return _receptionCache[key];
  }

  /**
   *
   */
  void remove(int rid) {
    _log.finest('Removing key $rid from cache');
    _receptionCache.remove(rid);
  }

  /**
   *
   */
  void removeExtension(String extension) {
    _log.finest('Removing key $extension from cache');
    _extensionToRid.remove(extension);
  }

  /**
   *
   */
  Future<List<int>> list() async {
    if (_receptionList.isEmpty) {
      _log.finest('No reception list found in cache. Looking one up.');

      _receptionList = serializeAndCompressObject(
          (await _receptionStore.list()).toList(growable: false));
    }

    return _receptionList;
  }

  /**
   *
   */
  Map get stats => {
        'receptionCount': _receptionCache.length,
        'receptionSize': _receptionCache.values
            .fold(0, (int sum, List<int> bytes) => sum + bytes.length),
        'listSize': _receptionList.length
      };

  /**
   *
   */
  Future prefill() async {
    final rRefs = await _receptionStore.list();

    _receptionList = serializeAndCompressObject(rRefs.toList(growable: false));

    await Future.forEach(rRefs, (rRef) async {
      final r = await _receptionStore.get(rRef.id);
      _receptionCache[r.id] = serializeAndCompressObject(r);
      _extensionToRid[r.dialplan] = r.id;
    });
  }

  /**
   *
   */
  void emptyList() {
    _receptionList = [];
  }

  /**
   *
   */
  void emptyAll() {
    emptyList();
    _receptionCache.clear();
  }
}

class Contact {
  final service.Authentication _authservice;
  final filestore.Contact _contactStore;
  final service.NotificationService _notification;
  final Map<int, List<int>> _contactCache = {};
  List<int> _contactListCache = [];
  final Map<int, List<int>> _recListCache = {};
  final Map<int, List<int>> _orgListCache = {};

  /// Rid and pre-gzipped listing.
  final Map<int, List<int>> _receptionContactCache = {};

  Contact(this._contactStore, this._notification, this._authservice);

  /**
   * Retrives a single base contact based on contactID.
   */
  Future<shelf.Response> base(shelf.Request request) async {
    final int cid = int.parse(shelf_route.getPathParameter(request, 'cid'));

    if (!_contactCache.containsKey(cid)) {
      model.BaseContact bc;
      try {
        bc = await _contactStore.get(cid);

        _contactCache[cid] =
            new GZipEncoder().encode(UTF8.encode(JSON.encode(bc)));
      } on storage.NotFound catch (e) {
        return notFound(e.toString());
      }
    }

    return okGzip(new Stream.fromIterable([_contactCache[cid]]));
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
    final createEvent = new event.ContactChange.create(rRef.id, creator.id);

    /// Update cache.
    _contactListCache.clear();

    _notification.broadcastEvent(createEvent);

    return okJson(rRef);
  }

  /**
   * Retrives a single base contact based on contactID.
   */
  Future<shelf.Response> listBase(shelf.Request request) async {
    if (_contactListCache.isEmpty) {
      try {
        _contactListCache = new GZipEncoder().encode(UTF8.encode(
            JSON.encode((await _contactStore.list()).toList(growable: false))));
      } on storage.NotFound catch (e) {
        return notFound(e.toString());
      }
    }

    return okGzip(new Stream.fromIterable([_contactListCache]));
  }

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
      final attr = await _contactStore.data(cid, rid);
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
          new event.ContactChange.delete(cid, modifier.id);

      _notification.broadcastEvent(changeEvent);
      return okJson(const {});
    } on storage.NotFound catch (e) {
      return notFound(e.toString());
    } finally {
      /// Remove cached objects. (TODO: remove cached reception data objects)
      _contactCache.remove(cid);
      _contactListCache.clear();
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
          new event.ContactChange.update(cid, modifier.id);

      _notification.broadcastEvent(changeEvent);

      return okJson(ref);
    } on storage.NotFound catch (e) {
      return notFound(e.toString());
    } finally {
      /// Remove cached objects. (TODO: remove cached reception data objects)
      _contactCache.remove(cid);
    }
  }

  /**
   * Gives a lists of every contact in an reception.
   */
  Future<shelf.Response> listByReception(shelf.Request request) async {
    final int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

    if (!_receptionContactCache.containsKey(rid)) {
      Iterable<model.ReceptionContact> contacts;

      try {
        contacts = await _contactStore.receptionContacts(rid);

        _receptionContactCache[rid] = new GZipEncoder()
            .encode(UTF8.encode(JSON.encode(contacts.toList(growable: false))));
      } on storage.NotFound catch (e) {
        return notFound(e.toString());
      }
    }

    return okGzip(new Stream.fromIterable([_receptionContactCache[rid]]));
  }

  /**
   *
   */
  Future<shelf.Response> addToReception(shelf.Request request) async {
    //final int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

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

    final ref = await _contactStore.addData(attr, modifier);

    event.ContactChange changeEvent =
        new event.ContactChange.create(attr.cid, modifier.id);

    _notification.broadcastEvent(changeEvent);

    return okJson(ref);
  }

  /**
   *
   */
  Future<shelf.Response> updateInReception(shelf.Request request) async {
    //final int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

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
      final ref = await _contactStore.updateData(attr, modifier);
      event.ContactChange changeEvent =
          new event.ContactChange.update(attr.cid, modifier.id);

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
      await _contactStore.removeData(cid, rid, modifier);
      event.ContactChange changeEvent =
          new event.ContactChange.delete(cid, modifier.id);
      _notification.broadcastEvent(changeEvent);

      return okJson(const {});
    } on storage.NotFound catch (e) {
      return notFound(e.toString());
    }
  }

  /**
   *
   */
  Future<shelf.Response> history(shelf.Request request) async =>
      okJson((await _contactStore.changes()).toList(growable: false));

  /**
   *
   */
  Future<shelf.Response> objectHistory(shelf.Request request) async {
    final String cidParam = shelf_route.getPathParameter(request, 'cid');
    int cid;
    try {
      cid = int.parse(cidParam);
    } on FormatException {
      return clientError('Bad cid: $cidParam');
    }

    return okJson((await _contactStore.changes(cid)).toList(growable: false));
  }

  /**
   *
   */
  Future<shelf.Response> receptionHistory(shelf.Request request) async {
    final String cidParam = shelf_route.getPathParameter(request, 'cid');
    final String ridParam = shelf_route.getPathParameter(request, 'rid');
    int cid;
    int rid;
    try {
      cid = int.parse(cidParam);
    } on FormatException {
      return clientError('Bad cid: $cidParam');
    }
    try {
      rid = int.parse(ridParam);
    } on FormatException {
      return clientError('Bad rid: $cidParam');
    }

    return okJson(
        (await _contactStore.changes(cid, rid)).toList(growable: false));
  }

  /**
   *
   */
  Future<shelf.Response> cacheStats(shelf.Request request) async {
    final Map stats = {
      'contactCount': _contactCache.length,
      'contactSize': _contactCache.values
          .fold(0, (int sum, List<int> bytes) => sum + bytes.length),
      'receptionContactCount': _receptionContactCache.length,
      'receptionContactSize': _receptionContactCache.values
          .fold(0, (int sum, List<int> bytes) => sum + bytes.length),
    };

    return okJson(stats);
  }

  /**
   *
   */
  Future<shelf.Response> emptyCache(shelf.Request request) async {
    _contactCache.clear();
    _recListCache.clear();
    _contactListCache.clear();
    _receptionContactCache.clear();
    return cacheStats(request);
  }
}
