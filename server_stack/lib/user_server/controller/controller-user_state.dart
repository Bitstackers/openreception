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

part of openreception.user_server.controller;

class UserState {
  final Logger _log = new Logger('${_libraryName}.UserState');

  final model.AgentHistory _history;
  final model.UserStatusList _userStateList;

  UserState(this._history, this._userStateList);

  shelf.Response stats(shelf.Request request) {
    return new shelf.Response.ok(JSON.encode(_history));
  }

  shelf.Response list(shelf.Request request) {
    return new shelf.Response.ok(JSON.encode(_userStateList));
  }

  shelf.Response get(shelf.Request request) {
    final int userID = int.parse(shelf_route.getPathParameter(request, 'uid'));

    if (!_userStateList.has(userID)) {
      return new shelf.Response.notFound('{}');
    }

    return new shelf.Response.ok(
        JSON.encode(_userStateList.getOrCreate(userID)));
  }

  shelf.Response set(shelf.Request request) {
    final int userID = int.parse(shelf_route.getPathParameter(request, 'uid'));
    final String newState = shelf_route.getPathParameter(request, 'state');

    if (newState == model.UserState.Paused) {
      return new shelf.Response.ok(JSON.encode(_userStateList.pause(userID)));
    } else if (newState == model.UserState.Ready) {
      return new shelf.Response.ok(JSON.encode(_userStateList.ready(userID)));
    } else {
      return _serverError('Unknown state $newState');
    }
  }
}
