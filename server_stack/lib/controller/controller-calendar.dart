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

library openreception.server.controller.calendar;

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

const String _libraryName = 'dialplan_server.controller';

List<int> serializeAndCompressObject(Object obj) =>
    new GZipEncoder().encode(UTF8.encode(JSON.encode(obj)));

class CalendarCache {
  final Logger _log = new Logger('$_libraryName.CalendarCache');

  final filestore.Calendar cCalendarStore;
  final filestore.Calendar rCalendarStore;

  final Map<String, List<int>> _entryCache = {};
  final Map<String, List<int>> _entryListCache = {};

  /**
   *
   */
  CalendarCache(this.cCalendarStore, this.rCalendarStore) {
    _observers();
  }

  /**
   *
   */
  void _observers() {
    cCalendarStore.changeStream.listen((event.CalendarChange e) {
      if (e.created) {
        emptyList(e.owner);
      } else if (e.updated) {
        emptyList(e.owner);
        removeEntry(e.eid, e.owner);
      } else if (e.deleted) {
        emptyList(e.owner);
        removeEntry(e.eid, e.owner);
      }
    });
  }

  /**
   *
   */
  Future<List<int>> get(int eid, model.Owner owner) async {
    final String key = '$owner:$eid';

    if (!_entryCache.containsKey(key)) {
      _log.finest('Key $key not found in cache. Looking it up.');
      if (owner is model.OwningContact) {
        _entryCache[key] =
            serializeAndCompressObject(await cCalendarStore.get(eid, owner));
      } else if (owner is model.OwningReception) {
        _entryCache[key] =
            serializeAndCompressObject(await rCalendarStore.get(eid, owner));
      } else {
        throw new storage.ClientError('Could not find suitable for store '
            'for owner type: ${owner.runtimeType}');
      }
    }
    return _entryCache[key];
  }

  /**
   *
   */
  void removeEntry(int eid, model.Owner owner) {
    final String key = '$owner:$eid';
    _log.finest('Removing key $key from cache');
    _entryCache.remove(key);
  }

  /**
   *
   */
  Future<List<int>> list(model.Owner owner) async {
    final String key = '$owner';

    if (!_entryListCache.containsKey(key)) {
      _log.finest('Key $key not found in cache. Looking it up.');

      Iterable<model.CalendarEntry> entries = [];
      if (owner is model.OwningContact) {
        entries = (await cCalendarStore.list(owner)).toList(growable: false);
      } else if (owner is model.OwningReception) {
        entries = (await rCalendarStore.list(owner)).toList(growable: false);
      } else {
        throw new storage.ClientError('Could not find suitable for store '
            'for owner type: ${owner.runtimeType}');
      }

      _entryListCache[key] = serializeAndCompressObject(entries);
    }

    return _entryListCache[key];
  }

  /**
   *
   */
  Map get stats => {
        'calendarEntries': _entryCache.length,
        'calendarEntrySize': _entryCache.values
            .fold(0, (int sum, List<int> bytes) => sum + bytes.length),
        'listSize': _entryListCache.length
      };

  /**
   *
   */
  Future prefill(Iterable<model.Owner> owners) async {
    await Future.forEach(owners, (owner) async {
      List<model.CalendarEntry> entries = [];

      if (owner is model.OwningContact) {
        entries = (await cCalendarStore.list(owner)).toList(growable: false);
      } else if (owner is model.OwningReception) {
        entries = (await rCalendarStore.list(owner)).toList(growable: false);
      } else {
        throw new storage.ClientError('Could not find suitable for store '
            'for owner type: ${owner.runtimeType}');
      }

      _entryListCache[owner.toString()] = serializeAndCompressObject(entries);

      await Future.forEach(entries, (entry) async {
        final String key = '$owner:${entry.id}';

        _entryCache[key] = serializeAndCompressObject(entry);
      });
    });
  }

  /**
   *
   */
  void emptyList(model.Owner owner) {
    _entryListCache.remove(owner.toString);
  }

  /**
   *
   */
  void emptyAll() {
    _entryCache.clear();
    _entryListCache.clear();
  }
}

/**
 * Ivr menu controller class.
 */
class Calendar {
  final filestore.Contact _contactStore;
  final filestore.Reception _receptionStore;
  final service.Authentication _authService;
  final service.NotificationService _notification;
  final Logger _log = new Logger('$_libraryName.Calendar');
  CalendarCache _cache;

  /**
   *
   */
  Calendar(this._contactStore, this._receptionStore, this._authService,
      this._notification) {
    _cache = new CalendarCache(
        _contactStore.calendarStore, _receptionStore.calendarStore);
  }

  /**
   *
   */
  Future<shelf.Response> create(shelf.Request request) async {
    model.User modifier;
    try {
      modifier = await _authService.userOf(tokenFrom(request));
    } catch (e, s) {
      _log.warning('Could not connect to auth server', e, s);
      return authServerDown();
    }

    model.Owner owner;
    final String type = shelf_route.getPathParameter(request, 'type');
    final String oid = shelf_route.getPathParameter(request, 'oid');
    try {
      owner = new model.Owner.parse('$type:$oid');
    } catch (e) {
      final String msg = 'Could parse owner: $type:$oid';
      _log.warning(msg, e);
      return clientError(e.toString(msg));
    }

    final model.CalendarEntry entry =
        model.CalendarEntry.decode(JSON.decode(await request.readAsString()));

    model.CalendarEntry created;

    try {
      if (owner is model.OwningContact) {
        created =
            await _contactStore.calendarStore.create(entry, owner, modifier);
      } else if (owner is model.OwningReception) {
        created =
            await _receptionStore.calendarStore.create(entry, owner, modifier);
      } else {
        return clientError('Could not find suitable for store '
            'for owner type: ${owner.runtimeType}');
      }
    } on storage.ClientError {
      return clientError('Could not create new object.');
    }

    event.CalendarChange changeEvent =
        new event.CalendarChange.create(created.id, owner, modifier.id);
    _log.finest('User id:${modifier.id} created entry for ${owner}');

    _notification.broadcastEvent(changeEvent);

    return okJson(created);
  }

  /**
   *
   */
  Future<shelf.Response> get(shelf.Request request) async {
    final int eid = int.parse(shelf_route.getPathParameter(request, 'eid'));

    model.Owner owner;
    final String type = shelf_route.getPathParameter(request, 'type');
    final String oid = shelf_route.getPathParameter(request, 'oid');
    try {
      owner = new model.Owner.parse('$type:$oid');
    } catch (e) {
      final String msg = 'Could parse owner: $type:$oid';
      _log.warning(msg, e);
      return clientError(e.toString(msg));
    }

    try {
      return okGzip(new Stream.fromIterable([await _cache.get(eid, owner)]));
    } on storage.ClientError catch (e) {
      return clientError(e.toString());
    } on storage.NotFound {
      return notFound('No event with id $eid');
    }
  }

  /**
   *
   */
  Future<shelf.Response> getDeleted(shelf.Request request) async {
    final int eid = int.parse(shelf_route.getPathParameter(request, 'eid'));

    try {
      //return okJson(await _calendarStore.get(eid));
      return serverError('Not supported');
    } on storage.NotFound {
      return notFound('No event with id $eid');
    }
  }

  /**
   *
   */
  Future<shelf.Response> list(shelf.Request request) async {
    model.Owner owner;
    final String type = shelf_route.getPathParameter(request, 'type');
    final String oid = shelf_route.getPathParameter(request, 'oid');
    try {
      owner = new model.Owner.parse('$type:$oid');
    } catch (e) {
      final String msg = 'Could parse owner: $type:$oid';
      _log.warning(msg, e);
      return clientError(e.toString(msg));
    }

    try {
      return okGzip(new Stream.fromIterable([await _cache.list(owner)]));
    } on storage.ClientError catch (e) {
      return clientError(e.toString());
    } on storage.NotFound {
      return notFound('Non-existing owner $owner');
    }
  }

  /**
   *
   */
  Future<shelf.Response> remove(shelf.Request request) async {
    model.User modifier;
    try {
      modifier = await _authService.userOf(tokenFrom(request));
    } catch (e) {
      _log.warning('Could not connect to auth server');
      return authServerDown();
    }

    final int eid = int.parse(shelf_route.getPathParameter(request, 'eid'));
    final String type = shelf_route.getPathParameter(request, 'type');
    final String oid = shelf_route.getPathParameter(request, 'oid');
    model.Owner owner;
    try {
      owner = new model.Owner.parse('$type:$oid');
    } catch (e) {
      final String msg = 'Could parse owner: $type:$oid';
      _log.warning(msg, e);
      return clientError(e.toString(msg));
    }

    try {
      if (owner is model.OwningContact) {
        await _contactStore.calendarStore.remove(eid, owner, modifier);
      } else if (owner is model.OwningReception) {
        await _receptionStore.calendarStore.remove(eid, owner, modifier);
      } else {
        return clientError('Could not find suitable for store '
            'for owner type: ${owner.runtimeType}');
      }
    } on storage.NotFound {
      return notFound('Non-existing owner $owner');
    }

    final event.CalendarChange changeEvent =
        new event.CalendarChange.delete(eid, owner, modifier.id);

    _log.finest('User id:${modifier.id} removed entry for ${owner}');

    _notification.broadcastEvent(changeEvent);

    return okJson('{}');
  }

  /**
   *
   */
  Future<shelf.Response> update(shelf.Request request) async {
    model.User modifier;

    try {
      modifier = await _authService.userOf(tokenFrom(request));
    } catch (e, s) {
      _log.warning('Could not connect to auth server', e, s);
      return authServerDown();
    }

    final String type = shelf_route.getPathParameter(request, 'type');
    final String oid = shelf_route.getPathParameter(request, 'oid');
    model.Owner owner;
    try {
      owner = new model.Owner.parse('$type:$oid');
    } catch (e) {
      final String msg = 'Could parse owner: $type:$oid';
      _log.warning(msg, e);
      return clientError(e.toString(msg));
    }

    final model.CalendarEntry entry =
        model.CalendarEntry.decode(JSON.decode(await request.readAsString()));

    model.CalendarEntry updated;

    try {
      if (owner is model.OwningContact) {
        updated =
            await _contactStore.calendarStore.update(entry, owner, modifier);
      } else if (owner is model.OwningReception) {
        updated =
            await _receptionStore.calendarStore.update(entry, owner, modifier);
      } else {
        return clientError('Could not find suitable for store '
            'for owner type: ${owner.runtimeType}');
      }
    } on storage.NotFound {
      return notFound('Non-existing owner $owner');
    }

    final event.CalendarChange changeEvent =
        new event.CalendarChange.update(updated.id, owner, modifier.id);

    _log.finest('User id:${modifier.id} updated entry for ${owner}');

    _notification.broadcastEvent(changeEvent);

    return okJson(updated);
  }

  /**
   *
   */
  Future<shelf.Response> changes(shelf.Request request) async {
    final int eid = shelf_route.getPathParameter(request, 'eid') != null
        ? int.parse(shelf_route.getPathParameter(request, 'eid'))
        : null;

    final String type = shelf_route.getPathParameter(request, 'type');
    final String oid = shelf_route.getPathParameter(request, 'oid');
    model.Owner owner;
    try {
      owner = new model.Owner.parse('$type:$oid');
    } catch (e) {
      final String msg = 'Could parse owner: $type:$oid';
      _log.warning(msg, e);
      return clientError(e.toString(msg));
    }

    try {
      if (owner is model.OwningContact) {
        return okJson((await _contactStore.calendarStore.changes(owner, eid))
            .toList(growable: false));
      } else if (owner is model.OwningReception) {
        return okJson((await _receptionStore.calendarStore.changes(owner, eid))
            .toList(growable: false));
      } else {
        return clientError('Could not find suitable for store '
            'for owner type: ${owner.runtimeType}');
      }
    } on storage.NotFound {
      return notFound('No event with id $eid');
    }
  }

  /**
   *
   */
  Future<shelf.Response> cacheStats(shelf.Request request) async {
    return okJson(_cache.stats);
  }

  /**
   *
   */
  Future<shelf.Response> emptyCache(shelf.Request request) async {
    _cache.emptyAll();

    return cacheStats(request);
  }

  /**
   *
   */
  Future<shelf.Response> cachePrefill(shelf.Request request) async {
    ///TODO: Implement.
    await _cache.prefill([]);

    return cacheStats(request);
  }
}
