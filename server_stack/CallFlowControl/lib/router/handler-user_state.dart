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

    bool aclCheck (User user) => user.ID == userID;

    AuthService.userOf(token).then((User user) {

      if (!aclCheck(user)) {
        forbidden(request, 'Insufficient privileges.');
        return;
      }


      /// Check user state. We allow the user manually change state from unknown.
      String userState = Model.UserStatusList.instance.get(user.ID).state;
      if (userState != Model.UserState.Unknown &&
          !Model.UserState.phoneIsReady(userState)) {
        clientError(request, 'Phone is not ready.');
        return;
      }

      Model.UserStatusList.instance.update(userID, Model.UserState.Idle);

      writeAndClose(request, JSON.encode(Model.UserStatusList.instance.get(userID)));
    }).catchError((error, stackTrace)
        => serverErrorTrace(request, error, stackTrace: stackTrace));
  }

}