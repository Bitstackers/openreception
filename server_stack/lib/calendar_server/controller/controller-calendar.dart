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

part of openreception.calendar_server.controller;

/**
 * Ivr menu controller class.
 */
class Calendar {
  final database.Calendar _calendarStore;
  final service.Authentication _authService;
  final service.NotificationService _notification;
  final Logger _log = new Logger('$_libraryName.Calendar');

  /**
   *
   */
  Calendar(this._calendarStore, this._authService, this._notification);

  /**
   *
   */
  Future<shelf.Response> create(shelf.Request request) async {
    final model.User user = await _authService.userOf(_tokenFrom(request));
    final model.CalendarEntry entry =
        model.CalendarEntry.decode(JSON.decode(await request.readAsString()));

    final model.CalendarEntry created =
        await _calendarStore.create(entry, user.id);

    event.CalendarChange changeEvent = new event.CalendarChange(created.ID,
        entry.contactID, entry.receptionID, event.CalendarEntryState.CREATED);

    _log.finest('User id:${user.id} created entry for ${entry.owner}');

    _notification.broadcastEvent(changeEvent);

    return _okJson(created);
  }

  /**
   *
   */
  Future<shelf.Response> get(shelf.Request request) async {
    final int eid = int.parse(shelf_route.getPathParameter(request, 'eid'));

    try {
      return _okJson(await _calendarStore.get(eid));
    } on storage.NotFound {
      return _notFound('No event with id $eid');
    }
  }

  /**
   *
   */
  Future<shelf.Response> getDeleted(shelf.Request request) async {
    final int eid = int.parse(shelf_route.getPathParameter(request, 'eid'));

    try {
      return _okJson(await _calendarStore.get(eid, deleted: true));
    } on storage.NotFound {
      return _notFound('No event with id $eid');
    }
  }

  /**
   *
   */
  Future<shelf.Response> list(shelf.Request request) async {
    final String type = shelf_route.getPathParameter(request, 'type');
    final String oid = shelf_route.getPathParameter(request, 'oid');

    final model.Owner owner = new model.Owner.parse('$type:$oid');

    return _okJson((await _calendarStore.list(owner)).toList(growable: false));
  }

  /**
   *
   */
  Future<shelf.Response> listDeleted(shelf.Request request) async {
    final String type = shelf_route.getPathParameter(request, 'type');
    final String oid = shelf_route.getPathParameter(request, 'oid');

    final model.Owner owner = new model.Owner.parse('$type:$oid');

    return _okJson((await _calendarStore.list(owner, deleted: true))
        .toList(growable: false));
  }

  /**
   *
   */
  Future<shelf.Response> remove(shelf.Request request) async {
    final model.User user = await _authService.userOf(_tokenFrom(request));

    final int eid = int.parse(shelf_route.getPathParameter(request, 'eid'));

    model.CalendarEntry removed;
    try {
      removed = await _calendarStore.get(eid);
      await _calendarStore.remove(eid, user.id);
    } on storage.NotFound {
      return _notFound('No entry with id $eid');
    }

    event.CalendarChange changeEvent = new event.CalendarChange(
        removed.ID,
        removed.contactID,
        removed.receptionID,
        event.CalendarEntryState.DELETED);

    _log.finest('User id:${user.ID} removed entry for ${removed.owner}');

    _notification.broadcastEvent(changeEvent);

    return _okJson('{}');
  }

  /**
   *
   */
  Future<shelf.Response> purge(shelf.Request request) async {
    final int eid = int.parse(shelf_route.getPathParameter(request, 'eid'));

    return _okJson(await _calendarStore.purge(eid));
  }

  /**
   *
   */
  Future<shelf.Response> update(shelf.Request request) async {
    final model.User user = await _authService.userOf(_tokenFrom(request));

    final model.CalendarEntry entry =
        model.CalendarEntry.decode(JSON.decode(await request.readAsString()));

    final model.CalendarEntry updated =
        await _calendarStore.update(entry, user.ID);

    event.CalendarChange changeEvent = new event.CalendarChange(updated.ID,
        entry.contactID, entry.receptionID, event.CalendarEntryState.UPDATED);

    _log.finest('User id:${user.ID} updated entry for ${entry.owner}');

    _notification.broadcastEvent(changeEvent);

    return _okJson(updated);
  }

  /**
   *
   */
  Future<shelf.Response> changeLatest(shelf.Request request) async {
    final int eid = int.parse(shelf_route.getPathParameter(request, 'eid'));

    return _okJson(await _calendarStore.latestChange(eid));
  }

  /**
   *
   */
  Future<shelf.Response> changes(shelf.Request request) async {
    final int eid = int.parse(shelf_route.getPathParameter(request, 'eid'));

    return _okJson((await _calendarStore.changes(eid)).toList(growable: false));
  }
}
