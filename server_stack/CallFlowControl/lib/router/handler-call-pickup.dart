part of callflowcontrol.router;

Map pickupOK (Model.Call call) => call.toJson();
    //{'status' : 'ok',
    // 'call'   : call};


Map<int,ORModel.UserState> userMap = {};

void handlerCallPickup(HttpRequest request) {

  String callID = pathParameterString(request.uri, "call");

  if (callID == null || callID == "") {
    clientError(request, "Empty call_id in path.");
    return;
  }
  final String context = '${libraryName}.handlerCallPickup';

  final String token   = request.uri.queryParameters['token'];

  bool aclCheck (ORModel.User user) => true;

  AuthService.userOf(token).then((ORModel.User user) {
    if (!aclCheck(user)) {
      forbidden(request, 'Insufficient privileges.');
      return;
    }

    try {
      if (!Model.PeerList.get (user.peer).registered) {
        clientError (request, "User with ${user.ID} has no peer available");
        return;
      }
    } catch (error) {
      clientError (request, "User with ${user.ID} has no peer available");
      logger.errorContext('Failed to lookup peer for user with ID ${user.ID}. Error : $error', context);
      return;
    }


    /// Park all the users calls.
    Future.forEach(Model.UserStatusList.instance.activeCallsAt(user.ID),
                   (Model.Call call) => call.park(user))
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

      /// Request the specified call.
      Model.Call assignedCall = Model.CallList.instance.requestSpecificCall (callID, user);

      logger.debugContext ('Assigned call ${assignedCall.ID} to user with ID ${user.ID}', context);

      /// Update the user state
      Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Receiving);

      Controller.PBX.transfer (assignedCall, user.peer).then((_) {
        assignedCall.assignedTo = user.ID;

        Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Speaking);

        writeAndClose(request, JSON.encode(pickupOK(assignedCall)));

      }).catchError((error, stackTrace) {
        Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Unknown);

        serverErrorTrace(request, error, stackTrace: stackTrace);
      });

    }).catchError((error, stackTrace) {
      Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Unknown);

      serverErrorTrace(request, error, stackTrace: stackTrace);
    });

  }).catchError((error, stackTrace) {
    if (error is Model.NotFound) {
      notFound (request, {'reason' : 'No calls available.'});
    } else {
      serverErrorTrace(request, error, stackTrace: stackTrace);
    }
  }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));
}

void handlerCallPickupNext(HttpRequest request) {

  const String context = '${libraryName}.handlerCallPickupNext';
  final String token   = request.uri.queryParameters['token'];

  bool aclCheck (ORModel.User user) => true;

  AuthService.userOf(token).then((ORModel.User user) {

    if (!aclCheck(user)) {
      forbidden(request, 'Insufficient privileges.');
      return;
    }

    try {
      if (!Model.PeerList.get (user.peer).registered) {
        clientError (request, "User with ${user.ID} has no peer available");
        return;
      }
    } catch (error) {
      clientError (request, "User with ${user.ID} has no peer available");
      logger.errorContext('Failed to lookup peer for user with ID ${user.ID}. Error : $error', context);
      return;
    }

    if (Model.UserStatusList.instance.get(user.ID).state == ORModel.UserState.Speaking) {
      clientError (request, "User with ${user.ID} is not ready for call.");
      logger.errorContext("User with ${user.ID} is not ready for call.", context);
      return;
    }

    /// Park all the users calls.
    Future.forEach(Model.UserStatusList.instance.activeCallsAt(user.ID),
                   (Model.Call call) => call.park(user))
      .whenComplete(() {

      /// Check user state
      String userState = Model.UserStatusList.instance.get(user.ID).state;
      if (!ORModel.UserState.phoneIsReady(userState)) {
        clientError(request, 'Phone is not ready.');
        return;
      }

      /// Get the next available call.
      Model.Call assignedCall = Model.CallList.instance.requestCall (user);

      logger.debugContext ('Assigned call ${assignedCall.ID} to user with ID ${user.ID}', context);

      /// Update the user state
      Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Receiving);

      Controller.PBX.transfer (assignedCall, user.peer).then((_) {
        assignedCall.assignedTo = user.ID;

        Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Speaking);

        writeAndClose(request, JSON.encode(pickupOK(assignedCall)));

      }).catchError((error, stackTrace) {
        Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Unknown);

        serverErrorTrace(request, error, stackTrace: stackTrace);
      });

    }).catchError((error, stackTrace) {
      Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Unknown);

      serverErrorTrace(request, error, stackTrace: stackTrace);
    });

  }).catchError((error, stackTrace) {
    if (error is Model.NotFound) {
      notFound (request, {'reason' : 'No calls available.'});
    } else {
      serverErrorTrace(request, error, stackTrace: stackTrace);
    }
  }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));
}
