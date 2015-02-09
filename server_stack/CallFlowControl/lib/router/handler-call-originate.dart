part of callflowcontrol.router;

Map orignateOK (channelUUID) =>
    {'status'      : 'ok',
     'call'        : {'id' : channelUUID},
     'description' : 'Connecting...'};

void handlerCallOrignate(HttpRequest request) {

  const String context = '${libraryName}.handlerCallOrignate';

  final int    receptionID = pathParameter(request.uri, 'reception');
  final int    contactID   = pathParameter(request.uri, 'contact');
  final String extension   = pathParameterString(request.uri, 'originate');
  final String token       = request.uri.queryParameters['token'];

  logger.debugContext ('Originating to ${extension} in context ${contactID}@${receptionID}', context);

  /// Any authenticated user is allowed to originate new calls.
  bool aclCheck (ORModel.User user) => true;

  bool validExtension (String extension) => extension != null && extension.length > 1;

  AuthService.userOf(token).then((ORModel.User user) {
    if (!aclCheck(user)) {
      forbidden(request, 'Insufficient privileges.');
      return;
    }

    if (!validExtension(extension)) {
      clientError(request, 'Invalid extension: $extension');
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
        Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Dialing);

        /// Perform the origination via the PBX.
        Controller.PBX.originate (extension, contactID, receptionID, user)
          .then ((String channelUUID) {

          /// Update the user state
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
