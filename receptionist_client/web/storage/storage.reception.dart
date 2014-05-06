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
  static Map<int, model.Reception> _receptionCache = new Map<int, model.Reception>();
  static Map<int, model.CalendarEvent> _calendarCache = new Map<int, model.CalendarEvent>();

  /**
   * Retrieved a single [model.Reception] - identified by [id] from the
   * cache - or from the remote storage.
   *
   * Completes with
   *  On success   : the [id] [model.Reception]
   *  
   *  Throws errors propagating from the service layer.
   */
  static Future<model.Reception> get(int id) {

    const String context = '${libraryName}.get';

    final Completer completer = new Completer<model.Reception>();

    if (_receptionCache.containsKey(id)) {
      debug("Loading reception from cache.", context);
      completer.complete(_receptionCache[id]);
    } else {
      debug("Reception not found in cache, loading from http.", context);
      Service.Reception.get(id).then((model.Reception reception) {
        // Store the reception in the cache.
        _receptionCache[reception.ID] = reception;
        completer.complete(reception);
      }).catchError((error) {
        completer.completeError(error);
      });
    }

    return completer.future;
  }

  /**
   * Get the [ReceptionList].
   *
   * Completes with
   *  On success : the [ReceptionList]
   *  On error   : an error message
   */
  static Future<model.ReceptionList> list() {
    final Completer completer = new Completer<model.ReceptionList>();

    protocol.getReceptionList().then((protocol.Response response) {
      switch (response.status) {
        case protocol.Response.OK:
          completer.complete(response.data);
          break;

        default:
          completer.completeError('storage.getReceptionList ERROR failed with ${response}');
      }
    }).catchError((error) {
      completer.completeError('storage.getReceptionList ERROR protocol.getReceptionList failed with ${error}');
    });

    return completer.future;
  }

  /**
   * Retrives the [model.calendarList].
   *
   */
  static Future<model.CalendarEventList> calendar(int receptionID) {
    const String context = '${libraryName}.get';

    final Completer completer = new Completer<model.Reception>();

    if (_calendarCache.containsKey(receptionID)) {
      debug("Loading calendar from cache.", context);
      completer.complete(_calendarCache[receptionID]);
    } else {
      debug("Reception not found in cache, loading from http.", context);
      Service.Reception.calendar(id).then((model.CalendarEventList eventList) {
        _calendarCache[receptionID] = reception;
        completer.complete(eventList);
      }).catchError((error) {
        completer.completeError(error);
      });
    }

    return completer.future;
  }

}
