/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of storage;


abstract class Reception {

  /* Local cache objects. */
  static List<Model.ReceptionStub> _receptionListCache  = [];
  static Map<int, Model.Reception> _receptionCache      = {};
  static Map<int, List<Model.CalendarEvent>> _calendarCache = {};

  /**
   * Removes the cached calendar.
   */
  static void invalidateCalendar (int receptionID) {
    if (_calendarCache.containsKey(receptionID)) {
      _calendarCache.remove(receptionID);
    }
  }

  /**
   * Retrieved a single [Model.Reception] - identified by [id] from the
   * cache - or from the remote storage.
   *
   * Completes with
   *  On success   : the [id] [Model.Reception]
   *
   *  Throws errors propagating from the service layer.
   */
  static Future<Model.Reception> get(int id) {

    const String context = '${libraryName}.get';

    final Completer completer = new Completer<Model.Reception>();

    if (_receptionCache.containsKey(id)) {
      debugStorage("Loading reception from cache.", context);
      completer.complete(_receptionCache[id]);
    } else {
      debugStorage("Reception not found in cache, loading from http.", context);
      Service.Reception.store.getMap(id).then((Map receptionMap) {
        // Store the reception in the cache.
        Model.Reception reception = new Model.Reception.fromMap(receptionMap);
        _receptionCache[reception.ID] = reception;
        completer.complete(_receptionCache[reception.ID]);
      }).catchError((error) {
        completer.completeError(error);
      });
    }

    return completer.future;
  }

  /**
   * Get the [ReceptionStubList].
   *
   * Completes with
   *  On success : the [ReceptionStubList]
   *  On error   : an error message
   */
  static Future<List<Model.ReceptionStub>> list() {

    const String context = '${libraryName}.list';

    final Completer completer = new Completer<List<Model.ReceptionStub>>();

    if (_receptionListCache.isNotEmpty) {
      debugStorage("Loading receptionList from cache.", context);
      completer.complete(_receptionListCache);
    } else {
      debugStorage("Reception not found in cache, loading from http.", context);
      Service.Reception.store.listMap().then((List<Map> receptionMapList) {
        // Store the reception in the cache.
        List<Model.ReceptionStub> receptionList =
            receptionMapList.map((Map receptionStubMap)
                => new Model.ReceptionStub.fromMap(receptionStubMap)).toList();

        _receptionListCache = receptionList;

        completer.complete(_receptionListCache);
      }).catchError((error) {
        completer.completeError(error);
      });
    }

    return completer.future;
  }

  /**
   * Retrives the [model.calendarList].
   *
   */
  static Future<List<Model.CalendarEvent>> calendar(int receptionID) {
    const String context = '${libraryName}.get';

    final Completer completer = new Completer<List<Model.CalendarEvent>>();

    if (_calendarCache.containsKey(receptionID)) {
      debugStorage("Loading calendar from cache.", context);
      completer.complete(_calendarCache[receptionID]);
    } else {
      debugStorage("Reception not found in cache, loading from http.", context);

      Service.Reception.store.calendarMap(receptionID).then((List<Map> eventList) {
        _calendarCache[receptionID] = eventList.map((Map eventMap)
            => new Model.CalendarEvent.fromMap(eventMap, receptionID)).toList();
        completer.complete(_calendarCache[receptionID]);
      }).catchError((error) {
        completer.completeError(error);
      });
    }

    return completer.future;
  }

}
