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

part of openreception.user_server.controller;

class User {
  static final Logger log = new Logger('$_libraryName.User');

  final filestore.User _userStore;
  final service.Authentication _authservice;
  final service.NotificationService _notification;

  User(this._userStore, this._notification, this._authservice);

  /**
   * HTTP Request handler for returning a single user resource.
   */
  Future<shelf.Response> get(shelf.Request request) async {
    final int uid = int.parse(shelf_route.getPathParameter(request, 'uid'));

    try {
      return okJson(await _userStore.get(uid));
    } on storage.NotFound catch (e) {
      return notFound(e.toString());
    }
  }

  /**
   * HTTP Request handler for returning a all user resources.
   */
  Future<shelf.Response> list(shelf.Request request) async =>
      okJson((await _userStore.list()).toList(growable: false));

  /**
   * HTTP Request handler for removing a single user resource.
   */
  Future<shelf.Response> remove(shelf.Request request) async {
    final int uid = int.parse(shelf_route.getPathParameter(request, 'uid'));
    model.User modifier;

    try {
      modifier = await _authservice.userOf(tokenFrom(request));
    } catch (e) {
      return authServerDown();
    }

    try {
      await _userStore.remove(uid, modifier);
      _notification
          .broadcastEvent(new event.UserChange.deleted(uid, modifier.id));

      return okJson({'status': 'ok', 'description': 'User deleted'});
    } on storage.NotFound {
      return notFoundJson({'description': 'No user found with id $uid'});
    }
  }

  /**
   * HTTP Request handler for creating a single user resource.
   */
  Future<shelf.Response> create(shelf.Request request) async {
    model.User user;
    model.User creator;
    try {
      user = await request
          .readAsString()
          .then(JSON.decode)
          .then(model.User.decode);
    } on FormatException catch (error) {
      Map response = {
        'status': 'bad request',
        'description': 'passed user argument '
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

    final uRef = await _userStore.create(user, creator);
    _notification
        .broadcastEvent(new event.UserChange.created(uRef.id, creator.id));
    return okJson(uRef);
  }

  /**
   * HTTP Request handler for updating a single user resource.
   */
  Future<shelf.Response> update(shelf.Request request) async {
    model.User user;
    model.User modifier;
    try {
      user = await request
          .readAsString()
          .then(JSON.decode)
          .then(model.User.decode);
    } on FormatException catch (error) {
      Map response = {
        'status': 'bad request',
        'description': 'passed user argument '
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
      final uRef = await _userStore.update(user, modifier);
      _notification
          .broadcastEvent(new event.UserChange.updated(uRef.id, modifier.id));
      return okJson(uRef);
    } on storage.Unchanged {
      return clientError('Unchanged');
    } on storage.NotFound catch (e) {
      return notFound(e.toString());
    } on storage.ClientError catch (e) {
      return clientError(e.toString());
    }
  }

  /**
   * Response handler for the user of an identity.
   */
  Future<shelf.Response> userIdentity(shelf.Request request) async {
    String identity = shelf_route.getPathParameter(request, 'identity');
    String domain = shelf_route.getPathParameter(request, 'domain');

    if (domain != null) {
      identity = domain.isEmpty ? identity : '$identity@$domain';
    }

    try {
      return _okJson(await _userStore.getByIdentity(identity));
    } on storage.NotFound catch (error) {
      _notFound(error.toString());
    }
  }

  /**
   * List every available group in the store.
   */
  Future<shelf.Response> groups(shelf.Request request) async =>
      okJson((await _userStore.groups()).toList(growable: false));
}
