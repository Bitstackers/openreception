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

library openreception.server.controller.reception;

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

class Reception {
  final filestore.Reception _rStore;
  final service.Authentication _authservice;
  final service.NotificationService _notification;
  ReceptionCache _cache;

  /**
   * Default constructor.
   */
  Reception(this._rStore, this._notification, this._authservice) {
    _cache = new ReceptionCache(_rStore);
  }

  /**
   *
   */
  Future<shelf.Response> list(shelf.Request request) async {
    return okGzip(new Stream.fromIterable([await _cache.list()]));
  }

  /**
   *
   */
  Future<shelf.Response> getByExtension(shelf.Request request) async {
    final String exten = shelf_route.getPathParameter(request, 'exten');

    try {
      final r = await _cache.getByExtension(exten);
      return okGzip(new Stream.fromIterable([r]));
    } on storage.NotFound {
      return notFoundJson({
        'description': 'No reception '
            'found on extension extension'
      });
    }
  }

  /**
   *
   */
  Future<shelf.Response> extensionOf(shelf.Request request) async {
    final int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

    try {
      final model.Reception rec = await _rStore.get(rid);
      return ok(rec.dialplan);
    } on storage.NotFound {
      return notFoundJson({
        'description': 'No reception '
            'found with ID $rid'
      });
    }
  }

  /**
   *
   */
  Future<shelf.Response> get(shelf.Request request) async {
    final int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

    try {
      return okJson(await _rStore.get(rid));
    } on storage.NotFound catch (error) {
      return notFound(error.toString());
    }
  }

  /**
   * shelf request handler for creating a new reception.
   */
  Future create(shelf.Request request) async {
    model.Reception reception;
    model.User creator;
    try {
      reception = await request
          .readAsString()
          .then(JSON.decode)
          .then(model.Reception.decode);
    } on FormatException catch (error) {
      Map response = {
        'status': 'bad request',
        'description': 'passed reception argument '
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

    final rRef = await _rStore.create(reception, creator);

    _cache.removeExtension(reception.dialplan);
    _cache.emptyList();

    _notification
        .broadcastEvent(new event.ReceptionChange.create(rRef.id, creator.id));
    return okJson(rRef);
  }

  /**
   * Update a reception.
   */
  Future update(shelf.Request request) async {
    model.Reception reception;
    model.User modifier;
    try {
      reception = await request
          .readAsString()
          .then(JSON.decode)
          .then(model.Reception.decode);
    } on FormatException catch (error) {
      Map response = {
        'status': 'bad request',
        'description': 'passed reception argument '
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
      final rRef = await _rStore.update(reception, modifier);

      _cache.remove(rRef.id);
      _cache.removeExtension(reception.dialplan);
      _cache.emptyList();

      _notification.broadcastEvent(
          new event.ReceptionChange.update(rRef.id, modifier.id));
      return okJson(rRef);
    } on storage.NotFound catch (e) {
      return notFound(e.toString());
    } on storage.ClientError catch (e) {
      return clientError(e.toString());
    }
  }

  /**
   * Removes a single reception from the data store.
   */
  Future remove(shelf.Request request) async {
    final int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));
    model.User modifier;

    try {
      modifier = await _authservice.userOf(tokenFrom(request));
    } catch (e) {
      return authServerDown();
    }

    try {
      await _rStore.remove(rid, modifier);

      _cache.remove(rid);

      _cache.emptyList();

      _notification
          .broadcastEvent(new event.ReceptionChange.delete(rid, modifier.id));

      return okJson({'status': 'ok', 'description': 'Reception deleted'});
    } on storage.NotFound {
      return notFoundJson({'description': 'No reception found with ID $rid'});
    }
  }

  /**
   *
   */
  Future<shelf.Response> history(shelf.Request request) async =>
      okJson((await _rStore.changes()).toList(growable: false));

  /**
   *
   */
  Future<shelf.Response> objectHistory(shelf.Request request) async {
    final String ridParam = shelf_route.getPathParameter(request, 'rid');
    int rid;
    try {
      rid = int.parse(ridParam);
    } on FormatException {
      return clientError('Bad rid: $ridParam');
    }

    return okJson((await _rStore.changes(rid)).toList(growable: false));
  }
}
