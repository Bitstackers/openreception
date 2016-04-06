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

part of openreception.server.controller.calendar;

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
    model.User modifier;
    try {
      modifier = await _authService.userOf(tokenFrom(request));
    } catch (e, s) {
      _log.warning('Could not connect to auth server', e, s);
      return authServerDown();
    }
    final model.CalendarEntry entry =
        model.CalendarEntry.decode(JSON.decode(await request.readAsString()));

    final model.CalendarEntry created =
        await _calendarStore.create(entry, modifier);

    event.CalendarChange changeEvent =
        new event.CalendarChange.create(created.id, entry.owner, modifier.id);

    _log.finest('User id:${modifier.id} created entry for ${entry.owner}');

    _notification.broadcastEvent(changeEvent);

    return okJson(created);
  }

  /**
   *
   */
  Future<shelf.Response> get(shelf.Request request) async {
    final int eid = int.parse(shelf_route.getPathParameter(request, 'eid'));

    try {
      return okJson(await _calendarStore.get(eid));
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
      return okJson(await _calendarStore.get(eid));
    } on storage.NotFound {
      return notFound('No event with id $eid');
    }
  }

  /**
   *
   */
  Future<shelf.Response> list(shelf.Request request) async {
    final String type = shelf_route.getPathParameter(request, 'type');
    final String oid = shelf_route.getPathParameter(request, 'oid');

    final model.Owner owner = new model.Owner.parse('$type:$oid');

    return okJson((await _calendarStore.list(owner)).toList(growable: false));
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

    model.CalendarEntry removed;
    try {
      removed = await _calendarStore.get(eid);
      await _calendarStore.remove(eid, modifier);
    } on storage.NotFound {
      return notFound('No entry with id $eid');
    }

    event.CalendarChange changeEvent =
        new event.CalendarChange.delete(removed.id, removed.owner, modifier.id);

    _log.finest('User id:${modifier.id} removed entry for ${removed.owner}');

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

    final model.CalendarEntry entry =
        model.CalendarEntry.decode(JSON.decode(await request.readAsString()));

    final model.CalendarEntry updated =
        await _calendarStore.update(entry, modifier);

    event.CalendarChange changeEvent =
        new event.CalendarChange.update(updated.id, updated.owner, modifier.id);

    _log.finest('User id:${modifier.id} updated entry for ${entry.owner}');

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

    final model.Owner owner = new model.Owner.parse('$type:$oid');

    return okJson(
        (await _calendarStore.changes(owner, eid)).toList(growable: false));
  }
}
