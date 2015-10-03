/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.call_flow_control_server.router;

/// Reply templates.
Map _orignateOK(channelUUID) => {
  'status': 'ok',
  'call': {
    'id': channelUUID
  },
  'description': 'Connecting...'
};

Map _parkOK(ORModel.Call call) => {
  'status': 'ok',
  'message': 'call parked',
  'call': call
};


Map pickupOK(ORModel.Call call) => call.toJson();

Map<int, ORModel.UserState> userMap = {};

abstract class Call {
  /**
   * Retrieves a single call from the call list.
   */
  static shelf.Response get(shelf.Request request) {
    String callID = shelf_route.getPathParameter(request, 'callid');

    try {
      ORModel.Call call = Model.CallList.instance.get(callID);
      return new shelf.Response.ok(JSON.encode(call));
    }
    on ORStorage.NotFound {
      return new shelf.Response.notFound('{}');
    }
    catch (error, stackTrace) {
      final String msg = 'Could not retrive call list';
      log.severe(msg, error, stackTrace);

      return _serverError(msg);
    }
  }

  /**
   * Hangup the current call of the agent.
   */
  static Future<shelf.Response> hangup(shelf.Request request) async {

    ORModel.User user;

    /// User object fetching.
    try {
      user = await AuthService.userOf(_tokenFrom(request));
    }
    catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      log.severe(msg, error, stackTrace);

      return _serverError(msg);
    }

    ///Find the current call of the agent.
    ORModel.Call call = Model.CallList.instance
        .firstWhere((ORModel.Call call) =>
            call.assignedTo == user.ID &&
            call.state == ORModel.CallState.Speaking,
        orElse: () => ORModel.Call.noCall);

    /// The agent currently has no call assigned.
    if (call == ORModel.Call.noCall) {
      return new shelf.Response.notFound('{}');
    }

    ///There is an active call, update the user state.
    Model.UserStatusList.instance.update(user.ID, ORModel.UserState.HangingUp);


    try {
      await Controller.PBX.hangup(call);
      Model.UserStatusList.instance.update
      (user.ID, ORModel.UserState.HandlingOffHook);

      return new shelf.Response.ok('{}');
    }
    catch (error, stackTrace) {
      final String msg = 'Failed retrieve call from call list';
      log.severe(msg, error, stackTrace);

      /// We can no longer assume anything about the users' state.
      Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Unknown);

      return _serverError(msg);
    }
  }

  /**
   * Hangup a specific call identified by the supplied call id.
   */
  static Future<shelf.Response> hangupSpecific(shelf.Request request) async {

    final String callID = shelf_route.getPathParameter(request, 'callid');

    ORModel.User user;

    /// Groups able to hangup any call.
    List<String> hangupGroups = ['Administrator'];

    bool aclCheck(ORModel.User user) =>
        user.groups.any(hangupGroups.contains) ||
            Model.CallList.instance.get(callID).assignedTo == user.ID;

    if (callID == null || callID == "") {
      return new Future.value
          (new shelf.Response(400, body : 'Empty call_id in path.'));
    }

    /// User object fetching.
    try {
      user = await AuthService.userOf(_tokenFrom(request));
    }
    catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      log.severe(msg, error, stackTrace);

      return _serverError(msg);
    }

    /// The agent is not allowed to terminate the call.
    if (!aclCheck(user)) {
       return new shelf.Response.forbidden ('Insufficient privileges.');
    }

    /// Verify existence of call targeted for hangup.
    ORModel.Call targetCall;
    try {
      targetCall = Model.CallList.instance.get(callID);
    } on ORStorage.NotFound catch (_) {
      return new shelf.Response.notFound(JSON.encode({'call_id': callID}));
    }

    /// Update user state.
    Model.UserStatusList.instance.update(user.ID, ORModel.UserState.HangingUp);

    ///Completer
    Completer<ORModel.Call> completer = new Completer<ORModel.Call>();

    Model.CallList.instance.onEvent.
      firstWhere((OREvent.CallEvent event) =>
          event is OREvent.CallHangup && event.call.ID == callID)
        .then ((OREvent.CallHangup hangupEvent) =>
              completer.complete(hangupEvent.call));

    return Controller.PBX.hangup(targetCall)
      .then((_) {

        return completer.future.then((ORModel.Call hungupCall) {
          /// Update user state.
          Model.UserStatusList.instance.update
            (user.ID, ORModel.UserState.WrappingUp);

          return new shelf.Response.ok(JSON.encode(hungupCall));
        }).timeout(new Duration(seconds : 3));


      })
      .catchError((error, stackTrace) {
        /// Update user state.
        Model.UserStatusList.instance.update
          (user.ID, ORModel.UserState.Unknown);

        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError();
      });

  }

  /**
   * Lists every active call in system.
   */
  static shelf.Response list(shelf.Request request) =>
    new shelf.Response.ok(JSON.encode(Model.CallList.instance));


  static void _userStateUnknown (ORModel.User user) =>
      Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Unknown);

  static void _userStateDialing (ORModel.User user) =>
      Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Dialing);

  /**
   * Originate a new call by first creating a parked phone channel to the
   * agent and then perform the orgination in the background.
   */
  static Future<shelf.Response> originate(shelf.Request request) async {

    final int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));
    final int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));
    String extension = shelf_route.getPathParameter(request, 'extension');
    final String host = shelf_route.getPathParameter(request, 'host');
    final String port = shelf_route.getPathParameter(request, 'port');
    ORModel.User user;
    Model.Peer peer;

    if (host != null) {
      extension = '$extension@$host:$port';
    }

    log.finest('Originating to ${extension} in context '
               '${contactID}@${receptionID}');

    /// Any authenticated user is allowed to originate new calls.
    bool aclCheck(ORModel.User user) => true;

    bool validExtension(String extension) =>
        extension != null && extension.length > 1;

    /// User object fetching.
    try {
      user = await AuthService.userOf(_tokenFrom(request));
    }
    catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      log.severe(msg, error, stackTrace);

      return _serverError(msg);
    }

    if (!aclCheck(user)) {
      return new shelf.Response.forbidden ('Insufficient privileges.');
    }

    if (!validExtension(extension)) {
      return new shelf.Response(400, body : 'Invalid extension: $extension');
    }

    /// Retrieve peer information.
    peer = Model.PeerList.get(user.peer);

    /// The user has not registered its peer to transfer the call to. Abort.
    if (peer == null || !peer.registered) {
      _userStateUnknown(user);
      return _clientError('User with ${user.ID} has no peer available');
    }

    /// The user has no reachable phone to transfer the call to. Abort.
    if (_phoneUnreachable(user)) {
      _userStateUnknown(user);
      return _clientError('Phone is not ready. ${_stateString(user)}');
    }

    /// Update the user state
    _userStateDialing(user);

    bool isSpeaking (ORModel.Call call) =>
        call.state == ORModel.CallState.Speaking;

    Future parkIt (ORModel.Call call) => Controller.PBX.park(call, user);

    /// Park all the users calls.
    try {
      await Future.forEach(Model.CallList.instance.callsOf(user.ID)
          .where(isSpeaking),
          parkIt);
    }
    catch (error, stackTrace) {
      final String msg = 'Failed to park user\'s active calls';
      log.severe(msg, error, stackTrace);
      _userStateUnknown(user);

      return _serverError(msg);
    }

    /// Create an agent channel;
    String uuid;
    try {
      uuid = await Controller.PBX.createAgentChannel(user);
    }
    on Controller.CallRejected {
      _userStateUnknown(user);

      return _clientError('Phone is not reachable'
      ' (call rejected). Check configuration.');
    }
    on Controller.NoAnswer {
      _userStateUnknown(user);

      return _clientError('Phone is not reachable'
        ' (no answer). Check autoanswer.');
    }
    catch (error, stackTrace) {
      final String msg = 'Failed to create agent channel';
      log.severe(msg, error, stackTrace);
      _userStateUnknown(user);

      return _serverError(msg);
    }

    /// Create a subscription that listens for the next outbound call.
    bool outboundCallWithUuid (ESL.Event event) =>
        event.eventName == 'CHANNEL_ORIGINATE' &&
        event.channel.fields['Other-Leg-Unique-ID'] == uuid;

    Future<ORModel.Call> outboundCall =
        Controller.PBX.eventClient.eventStream.firstWhere
        (outboundCallWithUuid, defaultValue : () => null)
        .then((ESL.Event event) =>
          Model.CallList.instance.createCall(event));

    /// At this point, we have an active agent channel and may perform
    /// the origination through the PBX by transferring our active agent
    /// channel to the outbound extension.
    ORModel.Call call;
    try {
      await Controller.PBX.transferUUIDToExtension(uuid, extension, user);
      call = await outboundCall.timeout(new Duration (seconds : 1));
    }
    catch (error, stackTrace) {
      final String msg = 'Failed to get call channel';
      log.severe(msg, error, stackTrace);

      _userStateUnknown(user);

      return _serverError(msg);
    }

    /// Update the call with the info from the originate request.
    call..assignedTo = user.ID
        ..receptionID = receptionID
        ..contactID = contactID
        ..b_Leg = uuid;

    /// Update call and user state information.
    call.changeState(ORModel.CallState.Ringing);
    Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Speaking);

    try {
      await Controller.PBX.setVariable
          (call.channel, Controller.PBX.ownerUid, user.ID.toString());
      await Controller.PBX.setVariable
        (call.channel, 'reception_id', receptionID.toString());
      await Controller.PBX.setVariable
         (call.channel, 'contact_id', contactID.toString());
    }
    catch (error, stackTrace) {
      final String msg = 'Failed to create agent channel';
      log.severe(msg, error, stackTrace);
      _userStateUnknown(user);

      return _serverError(msg);
    }

    return new shelf.Response.ok(JSON.encode(call));
  }

  /**
   * Park a specific call.
   */
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

      ORModel.Call call = Model.CallList.instance.get(callID);

      if (!aclCheck(user)) {
        return new Future.value(
            new shelf.Response.forbidden('Insufficient privileges.'));
      }

      Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Parking);

      return Controller.PBX.park(call, user).then((_) {
        Model.UserStatusList.instance.update(
            user.ID,
            ORModel.UserState.HandlingOffHook);


        String reply = JSON.encode(_parkOK(call));

        log.finest('Parked call ${reply}');

        return new shelf.Response.ok(reply);

      }).catchError((error, stackTrace) {
        _userStateUnknown(user);

        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError();
      });

    }).catchError((error, stackTrace) {
      if (error is ORStorage.NotFound) {
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

  /**
   *
   */
  static shelf.Response _clientError(String reason) =>
      new shelf.Response(400, body : reason);

  /**
   *
   */
  static shelf.Response _serverError(String reason) =>
      new shelf.Response(500, body : reason);

  /**
   *
   */
  static bool _phoneUnreachable(ORModel.User user)  {
    /// Check user state. If the user is currently performing an action - or
    /// has an active channel - deny the request.
    String userState = Model.UserStatusList.instance.getOrCreate(user.ID).state;

    bool inTransition = ORModel.UserState.TransitionStates.contains(userState);
    bool hasChannels = Model.ChannelList.instance.hasActiveChannels(user.peer);

    if(inTransition || hasChannels) {
      return true;
    }

    return false;
  }

  static String _stateString (ORModel.User user) {
    String userState = Model.UserStatusList.instance.getOrCreate(user.ID).state;
    bool hasChannels = Model.ChannelList.instance.hasActiveChannels(user.peer);

    return 'state:{$userState}, hasChannels:{$hasChannels}';
  }

  /**
   * Pickup a specific call.
   */
  static Future<shelf.Response> pickup(shelf.Request request) async {

    final String callID = shelf_route.getPathParameter(request, 'callid');
    ORModel.User user;
    Model.Peer peer;
    ORModel.Call assignedCall;
    String agentChannel;

    /// Parameter check.
    if (callID == null || callID == "") {
      return new Future.value(_clientError('Empty call_id in path.'));
    }

    /// User object fetching.
    try {
      user = await AuthService.userOf(_tokenFrom(request));
    }
    catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      log.severe(msg, error, stackTrace);

      return _serverError(msg);
    }

    /// Retrieve peer information.
    peer = Model.PeerList.get(user.peer);

    /// The user has not registered its peer to transfer the call to. Abort.
    if (peer == null || !peer.registered) {
      _userStateUnknown(user);

      return _clientError('User with ${user.ID} has no peer available');
    }

    /// The user has no reachable phone to transfer the call to. Abort.
    if (_phoneUnreachable(user)) {
      _userStateUnknown(user);

      return _clientError('Phone is not ready. ${_stateString(user)}');
    }

    try {
      /// Request the specified call.
      assignedCall = Model.CallList.instance.requestSpecificCall(callID, user);
      assignedCall.assignedTo = user.ID;
    }

    on ORStorage.Conflict {
      return new shelf.Response(409, body : JSON.encode({
        'error': 'Call not currently available.'
      }));
    }

    on ORStorage.NotFound {
      return new shelf.Response.notFound(JSON.encode({
        'error': 'No calls available.'
      }));
    }

    on ORStorage.Forbidden {
      return new shelf.Response.forbidden(JSON.encode({
          'error': 'Call already assigned.'
      }));
    }
    catch (error, stackTrace) {
      final String msg = 'Failed retrieve call from call list';
      log.severe(msg, error, stackTrace);

      return _serverError(msg);
    }

    /// Update the user state
    Model.UserStatusList.instance.update (user.ID, ORModel.UserState.Receiving);

    log.finest('Assigned call ${assignedCall.ID} to user with ID ${user.ID}');

    /// Create an agent channel
    try {
      agentChannel = await Controller.PBX.createAgentChannel(user);
    } catch (error, stackTrace) {
      final String msg = 'Failed to create agent channel';
      log.severe(msg, error, stackTrace);

      Model.UserStatusList.instance.update (user.ID, ORModel.UserState.Unknown);

      return _serverError(msg);
    }

    /// Channel bridging
    try {
      await Controller.PBX.bridgeChannel(agentChannel, assignedCall);
    }
    catch (error, stackTrace) {
      final String msg = 'Failed to bridge channels: '
          '$agentChannel and $assignedCall. '
          'Killing agent channel $agentChannel';
      log.severe(msg, error, stackTrace);

      Model.UserStatusList.instance.update (user.ID, ORModel.UserState.Unknown);

      /// Make sure the agent channel is closed before returning a response.
      return Controller.PBX.killChannel(agentChannel)
        .then((_) =>  _serverError(msg))
        .catchError((error, stackTrace) {
            log.severe('Failed to close agent channel', error, stackTrace);
        return _serverError(msg);
      });
    }

    /// Tag the channel as assigned to the user.
    try {
      await Controller.PBX.setVariable
        (assignedCall.channel, Controller.PBX.ownerUid, user.ID.toString());
    }
    catch (error, stackTrace) {
      final String msg = 'Failed set user id for channel $agentChannel.'
          'Channel reload will be inaccurate.';
      log.warning(msg, error, stackTrace);
    }

    /// Update the user state. At this point, all is well.
    Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Speaking);

    return new shelf.Response.ok(JSON.encode(assignedCall));
  }

  /**
   * Originate a call to record-sound extension in the PBX.
   */
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
              user.ID).where((ORModel.Call call) => call.state == ORModel.CallState.Speaking),
          (ORModel.Call call) => Controller.PBX.park(call, user)).then((_) {

        /// Check user state. If the user is currently performing an action - or
        /// has an active channel - deny the request.
        String userState = Model.UserStatusList.instance.getOrCreate(user.ID).state;

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

          return new shelf.Response.ok(JSON.encode(_orignateOK(channelUUID)));

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

  /**
   * Transfer (bridge) two calls in the PBX.
   */
  static Future<shelf.Response> transfer(shelf.Request request) async {

    String sourceCallID = shelf_route.getPathParameter(request, "aleg");
    String destinationCallID = shelf_route.getPathParameter(request, 'bleg');
    ORModel.Call sourceCall = null;
    ORModel.Call destinationCall = null;
    ORModel.User user;

    if (sourceCallID == null || sourceCallID == "") {
      return new Future.value
          (new shelf.Response(400, body : 'Empty call_id in path.'));
    }

    ///Check valitity of the call. (Will raise exception on invalid).
    try {
      [sourceCallID, destinationCallID].forEach(ORModel.Call.validateID);
    } on FormatException catch (_) {
      return new Future.value
       (new shelf.Response
           (400, body : 'Error in call id format (empty, null, nullID)'));
    }

    try {
      sourceCall = Model.CallList.instance.get(sourceCallID);
      destinationCall = Model.CallList.instance.get(destinationCallID);
    } on ORStorage.NotFound catch (_) {
      return new Future.value(new shelf.Response.notFound(JSON.encode({
        'description': 'At least one of the calls are ' 'no longer available'
      })));
    }

    log.finest('Transferring $sourceCall -> $destinationCall');

    /// Sanity check - are any of the calls already bridged?
    if ([
        sourceCall,
        destinationCall].every(
            (ORModel.Call call) => call.state != ORModel.CallState.Parked)) {
      log.warning(
          'Potential invalid state detected; trying to bridge a '
              'non-parked call in an attended transfer. uuids:'
              '($sourceCall => $destinationCall)');
    }

    log.finest('Transferring $sourceCall -> $destinationCall');

    /// User object fetching.
    try {
      user = await AuthService.userOf(_tokenFrom(request));
    }
    catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      log.severe(msg, error, stackTrace);

      return _serverError(msg);
    }

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
  }
}
