part of callflowcontrol.router;

void handlerCallRecordSound(HttpRequest request) {

  const String context = '${libraryName}.handlerCallOrignate';
  const String recordExtension = 'slowrecordmenu';

  int    receptionID;
  String recordPath;
  String token;

  try {
    receptionID = pathParameter(request.uri, 'reception');
    recordPath  = request.uri.queryParameters['recordpath'];
    token       = request.uri.queryParameters['token'];
  } catch(error, stack) {
    clientError(request, 'Parameter error. ${error} ${stack}');
  }

  if(recordPath == null) {
    clientError(request, 'Missing parameter "recordpath".');
    return;
  }

  logger.debugContext ('Originating to ${recordExtension} with path ${recordPath} for reception ${receptionID}', context);

  /// Any authenticated user is allowed to originate new calls.
  bool aclCheck (User user) => true;

  bool validExtension (String extension) => extension != null && extension.length > 1;

  AuthService.userOf(token).then((User user) {
    if (!aclCheck(user)) {
      forbidden(request, 'Insufficient privileges.');
      return;
    }


    /// Park all the users calls.
    Future.forEach(Model.CallList.instance.callsOf(user.ID).where
      ((Model.Call call) => call.state == Model.CallState.Speaking), (Model.Call call) => call.park(user))
      .whenComplete(() {

      /// Check user state
      String userState = Model.UserStatusList.instance.get(user.ID).state;
      if (!Model.UserState.phoneIsReady(userState)) {
        clientError(request, 'Phone is not ready.');
        return;
      }

      /// Update the user state
      Model.UserStatusList.instance.update(user, Model.UserState.Receiving);

      Controller.PBX.originateRecording (receptionID, recordExtension, recordPath, user)
        .then ((String channelUUID) {

          Model.UserStatusList.instance.update(user, Model.UserState.Speaking);

          writeAndClose(request, JSON.encode(orignateOK(channelUUID)));

      }).catchError((error, stackTrace) {
        Model.UserStatusList.instance.update(user, Model.UserState.Idle);

        serverErrorTrace(request, error, stackTrace: stackTrace);
      });

    }).catchError((error, stackTrace) {
      Model.UserStatusList.instance.update(user.ID, Model.UserState.Unknown);

      serverErrorTrace(request, error, stackTrace: stackTrace);
    });

  }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));
}
