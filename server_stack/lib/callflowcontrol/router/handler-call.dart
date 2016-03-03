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

Map pickupOK(ORModel.Call call) => call.toJson();

Map<int, ORModel.UserState> _userMap = {};

abstract class Call {
  static String _peerInfo(ORModel.Peer peer) => '${peer.name}: '
      'channels: ${Model.ChannelList.instance.activeChannelCount(peer.name)},'
      'inTransition: ${peer.inTransition}';

  /**
   * Retrieves a single call from the call list.
   */
  static shelf.Response get(shelf.Request request) {
    String callID = shelf_route.getPathParameter(request, 'callid');

    try {
      ORModel.Call call = Model.CallList.instance.get(callID);
      return new shelf.Response.ok(JSON.encode(call));
    } on ORStorage.NotFound {
      return new shelf.Response.notFound('{}');
    } catch (error, stackTrace) {
      final String msg = 'Could not retrive call list';
      log.severe(msg, error, stackTrace);

      return serverError(msg);
    }
  }

  /**
   * Hangup the current call of the agent.
   */
  static Future<shelf.Response> hangup(shelf.Request request) async {
    ORModel.User user;

    /// User object fetching.
    try {
      user = await authService.userOf(tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      log.severe(msg, error, stackTrace);

      return serverError(msg);
    }

    ///Find the current call of the agent.
    ORModel.Call call = Model.CallList.instance.firstWhere(
        (ORModel.Call call) =>
            call.assignedTo == user.id &&
            call.state == ORModel.CallState.Speaking,
        orElse: () => ORModel.Call.noCall);

    /// The agent currently has no call assigned.
    if (call == ORModel.Call.noCall) {
      return new shelf.Response.notFound('{}');
    }

    ///There is an active call, update the peer state.
    Model.peerlist.get(user.peer).inTransition = true;

    ///Perfrom the hangup
    try {
      await Controller.PBX.killChannel(call.channel);
      Model.peerlist.get(user.peer).inTransition = false;

      return new shelf.Response.ok('{}');
    } catch (error, stackTrace) {
      final String msg = 'Failed kill the channel: (${call.channel})';
      log.severe(msg, error, stackTrace);

      /// We can no longer assume anything about the users' state.
      Model.peerlist.get(user.peer).inTransition = false;

      return serverError(msg);
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
        Model.CallList.instance.get(callID).assignedTo == user.id;

    if (callID == null || callID == "") {
      return new shelf.Response(400, body: 'Empty call_id in path.');
    }

    /// User object fetching.
    try {
      user = await authService.userOf(tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      log.severe(msg, error, stackTrace);

      return serverError(msg);
    }

    /// The agent is not allowed to terminate the call.
    if (!aclCheck(user)) {
      return new shelf.Response.forbidden('Insufficient privileges.');
    }

    /// Verify existence of call targeted for hangup.
    ORModel.Call targetCall;
    try {
      targetCall = Model.CallList.instance.get(callID);
    } on ORStorage.NotFound catch (_) {
      return new shelf.Response.notFound(JSON.encode({'call_id': callID}));
    }

    ORModel.Peer peer = Model.peerlist.get(user.peer);

    /// Update peer state.
    peer.inTransition = true;

    ///Completer
    Completer<ORModel.Call> completer = new Completer<ORModel.Call>();

    Model.CallList.instance.onEvent
        .firstWhere((OREvent.Event event) =>
            event is OREvent.CallHangup && event.call.ID == callID)
        .then((OREvent.CallHangup hangupEvent) =>
            completer.complete(hangupEvent.call));

    return await Controller.PBX.hangup(targetCall).then((_) {
      return completer.future.then((ORModel.Call hungupCall) {
        /// Update peer state.
        peer.inTransition = false;
        return new shelf.Response.ok(JSON.encode(hungupCall));
      }).timeout(new Duration(seconds: 3));
    }).catchError((error, stackTrace) {
      /// Update peer state.
      peer.inTransition = false;

      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError();
    });
  }

  /**
   * Lists every active call in system.
   */
  static shelf.Response list(shelf.Request request) =>
      new shelf.Response.ok(JSON.encode(Model.CallList.instance));

  /**
   * Originate a new call by first creating a parked phone channel to the
   * agent and then perform the orgination in the background.
   */
  static Future<shelf.Response> originate(shelf.Request request) async {
    final String callId =
        shelf_route.getPathParameters(request).containsKey('callId')
            ? shelf_route.getPathParameter(request, 'callId')
            : '';
    final int receptionID =
        int.parse(shelf_route.getPathParameter(request, 'rid'));
    final int contactID =
        int.parse(shelf_route.getPathParameter(request, 'cid'));
    String extension = shelf_route.getPathParameter(request, 'extension');
    final String dialplan = shelf_route.getPathParameter(request, 'dialplan');
    final String host = shelf_route.getPathParameter(request, 'host');
    final String port = shelf_route.getPathParameter(request, 'port');

    if (dialplan.isEmpty) {
      return clientError('Dialplan must not be empty');
    }

    ORModel.User user;
    ORModel.Peer peer;

    /// Call is a SIP call.
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
      user = await authService.userOf(tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      log.severe(msg, error, stackTrace);

      return serverError(msg);
    }

    if (!aclCheck(user)) {
      return new shelf.Response.forbidden('Insufficient privileges.');
    }

    if (!validExtension(extension)) {
      return new shelf.Response(400, body: 'Invalid extension: $extension');
    }

    /// Retrieve peer information.
    peer = Model.peerlist.get(user.peer);

    /// The user has not registered its peer to transfer the call to. Abort.
    if (peer == null || !peer.registered) {
      return clientError('User with id ${user.id} has no peer '
          '(peer: ${user.peer}) available');
    }

    /// The user has no reachable phone to transfer the call to. Abort.
    if (_phoneUnreachable(peer)) {
      return clientError('Phone is not ready. ${_peerInfo(peer)}');
    }

    /// Update the peer state
    peer.inTransition = true;

    bool isSpeaking(ORModel.Call call) =>
        call.state == ORModel.CallState.Speaking;

    Future parkIt(ORModel.Call call) => Controller.PBX.park(call, user);

    /// Park all the users calls.
    try {
      await Future.forEach(
          Model.CallList.instance.callsOf(user.id).where(isSpeaking), parkIt);
    } catch (error, stackTrace) {
      final String msg = 'Failed to park user\'s active calls';
      log.severe(msg, error, stackTrace);
      peer.inTransition = false;

      return serverError(msg);
    }

    /// Create an agent channel;
    String agentChannel;
    try {
      agentChannel = await Controller.PBX.createAgentChannel(user);
    } on Controller.CallRejected {
      peer.inTransition = false;

      return clientError('Phone is not reachable'
          ' (call rejected). Check configuration.');
    } on Controller.NoAnswer {
      peer.inTransition = false;

      return clientError('Phone is not reachable'
          ' (no answer). Check autoanswer.');
    } catch (error, stackTrace) {
      final String msg = 'Failed to create agent channel';
      log.severe(msg, error, stackTrace);
      peer.inTransition = false;

      return serverError(msg);
    }

    /// Create a subscription that listens for the next outbound call.
    bool outboundCallWithUuid(ESL.Event event) =>
        event.eventName == 'CHANNEL_ORIGINATE' &&
        event.channel.fields['Other-Leg-Unique-ID'] == agentChannel;

    Future<ORModel.Call> outboundCall = Controller.PBX.eventClient.eventStream
        .firstWhere(outboundCallWithUuid, defaultValue: () => null)
        .then((ESL.Event event) => Model.CallList.instance.createCall(event));

    /// At this point, we have an active agent channel and may perform
    /// the origination through the PBX by transferring our active agent
    /// channel to the outbound extension.
    ORModel.Call call;
    try {
      await Controller.PBX
          .transferUUIDToExtension(agentChannel, extension, user, dialplan);
      call = await outboundCall.timeout(new Duration(seconds: 1));
    } catch (error, stackTrace) {
      final String msg = 'Failed to get call channel';
      log.severe(msg, error, stackTrace);

      peer.inTransition = false;

      return serverError(msg);
    }

    /// Update the call with the info from the originate request.
    call
      ..assignedTo = user.id
      ..callerID = config.callFlowControl.callerIdNumber
      ..destination = extension
      ..receptionID = receptionID
      ..contactID = contactID
      ..b_Leg = agentChannel;

    /// Update call and peer state information.
    call.changeState(ORModel.CallState.Ringing);

    try {
      await Controller.PBX
          .setVariable(call.channel, ORPbxKey.userId, user.id.toString());
      await Controller.PBX.setVariable(
          call.channel, ORPbxKey.receptionId, receptionID.toString());
      await Controller.PBX
          .setVariable(call.channel, ORPbxKey.contactId, contactID.toString());
      await Controller.PBX
          .setVariable(call.channel, ORPbxKey.destination, extension);

      if (callId.isNotEmpty) {
        await Controller.PBX
            .setVariable(call.channel, ORPbxKey.contextCallId, callId);
      }
    } catch (error, stackTrace) {
      final String msg = 'Failed to create agent channel';
      log.severe(msg, error, stackTrace);
      peer.inTransition = false;
      return serverError(msg);
    }

    peer.inTransition = false;
    return new shelf.Response.ok(JSON.encode(call));
  }

  /**
   * Park a specific call.
   */
  static Future<shelf.Response> park(shelf.Request request) async {
    final String callID = shelf_route.getPathParameter(request, "callid");

    List<String> parkGroups = [
      'Administrator',
      'Service_Agent',
      'Receptionist'
    ];

    ORModel.User user;

    bool aclCheck(ORModel.User user) =>
        Model.CallList.instance.get(callID).assignedTo == user.id ||
        user.groups.any((group) => parkGroups.contains(group));

    /// User object fetching.
    try {
      user = await authService.userOf(tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      log.severe(msg, error, stackTrace);

      return serverError(msg);
    }

    if (callID == null || callID == "") {
      return clientError('Empty call_id in path.');
    }

    ORModel.Call call;
    try {
      call = Model.CallList.instance.get(callID);
    } on ORStorage.NotFound {
      return notFoundJson({'description': 'callID : $callID'});
    }

    if (!aclCheck(user)) {
      return new shelf.Response.forbidden('Insufficient privileges.');
    }

    try {
      await Controller.PBX.park(call, user);
      log.finest('Parked call ${call.ID}');

      return okJson(call);
    } catch (error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError();
    }
  }

  /**
   *
   */
  static bool _phoneUnreachable(ORModel.Peer peer) =>
      peer.inTransition ||
      Model.ChannelList.instance.hasActiveChannels(peer.name);

  /**
   * Pickup a specific call.
   * TODO: Check for locked call in dialplan.
   */
  static Future<shelf.Response> pickup(shelf.Request request) async {
    final String callID = shelf_route.getPathParameter(request, 'callid');
    ORModel.User user;
    ORModel.Peer peer;
    ORModel.Call assignedCall;
    String agentChannel;
    int originallyAssignedTo = ORModel.User.noId;

    /// Parameter check.
    if (callID == null || callID == "") {
      return clientError('Empty call_id in path.');
    }

    /// User object fetching.
    try {
      user = await authService.userOf(tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      log.severe(msg, error, stackTrace);

      return serverError(msg);
    }

    /// Retrieve peer information.
    peer = Model.peerlist.get(user.peer);

    /// The user has not registered its peer to transfer the call to. Abort.
    if (peer == null) {
      return clientError('User with id ${user.id} has no peer '
          '(${_peerInfo(peer)} available');
    }

    /// The user has no reachable phone to transfer the call to. Abort.
    if (_phoneUnreachable(peer)) {
      return clientError('Phone is not ready. ${_peerInfo(peer)}');
    }

    try {
      /// Request the specified call.
      assignedCall = Model.CallList.instance.requestSpecificCall(callID, user);
    } on ORStorage.Conflict {
      return new shelf.Response(409,
          body: JSON.encode({'error': 'Call not currently available.'}));
    } on ORStorage.NotFound {
      return new shelf.Response.notFound(
          JSON.encode({'error': 'No calls available.'}));
    } on ORStorage.Forbidden {
      return new shelf.Response.forbidden(
          JSON.encode({'error': 'Call already assigned.'}));
    } catch (error, stackTrace) {
      final String msg = 'Failed retrieve call from call list';
      log.severe(msg, error, stackTrace);

      return serverError(msg);
    }

    /// Update the user state
    peer.inTransition = true;
    originallyAssignedTo = assignedCall.assignedTo;
    assignedCall.assignedTo = user.id;

    log.finest('Assigned call ${assignedCall.ID} to user with ID ${user.id}');

    /// Create an agent channel
    try {
      agentChannel = await Controller.PBX.createAgentChannel(user);
    } catch (error, stackTrace) {
      final String msg = 'Failed to create agent channel';
      log.severe(msg, error, stackTrace);

      peer.inTransition = false;

      /// Revert the call to the user it was originally assigned to.
      assignedCall.assignedTo = originallyAssignedTo;

      /// Make sure the agent channel is closed before returning a response.
      return await new Future.delayed(new Duration(seconds: 3)).then((_) =>
          Controller.PBX
              .killChannel(agentChannel)
              .then((_) => serverError(msg))
              .catchError((error, stackTrace) {
            log.severe('Failed to close agent channel', error, stackTrace);
            return serverError(msg);
          }));
    }

    /// Channel bridging
    try {
      await Controller.PBX.bridgeChannel(agentChannel, assignedCall);
    } catch (error, stackTrace) {
      final String msg = 'Failed to bridge channels: '
          '$agentChannel and $assignedCall. '
          'Killing agent channel $agentChannel';
      log.severe(msg, error, stackTrace);

      peer.inTransition = false;

      /// Make sure the agent channel is closed before returning a response.
      return await Controller.PBX
          .killChannel(agentChannel)
          .then((_) => serverError(msg))
          .catchError((error, stackTrace) {
        log.severe('Failed to close agent channel', error, stackTrace);
        return serverError(msg);
      });
    }

    /// Tag the channel as assigned to the user.
    try {
      await Controller.PBX.setVariable(
          assignedCall.channel, ORPbxKey.userId, user.id.toString());
    } catch (error, stackTrace) {
      final String msg = 'Failed set user id for channel $agentChannel.'
          'Channel reload will be inaccurate.';
      log.warning(msg, error, stackTrace);
    }

    /// Update the user state. At this point, all is well.
    peer.inTransition = false;
    assignedCall.locked = false;
    return new shelf.Response.ok(JSON.encode(assignedCall));
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
      return new shelf.Response(400, body: 'Empty call_id in path.');
    }

    ///Check valitity of the call. (Will raise exception on invalid).
    try {
      [sourceCallID, destinationCallID].forEach(ORModel.Call.validateID);
    } on FormatException catch (_) {
      return new shelf.Response(400,
          body: 'Error in call id format (empty, null, nullID)');
    }

    try {
      sourceCall = Model.CallList.instance.get(sourceCallID);
      destinationCall = Model.CallList.instance.get(destinationCallID);
    } on ORStorage.NotFound catch (_) {
      return new shelf.Response.notFound(JSON.encode({
        'description': 'At least one of the calls are ' 'no longer available'
      }));
    }

    log.finest('Transferring $sourceCall -> $destinationCall');

    /// Sanity check - are any of the calls already bridged?
    if ([sourceCall, destinationCall]
        .every((ORModel.Call call) => call.state != ORModel.CallState.Parked)) {
      log.warning('Potential invalid state detected; trying to bridge a '
          'non-parked call in an attended transfer. uuids:'
          '($sourceCall => $destinationCall)');
    }

    log.finest('Transferring $sourceCall -> $destinationCall');

    /// User object fetching.
    try {
      user = await authService.userOf(tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      log.severe(msg, error, stackTrace);

      return serverError(msg);
    }

    ORModel.Peer peer = Model.peerlist.get(user.peer);

    /// Update peer state.
    peer.inTransition = true;

    return await Controller.PBX.bridge(sourceCall, destinationCall).then((_) {
      return new shelf.Response.ok('{"status" : "ok"}');
    }).catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError();
    }).whenComplete(() => peer.inTransition = false);
  }

  /**
   * Remove a specific call identified by the supplied call id.
   */
  static Future<shelf.Response> remove(shelf.Request request) async {
    final String callID = shelf_route.getPathParameter(request, 'callid');

    ORModel.User user;

    /// Groups able to remove any call.
    List<String> updateGroups = ['Administrator'];

    bool aclCheck(ORModel.User user) =>
        user.groups.any(updateGroups.contains) ||
        Model.CallList.instance.get(callID).assignedTo == user.id;

    if (callID == null || callID == "") {
      return new shelf.Response(400, body: 'Empty call_id in path.');
    }

    /// User object fetching.
    try {
      user = await authService.userOf(tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      log.severe(msg, error, stackTrace);

      return serverError(msg);
    }

    /// The agent is not allowed to terminate the call.
    if (!aclCheck(user)) {
      return new shelf.Response.forbidden('Insufficient privileges.');
    }

    /// Verify existence of call targeted for update.
    if (Model.CallList.instance.containsID(callID)) {
      Model.CallList.instance.remove(callID);
      return okJson({});
    } else {
      return notFoundJson({'call_id': callID});
    }
  }

  /**
   * Update a specific call identified by the supplied call id.
   */
  static Future<shelf.Response> update(shelf.Request request) async {
    final String callID = shelf_route.getPathParameter(request, 'callid');

    ORModel.User user;

    ORModel.Call updatedCall;
    try {
      updatedCall = await request
          .readAsString()
          .then(JSON.decode)
          .then((Map map) => new ORModel.Call.fromMap(map));
    } catch (error, stackTrace) {
      log.warning(
          'Bad parameters from user '
          '${user.name} (id:${user.id})',
          error,
          stackTrace);
      return clientError(error.toString());
    }

    /// Groups able to update a call.
    List<String> updateGroups = ['Administrator'];

    bool aclCheck(ORModel.User user) =>
        user.groups.any(updateGroups.contains) ||
        Model.CallList.instance.get(callID).assignedTo == user.id;

    if (callID == null || callID == "") {
      return new shelf.Response(400, body: 'Empty call_id in path.');
    }

    /// User object fetching.
    try {
      user = await authService.userOf(tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      log.severe(msg, error, stackTrace);

      return serverError(msg);
    }

    /// The agent is not allowed to terminate the call.
    if (!aclCheck(user)) {
      return new shelf.Response.forbidden('Insufficient privileges.');
    }

    /// Verify existence of call targeted for update.
    if (Model.CallList.instance.containsID(callID)) {
      Model.CallList.instance.update(callID, updatedCall);
      return okJson(updatedCall);
    } else {
      return notFoundJson({'call_id': callID});
    }
  }
}
