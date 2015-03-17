part of callflowcontrol.router;

abstract class UserState {

  final String className = '${libraryName}.UserState';

  static void list(HttpRequest request) {
    writeAndClose(request, JSON.encode(Model.UserStatusList.instance));
  }

  static void get(HttpRequest request) {
    final int    userID = pathParameter(request.uri, 'userstate');

    writeAndClose(request, JSON.encode(Model.UserStatusList.instance.get(userID)));
  }

  static void markIdle(HttpRequest request) {

    final int    userID = pathParameter(request.uri, 'userstate');
    final String  token = request.uri.queryParameters['token'];

    bool aclCheck (ORModel.User user) => user.ID == userID;

    AuthService.userOf(token).then((ORModel.User user) {

      if (!aclCheck(user)) {
        forbidden(request, 'Insufficient privileges.');
        return;
      }

      /// Check user state. If the user is currently performing an action - or
      /// has an active channel - deny the request.
      String userState    = Model.UserStatusList.instance.get(user.ID).state;

      bool   inTransition = ORModel.UserState.TransitionStates.contains(userState);
      bool   hasChannels  = Model.ChannelList.instance.hasActiveChannels(user.peer);

      if (inTransition || hasChannels) {
        clientError(request, 'Phone is not ready. state:{$userState}, hasChannels:{$hasChannels}');
        return;
      }

      Model.UserStatusList.instance.update(userID, ORModel.UserState.Idle);

      writeAndClose(request, JSON.encode(Model.UserStatusList.instance.get(userID)));
    }).catchError((error, stackTrace)
        => serverErrorTrace(request, error, stackTrace: stackTrace));
  }

  static void markPaused(HttpRequest request) {

    final int    userID = pathParameter(request.uri, 'userstate');
    final String  token = request.uri.queryParameters['token'];

    bool aclCheck (ORModel.User user) => user.ID == userID;

    AuthService.userOf(token).then((ORModel.User user) {

      if (!aclCheck(user)) {
        forbidden(request, 'Insufficient privileges.');
        return;
      }

      /// Check user state. If the user is currently performing an action - or
      /// has an active channel - deny the request.
      String userState    = Model.UserStatusList.instance.get(user.ID).state;

      bool   inTransition = ORModel.UserState.TransitionStates.contains(userState);
      bool   hasChannels  = Model.ChannelList.instance.hasActiveChannels(user.peer);

      if (inTransition || hasChannels) {
        clientError(request, 'Phone is not ready. state:{$userState}, hasChannels:{$hasChannels}');
        return;
      }

      Model.UserStatusList.instance.update(userID, ORModel.UserState.Paused);

      writeAndClose(request, JSON.encode(Model.UserStatusList.instance.get(userID)));
    }).catchError((error, stackTrace)
        => serverErrorTrace(request, error, stackTrace: stackTrace));
  }
}