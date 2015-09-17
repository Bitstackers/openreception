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

part of openreception.call_flow_control_server.router;

abstract class UserState {

  final String className = '${libraryName}.UserState';

  static shelf.Response list(shelf.Request request) {
    return new shelf.Response.ok(JSON.encode(Model.UserStatusList.instance));
  }

  static shelf.Response get(shelf.Request request) {
    final int    userID = int.parse(shelf_route.getPathParameter(request, 'uid'));

    if (!Model.UserStatusList.instance.has(userID)) {
      return new shelf.Response.notFound ('{}');
    }

    return new shelf.Response.ok(JSON.encode(Model.UserStatusList.instance.getOrCreate(userID)));
  }

  static Future<shelf.Response> markIdle(shelf.Request request) {

    final int    userID = int.parse(shelf_route.getPathParameter(request, 'uid'));
    final String  token = request.requestedUri.queryParameters['token'];

    bool aclCheck (ORModel.User user) => user.ID == userID;

    return AuthService.userOf(token).then((ORModel.User user) {

      if (!aclCheck(user)) {
        return new shelf.Response.forbidden('Insufficient privileges.');
      }

      /// Check user state. If the user is currently performing an action - or
      /// has an active channel - deny the request.
      String userState    = Model.UserStatusList.instance.getOrCreate(user.ID).state;

      bool   inTransition = ORModel.UserState.TransitionStates.contains(userState);
      bool   hasChannels  = Model.ChannelList.instance.hasActiveChannels(user.peer);

      if (inTransition || hasChannels) {
        return new shelf.Response(400, body : 'Phone is not ready. '
          'state:{$userState}, hasChannels:{$hasChannels}');
      }

      Model.UserStatusList.instance.update(userID, ORModel.UserState.Idle);

      return new shelf.Response.ok(JSON.encode(Model.UserStatusList.instance.getOrCreate(userID)));
    }).catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError();
   });
  }

  static Future<shelf.Response> markPaused(shelf.Request request) {

    final int    userID = int.parse(shelf_route.getPathParameter(request, 'uid'));
    final String  token = request.requestedUri.queryParameters['token'];

    bool aclCheck (ORModel.User user) => user.ID == userID;

    return AuthService.userOf(token).then((ORModel.User user) {

      if (!aclCheck(user)) {
        return new shelf.Response.forbidden('Insufficient privileges.');
      }

      /// Check user state. If the user is currently performing an action - or
      /// has an active channel - deny the request.
      String userState    = Model.UserStatusList.instance.getOrCreate(user.ID).state;

      bool   inTransition = ORModel.UserState.TransitionStates.contains(userState);
      bool   hasChannels  = Model.ChannelList.instance.hasActiveChannels(user.peer);

      if (inTransition || hasChannels) {
        return new shelf.Response(400, body : 'Phone is not ready. '
          'state:{$userState}, hasChannels:{$hasChannels}');
      }

      Model.UserStatusList.instance.update(userID, ORModel.UserState.Paused);

      return new shelf.Response.ok(JSON.encode(Model.UserStatusList.instance.getOrCreate(userID)));
    }).catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError();
    });
  }

  static Future<shelf.Response> keepAlive(shelf.Request request) {
    final int    userID = int.parse(shelf_route.getPathParameter(request, 'uid'));
    final String  token = request.requestedUri.queryParameters['token'];

    bool aclCheck (ORModel.User user) => user.ID == userID;

    return AuthService.userOf(token).then((ORModel.User user) {

      if (!aclCheck(user)) {
        return new shelf.Response.forbidden('Insufficient privileges.');
      }

      /// Bump last-seen timestamp.
      try {
        Model.UserStatusList.instance.updatetimeStamp(userID);
      } on ORStorage.NotFound catch (_) {
        return new shelf.Response(400, body : 'No state for user, mark idle.');
      }

      return new shelf.Response.ok('{}');
    }).catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError();
    });
  }

  static Future<shelf.Response> logOut(shelf.Request request) {

    final int    userID = int.parse(shelf_route.getPathParameter(request, 'uid'));
    final String  token = request.requestedUri.queryParameters['token'];

    bool aclCheck (ORModel.User user) => user.ID == userID;

    return AuthService.userOf(token).then((ORModel.User user) {

      if (!aclCheck(user)) {
        return new shelf.Response.forbidden('Insufficient privileges.');
      }

      /// Check user state. If the user is currently performing an action - or
      /// has an active channel - deny the request.
      String userState    = Model.UserStatusList.instance.getOrCreate(user.ID).state;

      bool   inTransition = ORModel.UserState.TransitionStates.contains(userState);
      bool   hasChannels  = Model.ChannelList.instance.hasActiveChannels(user.peer);

      if (inTransition || hasChannels) {
        return new shelf.Response(400, body : 'Phone is not ready. '
          'state:{$userState}, hasChannels:{$hasChannels}');
      }

      Model.UserStatusList.instance.logout(userID);
      Model.UserStatusList.instance.remove(userID);


      return new shelf.Response.ok(JSON.encode(Model.UserStatusList.instance.getOrCreate(userID)));
    }).catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError();
    });
  }
}