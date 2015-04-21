part of callflowcontrol.router;


/// Reply templates.
Map hangupCallIDOK(callID) => {
  'status': 'ok',
  'description': 'Request to hang up ${callID} sent.'
};

Map hangupCommandOK(peerID) => {
  'status': 'ok',
  'description': 'Request for ${peerID} to hang up sent.'
};

Map orignateOK(channelUUID) => {
  'status': 'ok',
  'call': {
    'id': channelUUID
  },
  'description': 'Connecting...'
};

Map parkOK(Model.Call call) => {
  'status': 'ok',
  'message': 'call parked',
  'call': call
};


Map pickupOK(Model.Call call) => call.toJson();

Map<int, ORModel.UserState> userMap = {};

abstract class Call {

  static void get(HttpRequest request) {
    String callID = pathParameterString(request.uri, 'call');

    try {
      Model.Call call = Model.CallList.instance.get(callID);
      writeAndClose(request, JSON.encode(call));
    } catch (error, stackTrace) {
      if (error is Model.NotFound) {
        notFound(request, {});
      } else {
        serverErrorTrace(request, error, stackTrace: stackTrace);
      }
    }
  }

  static void hangup(HttpRequest request) {

    final String token = request.uri.queryParameters['token'];

    bool aclCheck(ORModel.User user) => true;

    AuthService.userOf(token).then((ORModel.User user) {

      if (!aclCheck(user)) {
        forbidden(request, 'Insufficient privileges.');
        return;
      }

      try {
        ESL.Peer peer = Model.PeerList.get(user.peer);

        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.HangingUp);

        Controller.PBX.hangupCommand(peer).then((_) {

          Model.UserStatusList.instance.update(
              user.ID,
              ORModel.UserState.HandlingOffHook);

          writeAndClose(request, JSON.encode(hangupCommandOK(peer.ID)));

        }).catchError((error, stackTrace) {
          Model.UserStatusList.instance.update(
              user.ID,
              ORModel.UserState.Unknown);
          serverErrorTrace(request, error, stackTrace: stackTrace);

        });

      } catch (error, stackTrace) {
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.Unknown);
        serverErrorTrace(request, error, stackTrace: stackTrace);
      }
    }).catchError(
        (error, stackTrace) =>
            serverErrorTrace(request, error, stackTrace: stackTrace));
  }

  static void hangupSpecific(HttpRequest request) {

    final String callID = pathParameterString(request.uri, 'call');
    final String token = request.uri.queryParameters['token'];

    List<String> hangupGroups = ['Administrator'];

    bool aclCheck(ORModel.User user) =>
        user.groups.any(hangupGroups.contains) ||
            Model.CallList.instance.get(callID).assignedTo == user.ID;

    if (callID == null || callID == "") {
      clientError(request, "Empty call_id in path.");
      return;
    }

    AuthService.userOf(token).then((ORModel.User user) {

      if (!aclCheck(user)) {
        forbidden(request, 'Insufficient privileges.');
        return;
      }

      /// Verify existence of call targeted for hangup.
      Model.Call targetCall = null;
      try {
        targetCall = Model.CallList.instance.get(callID);
      } on Model.NotFound catch (_) {
        notFound(request, {
          'call_id': callID
        });
        return;
      }

      /// Update user state.
      Model.UserStatusList.instance.update(
          user.ID,
          ORModel.UserState.HangingUp);

      Controller.PBX.hangup(targetCall).then((_) {

        /// Update user state.
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.WrappingUp);
        writeAndClose(request, JSON.encode(hangupCallIDOK(callID)));

      }).catchError((error, stackTrace) {
        /// Update user state.
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.Unknown);
        serverErrorTrace(request, error, stackTrace: stackTrace);

      });
    }).catchError(
        (error, stackTrace) =>
            serverErrorTrace(request, error, stackTrace: stackTrace));
  }

  static void list(HttpRequest request) {
    try {
      writeAndClose(request, JSON.encode(Model.CallList.instance));
    } catch (error, stackTrace) {
      serverErrorTrace(request, error, stackTrace: stackTrace);
    }
  }

  static void originate(HttpRequest request) {

    final int receptionID = pathParameter(request.uri, 'reception');
    final int contactID = pathParameter(request.uri, 'contact');
    final String extension = pathParameterString(request.uri, 'originate');
    final String token = request.uri.queryParameters['token'];

    log.finest('Originating to ${extension} in context '
               '${contactID}@${receptionID}');

    /// Any authenticated user is allowed to originate new calls.
    bool aclCheck(ORModel.User user) => true;

    bool validExtension(String extension) =>
        extension != null && extension.length > 1;

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
      Future.forEach(
          Model.CallList.instance.callsOf(
              user.ID).where((Model.Call call) => call.state == Model.CallState.Speaking),
          (Model.Call call) => call.park(user)).whenComplete(() {

        /// Check user state. If the user is currently performing an action - or
        /// has an active channel - deny the request.
        String userState = Model.UserStatusList.instance.get(user.ID).state;

        bool inTransition =
            ORModel.UserState.TransitionStates.contains(userState);
        bool hasChannels =
            Model.ChannelList.instance.hasActiveChannels(user.peer);

        if (inTransition || hasChannels) {
          clientError(
              request,
              'Phone is not ready. state:{$userState}, hasChannels:{$hasChannels}');
          return;
        }

        /// Update the user state
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.Dialing);

        /// Perform the origination via the PBX.
        Controller.PBX.originate(
            extension,
            contactID,
            receptionID,
            user).then((String channelUUID) {

          /// Update the user state
          Model.UserStatusList.instance.update(
              user.ID,
              ORModel.UserState.Speaking);

          writeAndClose(request, JSON.encode(orignateOK(channelUUID)));

        }).catchError((error, stackTrace) {
          Model.UserStatusList.instance.update(
              user.ID,
              ORModel.UserState.Unknown);

          serverErrorTrace(request, error, stackTrace: stackTrace);
        });

      }).catchError((error, stackTrace) {
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.Unknown);

        serverErrorTrace(request, error, stackTrace: stackTrace);
      });
    }).catchError(
        (error, stackTrace) =>
            serverErrorTrace(request, error, stackTrace: stackTrace));
  }


  static void park(HttpRequest request) {

    final String token = request.uri.queryParameters['token'];

    String callID = pathParameterString(request.uri, "call");

    List<String> parkGroups = [
        'Administrator',
        'Service_Agent',
        'Receptionist'];

    bool aclCheck(ORModel.User user) =>
        user.groups.any((group) => parkGroups.contains(group)) ||
            Model.CallList.instance.get(callID).assignedTo == user.ID;

    AuthService.userOf(token).then((ORModel.User user) {
      if (callID == null || callID == "") {
        clientError(request, "Empty call_id in path.");
        return;
      }

      Model.Call call = Model.CallList.instance.get(callID);

      if (!aclCheck(user)) {
        forbidden(request, 'Insufficient privileges.');
        return;
      }

      Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Parking);

      Controller.PBX.park(call, user).then((_) {
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.HandlingOffHook);

        writeAndClose(request, JSON.encode(parkOK(call)));

      }).catchError((error, stackTrace) {
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.Unknown);
        serverErrorTrace(request, error, stackTrace: stackTrace);
      });

    }).catchError((error, stackTrace) {
      if (error is Model.NotFound) {
        notFound(request, {
          'description': 'callID : $callID'
        });
      } else {
        serverErrorTrace(request, error, stackTrace: stackTrace);
      }
    }).catchError(
        (error, stackTrace) =>
            serverErrorTrace(request, error, stackTrace: stackTrace));

  }


  static void pickup(HttpRequest request) {

    String callID = pathParameterString(request.uri, "call");

    if (callID == null || callID == "") {
      clientError(request, "Empty call_id in path.");
      return;
    }
    final String token = request.uri.queryParameters['token'];

    bool aclCheck(ORModel.User user) => true;

    AuthService.userOf(token).then((ORModel.User user) {
      if (!aclCheck(user)) {
        forbidden(request, 'Insufficient privileges.');
        return;
      }

      try {
        if (!Model.PeerList.get(user.peer).registered) {
          clientError(request, "User with ${user.ID} has no peer available");
          return;
        }
      } catch (error) {
        clientError(request, "User with ${user.ID} has no peer available");
        log.severe
          ('Failed to lookup peer for user with ID ${user.ID}. Error : $error');
        return;
      }


      /// Park all the users calls.
      Future.forEach(
          Model.UserStatusList.instance.activeCallsAt(user.ID),
          (Model.Call call) => call.park(user)).whenComplete(() {

        /// Check user state. If the user is currently performing an action - or
        /// has an active channel - deny the request.
        String userState = Model.UserStatusList.instance.get(user.ID).state;

        bool inTransition =
            ORModel.UserState.TransitionStates.contains(userState);
        bool hasChannels =
            Model.ChannelList.instance.hasActiveChannels(user.peer);

        if (inTransition || hasChannels) {
          clientError(
              request,
              'Phone is not ready. state:{$userState}, hasChannels:{$hasChannels}');
          return;
        }

        /// Request the specified call.
        Model.Call assignedCall =
            Model.CallList.instance.requestSpecificCall(callID, user);

        log.finest('Assigned call ${assignedCall.ID} to user with '
                   'ID ${user.ID}');

        /// Update the user state
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.Receiving);

        Controller.PBX.transfer(assignedCall, user.peer).then((_) {
          assignedCall.assignedTo = user.ID;

          Model.UserStatusList.instance.update(
              user.ID,
              ORModel.UserState.Speaking);

          writeAndClose(request, JSON.encode(pickupOK(assignedCall)));

        }).catchError((error, stackTrace) {
          Model.UserStatusList.instance.update(
              user.ID,
              ORModel.UserState.Unknown);

          serverErrorTrace(request, error, stackTrace: stackTrace);
        });

      }).catchError((error, stackTrace) {
        if (error is Model.NotFound) {
          notFound(request, {
            'reason': 'No calls available.'
          });
        } else {
          Model.UserStatusList.instance.update(
              user.ID,
              ORModel.UserState.Unknown);
          serverErrorTrace(request, error, stackTrace: stackTrace);
        }
      });
    }).catchError((error, stackTrace) {
      if (error is Model.NotFound) {
        notFound(request, {
          'reason': 'No calls available.'
        });
      } else {
        serverErrorTrace(request, error, stackTrace: stackTrace);
      }
    }).catchError(
        (error, stackTrace) =>
            serverErrorTrace(request, error, stackTrace: stackTrace));
  }

  static void recordSound(HttpRequest request) {

    const String recordExtension = 'slowrecordmenu';

    int receptionID;
    String recordPath;
    String token;

    try {
      receptionID = pathParameter(request.uri, 'reception');
      recordPath = request.uri.queryParameters['recordpath'];
      token = request.uri.queryParameters['token'];
    } catch (error, stack) {
      clientError(request, 'Parameter error. ${error} ${stack}');
    }

    if (recordPath == null) {
      clientError(request, 'Missing parameter "recordpath".');
      return;
    }

    log.finest('Originating to ${recordExtension} with path '
               '${recordPath} for reception ${receptionID}');

    /// Any authenticated user is allowed to originate new calls.
    bool aclCheck(ORModel.User user) => true;

    bool validExtension(String extension) =>
        extension != null && extension.length > 1;

    AuthService.userOf(token).then((ORModel.User user) {
      if (!aclCheck(user)) {
        forbidden(request, 'Insufficient privileges.');
        return;
      }


      /// Park all the users calls.
      Future.forEach(
          Model.CallList.instance.callsOf(
              user.ID).where((Model.Call call) => call.state == Model.CallState.Speaking),
          (Model.Call call) => call.park(user)).whenComplete(() {

        /// Check user state. If the user is currently performing an action - or
        /// has an active channel - deny the request.
        String userState = Model.UserStatusList.instance.get(user.ID).state;

        bool inTransition =
            ORModel.UserState.TransitionStates.contains(userState);
        bool hasChannels =
            Model.ChannelList.instance.hasActiveChannels(user.peer);

        if (inTransition || hasChannels) {
          clientError(
              request,
              'Phone is not ready. state:{$userState}, hasChannels:{$hasChannels}');
          return;
        }

        /// Update the user state
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.Receiving);

        Controller.PBX.originateRecording(
            receptionID,
            recordExtension,
            recordPath,
            user).then((String channelUUID) {

          Model.UserStatusList.instance.update(
              user.ID,
              ORModel.UserState.Speaking);

          writeAndClose(request, JSON.encode(orignateOK(channelUUID)));

        }).catchError((error, stackTrace) {
          Model.UserStatusList.instance.update(
              user.ID,
              ORModel.UserState.Unknown);

          serverErrorTrace(request, error, stackTrace: stackTrace);
        });

      }).catchError((error, stackTrace) {
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.Unknown);

        serverErrorTrace(request, error, stackTrace: stackTrace);
      });

    }).catchError(
        (error, stackTrace) =>
            serverErrorTrace(request, error, stackTrace: stackTrace));
  }

  static void transfer(HttpRequest request) {

    final String token = request.uri.queryParameters['token'];

    String sourceCallID = pathParameterString(request.uri, "call");
    String destinationCallID = pathParameterString(request.uri, 'transfer');
    Model.Call sourceCall = null;
    Model.Call destinationCall = null;

    if (sourceCallID == null || sourceCallID == "") {
      clientError(request, "Empty call_id in path.");
      return;
    }

    ///Check valitity of the call. (Will raise exception on invalid).
    try {
      [sourceCallID, destinationCallID].forEach(Model.Call.validateID);
    } on FormatException catch (_) {
      clientError(request, 'Error in call id format (empty, null, nullID)');
      return;
    }

    try {
      sourceCall = Model.CallList.instance.get(sourceCallID);
      destinationCall = Model.CallList.instance.get(destinationCallID);
    } on Model.NotFound catch (_) {
      notFound(request, {
        'description': 'At least one of the calls are ' 'no longer available'
      });
      return;
    }

    log.finest('Transferring $sourceCall -> $destinationCall');

    /// Sanity check - are any of the calls already bridged?
    if ([
        sourceCall,
        destinationCall].every(
            (Model.Call call) => call.state != Model.CallState.Parked)) {
      log.warning(
          'Potential invalid state detected; trying to bridge a '
              'non-parked call in an attended transfer. uuids:'
              '($sourceCall => $destinationCall)');
    }

    log.finest('Transferring $sourceCall -> $destinationCall');

    AuthService.userOf(token).then((ORModel.User user) {
      /// Update user state.
      Model.UserStatusList.instance.update(
          user.ID,
          ORModel.UserState.Transferring);

      Controller.PBX.bridge(sourceCall, destinationCall).then((_) {
        /// Update user state.
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.WrappingUp);
        writeAndClose(request, '{"status" : "ok"}');

      }).catchError((error, stackTrace) {
        /// Update user state.
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.Unknown);
        serverErrorTrace(request, error, stackTrace: stackTrace);
      });

    }).catchError((error, stackTrace) {
      serverErrorTrace(request, error, stackTrace: stackTrace);
    });

  }

}
