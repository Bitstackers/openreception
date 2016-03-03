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

part of openreception.reception_server.controller;

class Reception {
  final Logger _log = new Logger('$_libraryName.Reception');
  final filestore.Reception _rStore;
  final service.Authentication _authservice;
  final service.NotificationService _notification;

  /**
   * Default constructor.
   */
  Reception(this._rStore, this._notification, this._authservice);

  /**
   *
   */
  Future<shelf.Response> list(shelf.Request request) async =>
      okJson((await _rStore.list()).toList(growable: false));

  /**
   *
   */
  Future<shelf.Response> getByExtension(shelf.Request request) async {
    final String exten = shelf_route.getPathParameter(request, 'exten');

    try {
      final r = await _rStore.getByExtension(exten);
      print(r.toJson());
      return okJson(r);
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
    _notification
        .broadcastEvent(new event.ReceptionChange.created(rRef.id, creator.id));
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
      _notification.broadcastEvent(
          new event.ReceptionChange.updated(rRef.id, modifier.id));
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
      _notification
          .broadcastEvent(new event.ReceptionChange.deleted(rid, modifier.id));

      return okJson({'status': 'ok', 'description': 'Reception deleted'});
    } on storage.NotFound {
      return notFoundJson({'description': 'No reception found with ID $rid'});
    }
  }
}
