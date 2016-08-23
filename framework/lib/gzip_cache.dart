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

dynamic unpackAndDeserializeObject(List<int> data) =>
    JSON.decode(UTF8.decode(new GZipDecoder().decodeBytes(data)));

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

final List<int> emptyGzipList = serializeAndCompressObject(<int>[]);

class CalendarCache {
  final Logger _log = new Logger('$_libraryName.CalendarCache');

  final filestore.Calendar cCalendarStore;
  final filestore.Calendar rCalendarStore;

  final Map<String, List<int>> _entryCache = <String, List<int>>{};
  final Map<String, List<int>> _entryListCache = <String, List<int>>{};

  /**
   *
   */
  CalendarCache(this.cCalendarStore, this.rCalendarStore,
      Iterable<Stream<event.CalendarChange>> streams) {
    streams.forEach((Stream<event.CalendarChange> stream) {
      stream.listen((event.CalendarChange e) {
        if (e.isUpdate || e.isDelete) {
          removeEntry(e.eid, e.owner);
        }
        _emptyList(e.owner);
      });
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

      Iterable<model.CalendarEntry> entries = <model.CalendarEntry>[];
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
  Map<String, dynamic> get stats =>
      new Map<String, dynamic>.unmodifiable(<String, dynamic>{
        'calendarEntries': _entryCache.length,
        'calendarEntrySize': _entryCache.values
            .fold(0, (int sum, List<int> bytes) => sum + bytes.length),
        'listSize': _entryListCache.length
      });

  /**
   *
   */
  Future<Null> prefill(Iterable<model.Owner> owners) async {
    await Future.forEach(owners, (model.Owner owner) async {
      final List<model.CalendarEntry> entries = <model.CalendarEntry>[];

      if (owner is model.OwningContact) {
        entries.addAll(await cCalendarStore.list(owner));
      } else if (owner is model.OwningReception) {
        entries.addAll(await rCalendarStore.list(owner));
      } else {
        throw new storage.ClientError('Could not find suitable for store '
            'for owner type: ${owner.runtimeType}');
      }

      _entryListCache[owner.toString()] = serializeAndCompressObject(entries);

      await Future.forEach(entries, (model.CalendarEntry entry) async {
        final String key = '$owner:${entry.id}';

        _entryCache[key] = serializeAndCompressObject(entry);
      });
    });
  }

  /**
   *
   */
  void _emptyList(model.Owner owner) {
    _log.finest('Emptying cache for ${owner.toJson()}');
    _entryListCache.remove(owner.toString());
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

  final Map<int, List<int>> _receptionCache = <int, List<int>>{};
  final Map<String, int> _extensionToRid = <String, int>{};
  List<int> _receptionList = <int>[];

  /**
   *
   */
  ReceptionCache(
      this._receptionStore, Stream<event.ReceptionChange> receptionChanges) {
    receptionChanges.listen((event.ReceptionChange change) {
      if (change.isUpdate || change.isDelete) {
        remove(change.rid);
      }

      emptyList();
    });
  }

  /// Retrieve the qzip-compression and serialized [model.Reception] with
  /// ID [rid].
  ///
  /// Throws a [NotFound] exception if the reception is neither found in the
  /// cache, nor the filestore.
  /// Will retrieve and cache reception object from the store, if not found
  /// in the cache.
  Future<List<int>> get(int rid) async {
    final int key = rid;

    if (!_receptionCache.containsKey(key)) {
      _log.finest('Key $key not found in cache. Looking it up.');
      final model.Reception r = await _receptionStore.get(rid);
      _receptionCache[r.id] = serializeAndCompressObject(r);
      _extensionToRid[r.dialplan] = r.id;
    }
    return _receptionCache[key];
  }

  void remove(int rid) {
    _log.finest('Removing key $rid from cache');
    _receptionCache.remove(rid);
  }

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
  Map<String, dynamic> get stats => <String, dynamic>{
        'receptionCount': _receptionCache.length,
        'receptionSize': _receptionCache.values
            .fold(0, (int sum, List<int> bytes) => sum + bytes.length),
        'listSize': _receptionList.length
      };

  /**
   *
   */
  Future<Null> prefill() async {
    final Iterable<model.ReceptionReference> rRefs =
        await _receptionStore.list();

    _receptionList = serializeAndCompressObject(rRefs.toList(growable: false));

    await Future.forEach(rRefs, (model.ReceptionReference rRef) async {
      final model.Reception r = await _receptionStore.get(rRef.id);
      _receptionCache[r.id] = serializeAndCompressObject(r);
      _extensionToRid[r.dialplan] = r.id;
    });
  }

  /**
   *
   */
  void emptyList() {
    _receptionList = <int>[];
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
  final Map<int, List<int>> _contactCache = <int, List<int>>{};
  List<int> _contactListCache = <int>[];
  final Map<int, List<int>> _recListCache = <int, List<int>>{};
  final Map<int, List<int>> _orgListCache = <int, List<int>>{};

  /// Rid and pre-gzipped listing.
  final Map<int, List<int>> _receptionContactCache = <int, List<int>>{};

  /// Cid:rid reception datas
  final Map<String, List<int>> _receptionDataCache = <String, List<int>>{};

  /**
   *
   */
  ContactCache(
      this._contactStore,
      Stream<event.ContactChange> contactChange,
      Stream<event.ReceptionData> receptionDataChange,
      Stream<event.ReceptionChange> receptionChange,
      Stream<event.OrganizationChange> organizationChange) {
    contactChange.listen((event.ContactChange e) {
      if (e.isUpdate || e.isDelete) {
        removeContact(e.cid);
      }

      emptyContactLists();
    });

    receptionDataChange.listen((event.ReceptionData change) {
      if (change.isDelete || change.isUpdate) {
        _receptionContactCache.remove(change.rid);
        _recListCache.remove(change.rid);
      }
    });

    receptionChange.listen((event.ReceptionChange change) {
      if (change.isDelete || change.isUpdate) {
        _receptionContactCache.remove(change.rid);
        _recListCache.remove(change.rid);
      }
    });

    organizationChange.listen((event.OrganizationChange change) {
      if (change.isDelete || change.isUpdate) {
        _orgListCache.remove(change.oid);
      }
    });
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
    _contactListCache = <int>[];
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
    _contactListCache = <int>[];
    _recListCache.clear();
    _orgListCache.clear();
    _receptionContactCache.clear();
  }

  /**
   *
   */
  Future<Null> prefill() async {
    final Iterable<model.BaseContact> contactList = await _contactStore.list();
    _contactListCache = serializeAndCompressObject(contactList);

    await Future.forEach(contactList, (model.BaseContact con) async {
      _contactCache[con.id] = serializeAndCompressObject(con);

      final Iterable<model.ReceptionReference> rRefs =
          await _contactStore.receptions(con.id);

      await Future.forEach(rRefs, (model.ReceptionReference rRef) async {
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
  Map<String, dynamic> get stats => <String, dynamic>{
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
  final Map<String, List<int>> _messageListCache = <String, List<int>>{};
  List<int> _draftListCache = <int>[];

  MessageCache(this._messageStore, Stream<event.MessageChange> messageChange) {
    messageChange.listen((event.MessageChange e) {
      final String key = e.createdAt.toIso8601String().split('T').first;
      _messageListCache.remove(key);

      if (e.messageState == model.MessageState.draft) {
        _draftListCache = <int>[];
      }
    });
  }

  /**
   *
   */
  Future<List<int>> list(DateTime day) async {
    final String key = day.toIso8601String().split('T').first;

    if (!_messageListCache.containsKey(key)) {
      final Iterable<model.Message> messages = await _messageStore.listDay(day);

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
  Future<List<int>> listDrafts() async {
    if (_draftListCache.isEmpty) {
      _draftListCache = new GZipEncoder()
          .encode(UTF8.encode(JSON.encode(await _messageStore.listDrafts())));
    }

    return _draftListCache;
  }

  /**
   *
   */
  Future<Null> prefill() async {}

  /**
   *
   */
  Map<String, dynamic> get stats => <String, dynamic>{
        'messageFolderCount': _messageListCache.length,
        'messageFolderSize': _messageListCache.values
            .fold(0, (int sum, List<int> bytes) => sum + bytes.length),
        'savedMessageSize': _draftListCache.length
      };
}

/**
 *
 */
class IvrMenuCache {
  final filestore.Ivr ivrStore;
  final Map<String, List<int>> _ivrCache = <String, List<int>>{};
  List<int> _ivrListCache = <int>[];

  IvrMenuCache(this.ivrStore, Stream<event.IvrMenuChange> ivrMenuChanges) {
    ivrMenuChanges.listen((event.IvrMenuChange changeEvent) {
      if (changeEvent.isDelete || changeEvent.isUpdate) {
        removeMenu(changeEvent.menuName);
      }

      clearListCache();
    });
  }

  /**
   *
   */
  void removeMenu(String name) {
    _ivrCache.remove(name);
  }

  /**
     *
     */
  void clearListCache() {
    _ivrListCache = <int>[];
  }

  /**
   *
   */
  Future<List<int>> list() async {
    if (_ivrCache.isEmpty) {
      final Iterable<model.IvrMenu> ivrs = await ivrStore.list();

      _ivrListCache = ivrs.isEmpty
          ? emptyGzipList
          : new GZipEncoder()
              .encode(UTF8.encode(JSON.encode(ivrs.toList(growable: false))));
    }

    return _ivrListCache;
  }

  /**
   *
   */
  Future<List<int>> get(String menuName) async {
    if (!_ivrCache.containsKey(menuName)) {
      final model.IvrMenu menu = await ivrStore.get(menuName);

      _ivrCache[menuName] =
          new GZipEncoder().encode(UTF8.encode(JSON.encode(menu)));
    }

    return _ivrCache[menuName];
  }

  /**
   *
   */
  Future<Null> emptyAll() async {
    _ivrCache.clear();
    clearListCache();
  }

  /**
   *
   */
  Future<Null> prefill() async {
    Iterable<model.IvrMenu> ivrs = await ivrStore.list();
    _ivrListCache = ivrs.isEmpty
        ? emptyGzipList
        : new GZipEncoder()
            .encode(UTF8.encode(JSON.encode(ivrs.toList(growable: false))));

    await Future.forEach(ivrs, (model.IvrMenu menu) async {
      await get(menu.name);
    });
  }

  /**
   *
   */
  Map<String, dynamic> get stats => <String, dynamic>{
        'ivrCount': _ivrCache.length,
        'ivrSize': _ivrCache.values
            .fold(0, (int sum, List<int> bytes) => sum + bytes.length),
        'ivrListSize': _ivrListCache.length
      };
}

/**
 *
 */
class DialplanCache {
  final filestore.ReceptionDialplan _rdpStore;
  final Map<String, List<int>> _dialplanCache = <String, List<int>>{};
  List<int> _dialplanListCache = <int>[];

  DialplanCache(this._rdpStore, Stream<event.DialplanChange> dialplanChanges) {
    dialplanChanges.listen((event.DialplanChange changeEvent) {
      if (changeEvent.isDelete || changeEvent.isUpdate) {
        removeDialplan(changeEvent.extension);
      }

      clearListCache();
    });
  }

  /**
   *
   */
  void removeDialplan(String dialplan) {
    _dialplanCache.remove(dialplan);
  }

  /**
     *
     */
  void clearListCache() {
    _dialplanListCache = <int>[];
  }

  /**
     *
     */
  Future<List<int>> list() async {
    if (_dialplanCache.isEmpty) {
      final Iterable<model.ReceptionDialplan> dialplans =
          await _rdpStore.list();

      _dialplanListCache = dialplans.isEmpty
          ? emptyGzipList
          : new GZipEncoder().encode(
              UTF8.encode(JSON.encode(dialplans.toList(growable: false))));
    }

    return _dialplanListCache;
  }

  /**
     *
     */
  Future<List<int>> get(String dialplan) async {
    if (!_dialplanCache.containsKey(dialplan)) {
      final model.ReceptionDialplan rdp = await _rdpStore.get(dialplan);

      _dialplanCache[dialplan] =
          new GZipEncoder().encode(UTF8.encode(JSON.encode(rdp)));
    }

    return _dialplanCache[dialplan];
  }

  /**
     *
     */
  Future<Null> emptyAll() async {
    _dialplanCache.clear();
    clearListCache();
  }

  /**
     *
     */
  Future<Null> prefill() async {
    Iterable<model.ReceptionDialplan> dialplans = await _rdpStore.list();
    _dialplanListCache = dialplans.isEmpty
        ? emptyGzipList
        : new GZipEncoder().encode(
            UTF8.encode(JSON.encode(dialplans.toList(growable: false))));

    await Future.forEach(dialplans, (model.ReceptionDialplan rdp) async {
      await get(rdp.extension);
    });
  }

  /**
     *
     */
  Map<String, dynamic> get stats => <String, dynamic>{
        'dialplanCount': _dialplanCache.length,
        'dialplanSize': _dialplanCache.values
            .fold(0, (int sum, List<int> bytes) => sum + bytes.length),
        'userListSize': _dialplanListCache.length
      };
}

class UserCache {
  final filestore.User _userStore;
  final Map<int, List<int>> _userCache = <int, List<int>>{};
  List<int> _userListCache = <int>[];

  /**
   *
   */
  UserCache(this._userStore, Stream<event.UserChange> userChanges) {
    userChanges.listen((event.UserChange changeEvent) {
      if (changeEvent.isDelete || changeEvent.isUpdate) {
        removeUid(changeEvent.uid);
      }

      clearListCache();
    });
  }

  /**
   *
   */
  void removeUid(int uid) {
    _userCache.remove(uid);
  }

  /**
   *
   */
  void clearListCache() {
    _userListCache = <int>[];
  }

  /**
   *
   */
  Future<List<int>> list() async {
    if (_userListCache.isEmpty) {
      final Iterable<model.UserReference> users = await _userStore.list();

      _userListCache = users.isEmpty
          ? emptyGzipList
          : new GZipEncoder()
              .encode(UTF8.encode(JSON.encode(users.toList(growable: false))));
    }

    return _userListCache;
  }

  /**
   *
   */
  Future<List<int>> get(int uid) async {
    if (!_userCache.containsKey(uid)) {
      final model.User user = await _userStore.get(uid);

      _userCache[uid] =
          new GZipEncoder().encode(UTF8.encode(JSON.encode(user)));
    }

    return _userCache[uid];
  }

  /**
   *
   */
  Future<Null> emptyAll() async {
    _userCache.clear();
    clearListCache();
  }

  /**
   *
   */
  Future<Null> prefill() async {
    Iterable<model.UserReference> users = await _userStore.list();
    _userListCache = users.isEmpty
        ? emptyGzipList
        : new GZipEncoder()
            .encode(UTF8.encode(JSON.encode(users.toList(growable: false))));

    await Future.forEach(users, (model.UserReference uRef) async {
      await get(uRef.id);
    });
  }

  /**
   *
   */
  Map<String, dynamic> get stats => <String, dynamic>{
        'userCount': _userCache.length,
        'userSize': _userCache.values
            .fold(0, (int sum, List<int> bytes) => sum + bytes.length),
        'userListSize': _userListCache.length
      };
}

class OrganizationCache {
  final Logger _log = new Logger('$_libraryName.CalendarCache');

  final filestore.Organization orgStore;

  final Map<int, List<int>> _organizationCache = <int, List<int>>{};
  List<int> _organizationListCache = <int>[];

  /**
   *
   */
  OrganizationCache(
      this.orgStore, Stream<event.OrganizationChange> organizationChange) {
    organizationChange.listen((event.OrganizationChange e) {
      if (e.isUpdate || e.isDelete) {
        remove(e.oid);
      }

      emptyList();
    });
  }

  /**
   *
   */
  void remove(int oid) {
    _organizationCache.remove(oid);
  }

  /**
   *
   */
  Future<List<int>> get(int oid) async {
    if (!_organizationCache.containsKey(oid)) {
      _log.finest('Key $oid not found in cache. Looking it up.');
      _organizationCache[oid] =
          serializeAndCompressObject(await orgStore.get(oid));
    }
    return _organizationCache[oid];
  }

  /**
   *
   */
  void removeEntry(int eid, model.Owner owner) {
    final String key = '$owner:$eid';
    _log.finest('Removing key $key from cache');
    _organizationCache.remove(key);
  }

  /**
   *
   */
  Future<List<int>> list() async {
    if (_organizationListCache.isEmpty) {
      _log.finest('Listing not found in cache. Looking it up.');

      _organizationListCache = serializeAndCompressObject(
          (await orgStore.list()).toList(growable: false));
    }

    return _organizationListCache;
  }

  /**
   *
   */
  Map<String, dynamic> get stats => <String, dynamic>{
        'organizationEntries': _organizationCache.length,
        'organizationSize': _organizationCache.values
            .fold(0, (int sum, List<int> bytes) => sum + bytes.length),
        'listSize': _organizationListCache.length
      };

  /**
   *
   */
  Future<Null> prefill() async {
    List<model.OrganizationReference> oRefs = await orgStore.list();

    _organizationListCache =
        serializeAndCompressObject(oRefs.toList(growable: false));

    await Future.forEach(oRefs, (model.OrganizationReference oRef) async {
      final model.Organization o = await orgStore.get(oRef.id);
      _organizationCache[o.id] = serializeAndCompressObject(o);
    });
  }

  /**
   *
   */
  void emptyList() {
    _organizationListCache = <int>[];
  }

  /**
   *
   */
  void emptyAll() {
    _organizationCache.clear();
    emptyList();
  }
}
