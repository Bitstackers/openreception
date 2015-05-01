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

  static shelf.Response get(shelf.Request request) {
    String callID = shelf_route.getPathParameter(request, 'callid');

    try {
      Model.Call call = Model.CallList.instance.get(callID);
      return new shelf.Response.ok(JSON.encode(call));
    } catch (error, stackTrace) {
      if (error is Model.NotFound) {
        return new shelf.Response.notFound('{}');
      } else {
        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError();
      }
    }
  }

  static Future<shelf.Response> hangup(shelf.Request request) {

    return AuthService.userOf(_tokenFrom(request)).then((ORModel.User user) {

      ESL.Peer peer = Model.PeerList.get(user.peer);

      Model.UserStatusList.instance.update
        (user.ID, ORModel.UserState.HangingUp);

      return Controller.PBX.hangupCommand(peer)
        .then((_) {
          Model.UserStatusList.instance.update
            (user.ID, ORModel.UserState.HandlingOffHook);

          return new shelf.Response.ok(JSON.encode(hangupCommandOK(peer.ID)));

        })
        .catchError((error, stackTrace) {
          Model.UserStatusList.instance.update
            (user.ID, ORModel.UserState.Unknown);

          log.severe(error, stackTrace);
          return new shelf.Response.internalServerError();

        });

    })
    .catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError();

    });
  }

  static Future<shelf.Response> hangupSpecific(shelf.Request request) {

    final String callID = shelf_route.getPathParameter(request, 'callid');

    List<String> hangupGroups = ['Administrator'];

    bool aclCheck(ORModel.User user) =>
        user.groups.any(hangupGroups.contains) ||
            Model.CallList.instance.get(callID).assignedTo == user.ID;

    if (callID == null || callID == "") {
      return new Future.value
          (new shelf.Response(400, body : 'Empty call_id in path.'));
    }

    return AuthService.userOf(_tokenFrom(request))
      .then((ORModel.User user) {
        if (!aclCheck(user)) {
          return new shelf.Response.forbidden ('Insufficient privileges.');
        }

        /// Verify existence of call targeted for hangup.
        Model.Call targetCall = null;
        try {
          targetCall = Model.CallList.instance.get(callID);
        } on Model.NotFound catch (_) {
          return new shelf.Response.notFound
            (JSON.encode({'call_id': callID}));
        }

        /// Update user state.
        Model.UserStatusList.instance.update
          (user.ID, ORModel.UserState.HangingUp);

        return Controller.PBX.hangup(targetCall)
          .then((_) {

            /// Update user state.
            Model.UserStatusList.instance.update
              (user.ID, ORModel.UserState.WrappingUp);

            return new shelf.Response.ok(JSON.encode(hangupCallIDOK(callID)));

          })
          .catchError((error, stackTrace) {
            /// Update user state.
            Model.UserStatusList.instance.update
              (user.ID, ORModel.UserState.Unknown);

            log.severe(error, stackTrace);
            return new shelf.Response.internalServerError();
          });
      })
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError();
      });
  }

  static shelf.Response list(shelf.Request request) =>
    new shelf.Response.ok(JSON.encode(Model.CallList.instance));

  static Future<shelf.Response> originate(shelf.Request request) {

    final int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));
    final int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));
    String extension = shelf_route.getPathParameter(request, 'extension');
    final String host = shelf_route.getPathParameter(request, 'host');
    final String port = shelf_route.getPathParameter(request, 'port');

    if (host != null) {
      extension = '$extension@$host:$port';
    }

    log.finest('Originating to ${extension} in context '
               '${contactID}@${receptionID}');

    /// Any authenticated user is allowed to originate new calls.
    bool aclCheck(ORModel.User user) => true;

    bool validExtension(String extension) =>
        extension != null && extension.length > 1;

    return AuthService.userOf(_tokenFrom(request)).then((ORModel.User user) {
      if (!aclCheck(user)) {
        return new shelf.Response.forbidden ('Insufficient privileges.');
      }

      if (!validExtension(extension)) {
        return new shelf.Response(400, body : 'Invalid extension: $extension');
      }
      /// Park all the users calls.
      return Future.forEach
        (Model.CallList.instance.callsOf(user.ID).where((Model.Call call) =>
          call.state == Model.CallState.Speaking), (Model.Call call) =>
            call.park(user))
        .then((_) {

          /// Check user state. If the user is currently performing an action - or
          /// has an active channel - deny the request.
          String userState = Model.UserStatusList.instance.get(user.ID).state;

          bool inTransition =
            ORModel.UserState.TransitionStates.contains(userState);
          bool hasChannels =
            Model.ChannelList.instance.hasActiveChannels(user.peer);

          if (inTransition || hasChannels) {
            return new shelf.Response(400, body : 'Phone is not ready. '
              'state:{$userState}, hasChannels:{$hasChannels}');
          }

          /// Update the user state
          Model.UserStatusList.instance.update
            (user.ID, ORModel.UserState.Dialing);

          /// Perform the origination via the PBX.
          return Controller.PBX.originate (extension, contactID, receptionID, user)
            .then((String channelUUID) {

              /// Update the user state
              Model.UserStatusList.instance.update
                (user.ID, ORModel.UserState.Speaking);

              return new shelf.Response.ok(JSON.encode(orignateOK(channelUUID)));

            })
            .catchError((error, stackTrace) {
              Model.UserStatusList.instance.update
                (user.ID, ORModel.UserState.Unknown);

              log.severe(error, stackTrace);
              return new shelf.Response.internalServerError();
            });

        })
        .catchError((error, stackTrace) {
          Model.UserStatusList.instance.update
            (user.ID, ORModel.UserState.Unknown);

          log.severe(error, stackTrace);
          return new shelf.Response.internalServerError();
      });
    })
    .catchError(
        (error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError();
    });
  }

  /**
   * Originate a new call by first creating a parked phone channel to the
   * agent and then perform the orgination in the background.
   */
  static Future<shelf.Response> originateViaPark(shelf.Request request) {

    final int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));
    final int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));
    String extension = shelf_route.getPathParameter(request, 'extension');
    final String host = shelf_route.getPathParameter(request, 'host');
    final String port = shelf_route.getPathParameter(request, 'port');

    if (host != null) {
      extension = '$extension@$host:$port';
    }

    log.finest('Originating to ${extension} in context '
               '${contactID}@${receptionID}');

    /// Any authenticated user is allowed to originate new calls.
    bool aclCheck(ORModel.User user) => true;

    bool validExtension(String extension) =>
        extension != null && extension.length > 1;

    return AuthService.userOf(_tokenFrom(request)).then((ORModel.User user) {
      if (!aclCheck(user)) {
        return new shelf.Response.forbidden ('Insufficient privileges.');
      }

      if (!validExtension(extension)) {
        return new shelf.Response(400, body : 'Invalid extension: $extension');
      }


      bool isSpeaking (Model.Call call) =>
          call.state == Model.CallState.Speaking;

      Future parkIt (Model.Call call) => call.park(user);

      /// Park all the users calls.
      return Future.forEach
        (Model.CallList.instance.callsOf(user.ID).where(isSpeaking), parkIt)
        .then((_) {

        /// Check user state. If the user is currently performing an action - or
        /// has an active channel - deny the request.
        String userState = Model.UserStatusList.instance.get(user.ID).state;
        Future<Model.Call> outboundCall;

        bool inTransition =
            ORModel.UserState.TransitionStates.contains(userState);
        bool hasChannels =
            Model.ChannelList.instance.hasActiveChannels(user.peer);

        if (inTransition || hasChannels) {
          return new shelf.Response(400, body : 'Phone is not ready. '
            'state:{$userState}, hasChannels:{$hasChannels}');
        }

        /// Update the user state
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.Dialing);

        return Controller.PBX.createAgentChannel(extension, user)
          .then((String uuid) {
          bool outboundCallWithUuid (ESL.Event event) {
            return event.eventName == 'CHANNEL_ORIGINATE' &&
                event.channel.fields['Other-Leg-Unique-ID'] == uuid;
          }

          outboundCall =
              Model.PBXClient.instance.eventStream.firstWhere
              (outboundCallWithUuid, defaultValue : () => null)
              .then((ESL.Event event) =>
                Model.CallList.instance.get(event.uniqueID));
          outboundCall.timeout(new Duration (seconds : 10));

          /// Perform the origination via the PBX.
          return Controller.PBX.transferUUIDToExtension(uuid, extension, user)
            .then((_) {
              /// Update the user state
              Model.UserStatusList.instance.update(
                user.ID,
                ORModel.UserState.Speaking);

              return outboundCall
                .then((Model.Call call) {
                call.assignedTo = user.ID;
                call.receptionID = receptionID;
                call.contactID = contactID;

                return new shelf.Response.ok(JSON.encode(call));
              })
              .catchError((error, stackTrace) {
                Model.UserStatusList.instance.update(
                    user.ID,
                    ORModel.UserState.Unknown);
              });
            })
            .catchError((error, stackTrace) {
              Model.UserStatusList.instance.update(
                  user.ID,
                  ORModel.UserState.Unknown);

            });
          })
          .catchError((error, stackTrace) {
            Model.UserStatusList.instance.update(
                user.ID,
                ORModel.UserState.Unknown);
        });
        })
        .catchError((error, stackTrace) {
          Model.UserStatusList.instance.update
            (user.ID, ORModel.UserState.Unknown);

          log.severe(error, stackTrace);
          return new shelf.Response.internalServerError();
        });
      });
  }



  static Future<shelf.Response> park(shelf.Request request) {

    final String callID = shelf_route.getPathParameter(request, "callid");

    List<String> parkGroups = [
        'Administrator',
        'Service_Agent',
        'Receptionist'];

    bool aclCheck(ORModel.User user) =>
        user.groups.any((group) => parkGroups.contains(group)) ||
            Model.CallList.instance.get(callID).assignedTo == user.ID;

    return AuthService.userOf(_tokenFrom(request)).then((ORModel.User user) {
      if (callID == null || callID == "") {
        return new Future.value(
            new shelf.Response(400, body : 'Empty call_id in path.'));
      }

      Model.Call call = Model.CallList.instance.get(callID);

      if (!aclCheck(user)) {
        return new Future.value(
            new shelf.Response.forbidden('Insufficient privileges.'));
      }

      Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Parking);

      return Controller.PBX.park(call, user).then((_) {
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.HandlingOffHook);


        String reply = JSON.encode(parkOK(call));

        log.finest('Parked call ${reply}');

        return new shelf.Response.ok(reply);

      }).catchError((error, stackTrace) {
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.Unknown);
        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError();
      });

    }).catchError((error, stackTrace) {
      if (error is Model.NotFound) {
        return new shelf.Response.notFound
            (JSON.encode({'description': 'callID : $callID'}));
      } else {
        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError();
      }
    }).catchError(
        (error, stackTrace) {

      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError();
    });
  }

  static Future<shelf.Response> pickup(shelf.Request request) {

    final String callID = shelf_route.getPathParameter(request, 'callid');

    if (callID == null || callID == "") {
      return new Future.value
          (new shelf.Response(400, body : 'Empty call_id in path.'));
    }

    bool aclCheck(ORModel.User user) => true;

    return AuthService.userOf(_tokenFrom(request)).then((ORModel.User user) {
      if (!aclCheck(user)) {
        return new shelf.Response.forbidden('Insufficient privileges.');
      }

      try {
        if (!Model.PeerList.get(user.peer).registered) {
          return new shelf.Response(400, body : 'User with ${user.ID} has no peer available');
        }
      } catch (error) {
        log.severe
          ('Failed to lookup peer for user with ID ${user.ID}. Error : $error');
        return new shelf.Response(400, body : 'User with ${user.ID} has no peer available');
      }


      /// Park all the users calls.
      return Future.forEach(
          Model.UserStatusList.instance.activeCallsAt(user.ID),
          (Model.Call call) => call.park(user)).then((_) {

        /// Check user state. If the user is currently performing an action - or
        /// has an active channel - deny the request.
        String userState = Model.UserStatusList.instance.get(user.ID).state;

        bool inTransition =
            ORModel.UserState.TransitionStates.contains(userState);
        bool hasChannels =
            Model.ChannelList.instance.hasActiveChannels(user.peer);

        if (inTransition || hasChannels) {
          return new shelf.Response
              (400, body : 'Phone is not ready. '
                'state:{$userState}, hasChannels:{$hasChannels}');
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

        return Controller.PBX.transfer(assignedCall, user.peer).then((_) {
          assignedCall.assignedTo = user.ID;

          Model.UserStatusList.instance.update(
              user.ID,
              ORModel.UserState.Speaking);

          return new shelf.Response.ok(JSON.encode(pickupOK(assignedCall)));

        }).catchError((error, stackTrace) {
          Model.UserStatusList.instance.update(
              user.ID,
              ORModel.UserState.Unknown);

          log.severe(error, stackTrace);
          return new shelf.Response.internalServerError();
        });

      }).catchError((error, stackTrace) {
        if (error is Model.NotFound) {
          return new shelf.Response.notFound(JSON.encode({
            'reason': 'No calls available.'
          }));
        } else {
          Model.UserStatusList.instance.update(
              user.ID,
              ORModel.UserState.Unknown);
          log.severe(error, stackTrace);
          return new shelf.Response.internalServerError();
        }
      });
    }).catchError((error, stackTrace) {
      if (error is Model.NotFound) {
        return new shelf.Response.notFound(JSON.encode({
          'reason': 'No calls available.'
        }));
      } else {

        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError();
      }
    })
    .catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError();
    });
  }

  static Future<shelf.Response> recordSound(shelf.Request request) {

    const String recordExtension = 'slowrecordmenu';

    int receptionID;
    String recordPath;
    String token;

    try {
      receptionID = shelf_route.getPathParameter(request, 'rid');
      recordPath = request.requestedUri.queryParameters['recordpath'];
      token = request.requestedUri.queryParameters['token'];
    } catch (error, stack) {
      return new Future.value
        (new shelf.Response(400, body : 'Parameter error. ${error} ${stack}'));
    }

    if (recordPath == null) {
      return new Future.value
        (new shelf.Response(400, body : 'Missing parameter "recordpath".'));
    }

    log.finest('Originating to ${recordExtension} with path '
               '${recordPath} for reception ${receptionID}');

    /// Any authenticated user is allowed to originate new calls.
    bool aclCheck(ORModel.User user) => true;

    return AuthService.userOf(token).then((ORModel.User user) {
      if (!aclCheck(user)) {
        return new shelf.Response.forbidden('Insufficient privileges.');

      }


      /// Park all the users calls.
      return Future.forEach(
          Model.CallList.instance.callsOf(
              user.ID).where((Model.Call call) => call.state == Model.CallState.Speaking),
          (Model.Call call) => call.park(user)).then((_) {

        /// Check user state. If the user is currently performing an action - or
        /// has an active channel - deny the request.
        String userState = Model.UserStatusList.instance.get(user.ID).state;

        bool inTransition =
            ORModel.UserState.TransitionStates.contains(userState);
        bool hasChannels =
            Model.ChannelList.instance.hasActiveChannels(user.peer);

        if (inTransition || hasChannels) {
          return new shelf.Response(400, body : 'Phone is not ready. '
            'state:{$userState}, hasChannels:{$hasChannels}');
        }

        /// Update the user state
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.Receiving);

        return Controller.PBX.originateRecording(
            receptionID,
            recordExtension,
            recordPath,
            user).then((String channelUUID) {

          Model.UserStatusList.instance.update(
              user.ID,
              ORModel.UserState.Speaking);

          return new shelf.Response.ok(JSON.encode(orignateOK(channelUUID)));

        }).catchError((error, stackTrace) {
          Model.UserStatusList.instance.update(
              user.ID,
              ORModel.UserState.Unknown);

          log.severe(error, stackTrace);
          return new shelf.Response.internalServerError();
        });

      }).catchError((error, stackTrace) {
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.Unknown);

        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError();
      });

    })
    .catchError((error, stackTrace) {

      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError();
    });
  }

  static Future<shelf.Response> transfer(shelf.Request request) {

    String sourceCallID = shelf_route.getPathParameter(request, "aleg");
    String destinationCallID = shelf_route.getPathParameter(request, 'bleg');
    Model.Call sourceCall = null;
    Model.Call destinationCall = null;

    if (sourceCallID == null || sourceCallID == "") {
      return new Future.value
          (new shelf.Response(400, body : 'Empty call_id in path.'));
    }

    ///Check valitity of the call. (Will raise exception on invalid).
    try {
      [sourceCallID, destinationCallID].forEach(Model.Call.validateID);
    } on FormatException catch (_) {
      return new Future.value
       (new shelf.Response
           (400, body : 'Error in call id format (empty, null, nullID)'));
    }

    try {
      sourceCall = Model.CallList.instance.get(sourceCallID);
      destinationCall = Model.CallList.instance.get(destinationCallID);
    } on Model.NotFound catch (_) {
      return new Future.value(new shelf.Response.notFound(JSON.encode({
        'description': 'At least one of the calls are ' 'no longer available'
      })));
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

    return AuthService.userOf(_tokenFrom(request)).then((ORModel.User user) {
      /// Update user state.
      Model.UserStatusList.instance.update(
          user.ID,
          ORModel.UserState.Transferring);

      return Controller.PBX.bridge(sourceCall, destinationCall).then((_) {
        /// Update user state.
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.WrappingUp);
        return new shelf.Response.ok('{"status" : "ok"}');

      }).catchError((error, stackTrace) {
        /// Update user state.
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.Unknown);
        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError();
      });

    })
    .catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError();
    });

  }

}
