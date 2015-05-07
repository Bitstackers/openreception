part of callflowcontrol.router;

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