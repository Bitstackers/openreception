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

      // States that are okay to transfer to idle from.
      List validStates = [ORModel.UserState.Unknown,
                              ORModel.UserState.Paused]..addAll(ORModel.UserState.PhoneReadyStates);

      /// Check user state. We allow the user manually change state from unknown.
      String userState = Model.UserStatusList.instance.get(user.ID).state;
      if (!validStates.contains(userState)) {
        clientError(request, 'Phone is not ready.');
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

      // States that are okay to transfer to paused from.
      List validStates = [ORModel.UserState.Unknown]..addAll(ORModel.UserState.PhoneReadyStates);

      /// Check user state. We allow the user manually change state from unknown.
      String userState = Model.UserStatusList.instance.get(user.ID).state;
      if (!validStates.contains(userState)) {
        clientError(request, 'Phone is not ready.');
        return;
      }

      Model.UserStatusList.instance.update(userID, ORModel.UserState.Paused);

      writeAndClose(request, JSON.encode(Model.UserStatusList.instance.get(userID)));
    }).catchError((error, stackTrace)
        => serverErrorTrace(request, error, stackTrace: stackTrace));
  }
}