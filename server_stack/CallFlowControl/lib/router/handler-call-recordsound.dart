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
  bool aclCheck (ORModel.User user) => true;

  bool validExtension (String extension) => extension != null && extension.length > 1;

  AuthService.userOf(token).then((ORModel.User user) {
    if (!aclCheck(user)) {
      forbidden(request, 'Insufficient privileges.');
      return;
    }


    /// Park all the users calls.
    Future.forEach(Model.CallList.instance.callsOf(user.ID).where
      ((Model.Call call) => call.state == Model.CallState.Speaking), (Model.Call call) => call.park(user))
      .whenComplete(() {

      /// Check user state. If the user is currently performing an action - or
      /// has an active channel - deny the request.
      String userState    = Model.UserStatusList.instance.get(user.ID).state;

      bool   inTransition = ORModel.UserState.TransitionStates.contains(userState);
      bool   hasChannels  = Model.ChannelList.instance.hasActiveChannels(user.peer);

      if (inTransition || hasChannels) {
        clientError(request, 'Phone is not ready. state:{$userState}, hasChannels:{$hasChannels}');
        return;
      }

      /// Update the user state
      Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Receiving);

      Controller.PBX.originateRecording (receptionID, recordExtension, recordPath, user)
        .then ((String channelUUID) {

          Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Speaking);

          writeAndClose(request, JSON.encode(orignateOK(channelUUID)));

      }).catchError((error, stackTrace) {
        Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Unknown);

        serverErrorTrace(request, error, stackTrace: stackTrace);
      });

    }).catchError((error, stackTrace) {
      Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Unknown);

      serverErrorTrace(request, error, stackTrace: stackTrace);
    });

  }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));
}
