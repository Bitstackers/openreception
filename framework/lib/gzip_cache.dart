/*                  This file is part of OpenReception
                   Copyright (C) 2016-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.framework.gzip_cache;

import 'dart:async';

import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:logging/logging.dart';
import 'package:openreception.framework/event.dart' as event;
import 'package:openreception.framework/filestore.dart' as filestore;
import 'package:openreception.framework/model.dart' as model;
import 'package:openreception.framework/storage.dart' as storage;

const String _libraryName = 'openreception.framework.gzip_cache';

List<int> serializeAndCompressObject(Object obj) =>
    new GZipEncoder().encode(UTF8.encode(JSON.encode(obj)));

bool isEmptyGzipList(List<int> list) {
  if (list.length != emptyGzipList.length) {
    return false;
  }

  for (int i = 0; i < emptyGzipList.length; i++) {
    if (list[i] != emptyGzipList[i]) return false;
  }

  return true;
}

final List<int> emptyGzipList = serializeAndCompressObject([]);

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

      if (entries.isEmpty) {
        _entryListCache[key] = emptyGzipList;
      } else {
        _entryListCache[key] = serializeAndCompressObject(entries);
      }
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

class ContactCache {
  final filestore.Contact _contactStore;
  final Map<int, List<int>> _contactCache = {};
  List<int> _contactListCache = [];
  final Map<int, List<int>> _recListCache = {};
  final Map<int, List<int>> _orgListCache = {};

  /// Rid and pre-gzipped listing.
  final Map<int, List<int>> _receptionContactCache = {};

  /// Cid:rid reception datas
  final Map<String, List<int>> _receptionDataCache = {};

  ContactCache(this._contactStore) {
    _observers();
  }

  /**
   *
   */
  Future<List<int>> receptionData(int cid, int rid) async {
    final String key = '$cid:$rid';

    if (!_receptionDataCache.containsKey(key)) {
      _receptionDataCache[key] = new GZipEncoder()
          .encode(UTF8.encode(JSON.encode(await _contactStore.data(cid, rid))));
    }

    return _receptionDataCache[key];
  }

  /**
   *
   */
  void _observers() {
    _contactStore.onContactChange.listen((event.ContactChange e) {
      if (e.updated || e.deleted) {
        removeContact(e.cid);
      }

      emptyContactLists();
    });
  }

  /**
   *
   */
  Future<List<int>> allContacts() async {
    if (_contactListCache.isEmpty) {
      _contactListCache = new GZipEncoder().encode(UTF8.encode(
          JSON.encode((await _contactStore.list()).toList(growable: false))));
    }

    return _contactListCache;
  }

  /**
   *
   */
  void removeContact(int cid) {
    _contactCache.remove(cid);
    _receptionContactCache.clear();
  }

  /**
   *
   */
  void emptyContactLists() {
    _contactListCache = [];
    _receptionContactCache.clear();
  }

  Future<List<int>> receptionContacts(int rid) async {
    if (!_receptionContactCache.containsKey(rid)) {
      Iterable<model.ReceptionContact> contacts;

      contacts = await _contactStore.receptionContacts(rid);

      _receptionContactCache[rid] = new GZipEncoder()
          .encode(UTF8.encode(JSON.encode(contacts.toList(growable: false))));
    }

    return _receptionContactCache[rid];
  }

  /**
   *
   */
  Future<List<int>> get(int cid) async {
    if (!_contactCache.containsKey(cid)) {
      _contactCache[cid] = new GZipEncoder()
          .encode(UTF8.encode(JSON.encode(await _contactStore.get(cid))));
    }
    return _contactCache[cid];
  }

  /**
   *
   */
  void emptyAll() {
    _contactCache.clear();
    _contactListCache = [];
    _recListCache.clear();
    _orgListCache.clear();
    _receptionContactCache.clear();
  }

  /**
   *
   */
  Future prefill() async {
    final contactList = await _contactStore.list();
    _contactListCache = serializeAndCompressObject(contactList);

    await Future.forEach(contactList, (model.BaseContact con) async {
      _contactCache[con.id] = serializeAndCompressObject(con);

      final rRefs = await _contactStore.receptions(con.id);

      await Future.forEach(rRefs, (rRef) async {
        if (_receptionContactCache[rRef.id] != null) {
          _receptionContactCache[rRef.id] = serializeAndCompressObject(
              await _contactStore.receptionContacts(rRef.id));
        }
      });
    });
  }

  /**
   *
   */
  Map get stats => {
        'contactCount': _contactCache.length,
        'contactSize': _contactCache.values
            .fold(0, (int sum, List<int> bytes) => sum + bytes.length),
        'receptionContactCount': _receptionContactCache.length,
        'receptionContactSize': _receptionContactCache.values
            .fold(0, (int sum, List<int> bytes) => sum + bytes.length),
      };
}

class MessageCache {
  final filestore.Message _messageStore;
  final Map<String, List<int>> _messageListCache = {};
  List<int> _savedListCache = [];

  MessageCache(this._messageStore) {
    _observers();
  }

  /**
   *
   */
  Future<List<int>> list(DateTime day) async {
    final String key = day.toIso8601String().split('T').first;

    if (!_messageListCache.containsKey(key)) {
      final messages = await _messageStore.listDay(day);

      if (messages.isEmpty) {
        _messageListCache[key] = emptyGzipList;
      } else {
        _messageListCache[key] =
            new GZipEncoder().encode(UTF8.encode(JSON.encode(messages)));
      }
    }

    return _messageListCache[key];
  }

  /**
   *
   */
  Future<List<int>> listSaved() async {
    if (_savedListCache.isEmpty) {
      _savedListCache = new GZipEncoder()
          .encode(UTF8.encode(JSON.encode(await _messageStore.listSaved())));
    }

    return _savedListCache;
  }

  /**
   * Remove the cache from _today_ only because we simply do not know which
   * cache the given message is stored in.
   */
  void _observers() {
    _messageStore.changeStream.listen((event.MessageChange e) {
      final String key = new DateTime.now().toIso8601String().split('T').first;
      _messageListCache.remove(key);

      if (e.messageState == model.MessageState.saved) {
        _savedListCache = [];
      }
    });
  }

  /**
   *
   */
  Future prefill() async {
    throw new UnimplementedError();
  }

  /**
   *
   */
  Map get stats => {
        'messageFolderCount': _messageListCache.length,
        'messageFolderSize': _messageListCache.values
            .fold(0, (int sum, List<int> bytes) => sum + bytes.length),
        'savedMessageSize': _savedListCache.length
      };
}
