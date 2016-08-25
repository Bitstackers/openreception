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

library openreception.server.controller.call;

import 'dart:async';
import 'dart:convert';

import 'package:esl/esl.dart' as esl;
import 'package:logging/logging.dart';
import 'package:openreception.framework/event.dart' as event;
import 'package:openreception.framework/exceptions.dart';
import 'package:openreception.framework/model.dart' as model;
import 'package:openreception.framework/pbx-keys.dart';
import 'package:openreception.framework/service-io.dart' as service;
import 'package:openreception.framework/service.dart' as service;
import 'package:openreception.server/controller/controller-pbx.dart'
    as controller;
import 'package:openreception.server/model.dart' as _model;
import 'package:openreception.server/configuration.dart';
import 'package:openreception.server/response_utils.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_route/shelf_route.dart' as shelf_route;

class Call {
  String _peerInfo(model.Peer peer) => '${peer.name}: '
      'channels: ${_channelList.activeChannelCount(peer.name)},'
      'inTransition: ${peer.inTransition}';

  final _model.CallList _callList;
  final _model.PeerList _peerlist;
  final _model.ChannelList _channelList;
  final controller.PBX _pbxController;
  final service.Authentication authService;
  final Logger _log =
      new Logger('openreception.server.controller.call_flow_control');

  Call(this._callList, this._channelList, this._peerlist, this._pbxController,
      this.authService);

  /**
   * Retrieves a single call from the call list.
   */
  shelf.Response get(shelf.Request request) {
    String callID = shelf_route.getPathParameter(request, 'callid');

    try {
      model.Call call = _callList.get(callID);
      return new shelf.Response.ok(JSON.encode(call));
    } on NotFound {
      return new shelf.Response.notFound('{}');
    } catch (error, stackTrace) {
      final String msg = 'Could not retrive call list';
      _log.severe(msg, error, stackTrace);

      return serverError(msg);
    }
  }

  /**
   * Hangup the current call of the agent.
   */
  Future<shelf.Response> hangup(shelf.Request request) async {
    model.User user;

    /// User object fetching.
    try {
      user = await authService.userOf(tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      _log.severe(msg, error, stackTrace);

      return serverError(msg);
    }

    ///Find the current call of the agent.
    model.Call call = _callList.firstWhere(
        (model.Call call) =>
            call.assignedTo == user.id &&
            call.state == model.CallState.speaking,
        orElse: () => model.Call.noCall);

    /// The agent currently has no call assigned.
    if (call == model.Call.noCall) {
      return new shelf.Response.notFound('{}');
    }

    ///There is an active call, update the peer state.
    _peerlist.get(user.extension).inTransition = true;

    ///Perfrom the hangup
    try {
      await _pbxController.killChannel(call.channel);
      _peerlist.get(user.extension).inTransition = false;

      return new shelf.Response.ok('{}');
    } catch (error, stackTrace) {
      final String msg = 'Failed kill the channel: (${call.channel})';
      _log.severe(msg, error, stackTrace);

      /// We can no longer assume anything about the users' state.
      _peerlist.get(user.extension).inTransition = false;

      return serverError(msg);
    }
  }

  /**
   * Hangup a specific call identified by the supplied call id.
   */
  Future<shelf.Response> hangupSpecific(shelf.Request request) async {
    final String callID = shelf_route.getPathParameter(request, 'callid');

    model.User user;

    /// Groups able to hangup any call.
    List<String> hangupGroups = ['Administrator'];

    bool aclCheck(model.User user) =>
        user.groups.any(hangupGroups.contains) ||
        _callList.get(callID).assignedTo == user.id;

    if (callID == null || callID == "") {
      return new shelf.Response(400, body: 'Empty call_id in path.');
    }

    /// User object fetching.
    try {
      user = await authService.userOf(tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      _log.severe(msg, error, stackTrace);

      return serverError(msg);
    }

    /// The agent is not allowed to terminate the call.
    if (!aclCheck(user)) {
      return new shelf.Response.forbidden('Insufficient privileges.');
    }

    /// Verify existence of call targeted for hangup.
    model.Call targetCall;
    try {
      targetCall = _callList.get(callID);
    } on NotFound catch (_) {
      return new shelf.Response.notFound(JSON.encode({'call_id': callID}));
    }

    model.Peer peer = _peerlist.get(user.extension);

    /// Update peer state.
    peer.inTransition = true;

    ///Completer
    Completer<model.Call> completer = new Completer<model.Call>();

    _callList.onEvent
        .firstWhere(
            (event.Event e) => e is event.CallHangup && e.call.id == callID)
        .then((event.CallHangup hangupEvent) =>
            completer.complete(hangupEvent.call));

    return await _pbxController.hangup(targetCall).then((_) {
      return completer.future.then((model.Call hungupCall) {
        /// Update peer state.
        peer.inTransition = false;
        return new shelf.Response.ok(JSON.encode(hungupCall));
      }).timeout(new Duration(seconds: 3));
    }).catchError((error, stackTrace) {
      /// Update peer state.
      peer.inTransition = false;

      _log.severe(error, stackTrace);
      return new shelf.Response.internalServerError();
    });
  }

  /**
   * Lists every active call in system.
   */
  shelf.Response list(shelf.Request request) =>
      new shelf.Response.ok(JSON.encode(_callList));

  /**
   * Originate a new call by first creating a parked phone channel to the
   * agent and then perform the orgination in the background.
   */
  Future<shelf.Response> originate(shelf.Request request) async {
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

    model.User user;
    model.Peer peer;

    /// Call is a SIP call.
    if (host != null) {
      extension = '$extension@$host:$port';
    }

    _log.finest('Originating to ${extension} in context '
        '${contactID}@${receptionID}');

    /// Any authenticated user is allowed to originate new calls.
    bool aclCheck(model.User user) => true;

    bool validExtension(String extension) =>
        extension != null && extension.length > 1;

    /// User object fetching.
    try {
      user = await authService.userOf(tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      _log.severe(msg, error, stackTrace);

      return serverError(msg);
    }

    if (!aclCheck(user)) {
      return new shelf.Response.forbidden('Insufficient privileges.');
    }

    if (!validExtension(extension)) {
      return new shelf.Response(400, body: 'Invalid extension: $extension');
    }

    /// Retrieve peer information.
    peer = _peerlist.get(user.extension);

    /// The user has not registered its peer to transfer the call to. Abort.
    if (peer == null || !peer.registered) {
      return clientError('User with id ${user.id} has no peer '
          '(peer: ${user.extension}) available');
    }

    /// The user has no reachable phone to transfer the call to. Abort.
    if (_phoneUnreachable(peer)) {
      return clientError('Phone is not ready. ${_peerInfo(peer)}');
    }

    /// Update the peer state
    peer.inTransition = true;

    bool isSpeaking(model.Call call) => call.state == model.CallState.speaking;

    Future parkIt(model.Call call) => _pbxController.park(call, user);

    /// Park all the users calls.
    try {
      await Future.forEach(
          _callList.callsOf(user.id).where(isSpeaking), parkIt);
    } catch (error, stackTrace) {
      final String msg = 'Failed to park user\'s active calls';
      _log.severe(msg, error, stackTrace);
      peer.inTransition = false;

      return serverError(msg);
    }

    /// Create an agent channel;
    String agentChannel;
    try {
      agentChannel = await _pbxController.createAgentChannel(user);
    } on controller.CallRejected {
      peer.inTransition = false;

      return clientError('Phone is not reachable'
          ' (call rejected). Check configuration.');
    } on controller.NoAnswer {
      peer.inTransition = false;

      return clientError('Phone is not reachable'
          ' (no answer). Check autoanswer.');
    } catch (error, stackTrace) {
      final String msg = 'Failed to create agent channel';
      _log.severe(msg, error, stackTrace);
      peer.inTransition = false;

      return serverError(msg);
    }

    /// Create a subscription that listens for the next outbound call.
    bool outboundCallWithUuid(esl.Event e) =>
        e.eventName == 'CHANNEL_ORIGINATE' &&
        e.channel.fields['Other-Leg-Unique-ID'] == agentChannel;

    Future<model.Call> outboundCall = _pbxController.eslClient.eventStream
        .firstWhere(outboundCallWithUuid, defaultValue: () => null)
        .then((esl.Event e) => _callList.createCall(e));

    /// At this point, we have an active agent channel and may perform
    /// the origination through the PBX by transferring our active agent
    /// channel to the outbound extension.
    model.Call call;
    try {
      await _pbxController.transferUUIDToExtension(
          agentChannel, extension, user, dialplan);
      call = await outboundCall.timeout(new Duration(seconds: 1));
    } catch (error, stackTrace) {
      final String msg = 'Failed to get call channel';
      _log.severe(msg, error, stackTrace);

      peer.inTransition = false;

      return serverError(msg);
    }

    /// Update the call with the info from the originate request.
    call
      ..assignedTo = user.id
      ..callerId = config.callFlowControl.callerIdNumber
      ..destination = extension
      ..rid = receptionID
      ..cid = contactID
      ..bLeg = agentChannel;

    /// Update call and peer state information.
    call.changeState(model.CallState.ringing);

    try {
      await _pbxController.setVariable(
          call.channel, ORPbxKey.userId, user.id.toString());
      await _pbxController.setVariable(
          call.channel, ORPbxKey.receptionId, receptionID.toString());
      await _pbxController.setVariable(
          call.channel, ORPbxKey.contactId, contactID.toString());
      await _pbxController.setVariable(
          call.channel, ORPbxKey.destination, extension);

      if (callId.isNotEmpty) {
        await _pbxController.setVariable(
            call.channel, ORPbxKey.contextCallId, callId);
      }
    } catch (error, stackTrace) {
      final String msg = 'Failed to create agent channel';
      _log.severe(msg, error, stackTrace);
      peer.inTransition = false;
      return serverError(msg);
    }

    peer.inTransition = false;
    return new shelf.Response.ok(JSON.encode(call));
  }

  /**
   * Park a specific call.
   */
  Future<shelf.Response> park(shelf.Request request) async {
    final String callID = shelf_route.getPathParameter(request, "callid");

    List<String> parkGroups = [
      'Administrator',
      'Service_Agent',
      'Receptionist'
    ];

    model.User user;

    bool aclCheck(model.User user) =>
        _callList.get(callID).assignedTo == user.id ||
        user.groups.any((group) => parkGroups.contains(group));

    /// User object fetching.
    try {
      user = await authService.userOf(tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      _log.severe(msg, error, stackTrace);

      return serverError(msg);
    }

    if (callID == null || callID == "") {
      return clientError('Empty call_id in path.');
    }

    model.Call call;
    try {
      call = _callList.get(callID);
    } on NotFound {
      return notFoundJson({'description': 'callID : $callID'});
    }

    if (!aclCheck(user)) {
      return new shelf.Response.forbidden('Insufficient privileges.');
    }

    try {
      await _pbxController.park(call, user);
      _log.finest('Parked call ${call.id}');

      return okJson(call);
    } catch (error, stackTrace) {
      _log.severe(error, stackTrace);
      return new shelf.Response.internalServerError();
    }
  }

  /**
   *
   */
  bool _phoneUnreachable(model.Peer peer) =>
      peer.inTransition || _channelList.hasActiveChannels(peer.name);

  /**
   * Pickup a specific call.
   */
  Future<shelf.Response> pickup(shelf.Request request) async {
    final String callID = shelf_route.getPathParameter(request, 'callid');
    model.User user;
    model.Peer peer;
    model.Call assignedCall;
    String agentChannel;
    int originallyAssignedTo = model.User.noId;

    /// Parameter check.
    if (callID == null || callID == "") {
      return clientError('Empty call_id in path.');
    }

    /// User object fetching.
    try {
      user = await authService.userOf(tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      _log.severe(msg, error, stackTrace);

      return serverError(msg);
    }

    /// Retrieve peer information.
    peer = _peerlist.get(user.extension);

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
      assignedCall = _callList.requestSpecificCall(callID, user);
    } on Conflict {
      return new shelf.Response(409,
          body: JSON.encode({'error': 'Call not currently available.'}));
    } on NotFound {
      return new shelf.Response.notFound(
          JSON.encode({'error': 'No calls available.'}));
    } on Forbidden {
      return new shelf.Response.forbidden(
          JSON.encode({'error': 'Call already assigned.'}));
    } catch (error, stackTrace) {
      final String msg = 'Failed retrieve call from call list';
      _log.severe(msg, error, stackTrace);

      return serverError(msg);
    }

    /// Update the user state
    peer.inTransition = true;
    originallyAssignedTo = assignedCall.assignedTo;
    assignedCall.assignedTo = user.id;

    _log.finest('Assigned call ${assignedCall.id} to user with ID ${user.id}');

    /// Create an agent channel
    try {
      agentChannel = await _pbxController.createAgentChannel(user);
    } catch (error, stackTrace) {
      final String msg = 'Failed to create agent channel';
      _log.severe(msg, error, stackTrace);

      peer.inTransition = false;

      /// Revert the call to the user it was originally assigned to.
      assignedCall.assignedTo = originallyAssignedTo;

      /// Make sure the agent channel is closed before returning a response.
      return await new Future.delayed(new Duration(seconds: 3)).then((_) =>
          _pbxController
              .killChannel(agentChannel)
              .then((_) => serverError(msg))
              .catchError((error, stackTrace) {
            _log.severe('Failed to close agent channel', error, stackTrace);
            return serverError(msg);
          }));
    }

    /// Channel bridging
    try {
      await _pbxController.bridgeChannel(agentChannel, assignedCall);
    } catch (error, stackTrace) {
      final String msg = 'Failed to bridge channels: '
          '$agentChannel and $assignedCall. '
          'Killing agent channel $agentChannel';
      _log.severe(msg, error, stackTrace);

      peer.inTransition = false;

      /// Make sure the agent channel is closed before returning a response.
      return await _pbxController
          .killChannel(agentChannel)
          .then((_) => serverError(msg))
          .catchError((error, stackTrace) {
        _log.severe('Failed to close agent channel', error, stackTrace);
        return serverError(msg);
      });
    }

    /// Tag the channel as assigned to the user.
    try {
      await _pbxController.setVariable(
          assignedCall.channel, ORPbxKey.userId, user.id.toString());
    } catch (error, stackTrace) {
      final String msg = 'Failed set user id for channel $agentChannel.'
          'Channel reload will be inaccurate.';
      _log.warning(msg, error, stackTrace);
    }

    /// Update the user state. At this point, all is well.
    peer.inTransition = false;
    assignedCall.locked = false;
    return new shelf.Response.ok(JSON.encode(assignedCall));
  }

  /**
   * Transfer (bridge) two calls in the PBX.
   */
  Future<shelf.Response> transfer(shelf.Request request) async {
    String sourceCallID = shelf_route.getPathParameter(request, "aleg");
    String destinationCallID = shelf_route.getPathParameter(request, 'bleg');
    model.Call sourceCall = null;
    model.Call destinationCall = null;
    model.User user;

    if (sourceCallID == null || sourceCallID == "") {
      return new shelf.Response(400, body: 'Empty call_id in path.');
    }

    ///Check valitity of the call. (Will raise exception on invalid).
    try {
      [sourceCallID, destinationCallID].forEach(model.Call.validateID);
    } on FormatException catch (_) {
      return new shelf.Response(400,
          body: 'Error in call id format (empty, null, nullID)');
    }

    try {
      sourceCall = _callList.get(sourceCallID);
      destinationCall = _callList.get(destinationCallID);
    } on NotFound catch (_) {
      return new shelf.Response.notFound(JSON.encode({
        'description': 'At least one of the calls are ' 'no longer available'
      }));
    }

    _log.finest('Transferring $sourceCall -> $destinationCall');

    /// Sanity check - are any of the calls already bridged?
    if ([sourceCall, destinationCall]
        .every((model.Call call) => call.state != model.CallState.parked)) {
      _log.warning('Potential invalid state detected; trying to bridge a '
          'non-parked call in an attended transfer. uuids:'
          '($sourceCall => $destinationCall)');
    }

    _log.finest('Transferring $sourceCall -> $destinationCall');

    /// User object fetching.
    try {
      user = await authService.userOf(tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      _log.severe(msg, error, stackTrace);

      return serverError(msg);
    }

    model.Peer peer = _peerlist.get(user.extension);

    /// Update peer state.
    peer.inTransition = true;

    return await _pbxController.bridge(sourceCall, destinationCall).then((_) {
      return new shelf.Response.ok('{"status" : "ok"}');
    }).catchError((error, stackTrace) {
      _log.severe(error, stackTrace);
      return new shelf.Response.internalServerError();
    }).whenComplete(() => peer.inTransition = false);
  }

  /**
   * Remove a specific call identified by the supplied call id.
   */
  Future<shelf.Response> remove(shelf.Request request) async {
    final String callID = shelf_route.getPathParameter(request, 'callid');

    model.User user;

    /// Groups able to remove any call.
    List<String> updateGroups = ['Administrator'];

    bool aclCheck(model.User user) =>
        user.groups.any(updateGroups.contains) ||
        _callList.get(callID).assignedTo == user.id;

    if (callID == null || callID == "") {
      return new shelf.Response(400, body: 'Empty call_id in path.');
    }

    /// User object fetching.
    try {
      user = await authService.userOf(tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      _log.severe(msg, error, stackTrace);

      return serverError(msg);
    }

    /// The agent is not allowed to terminate the call.
    if (!aclCheck(user)) {
      return new shelf.Response.forbidden('Insufficient privileges.');
    }

    /// Verify existence of call targeted for update.
    if (_callList.containsID(callID)) {
      _callList.remove(callID);
      return okJson({});
    } else {
      return notFoundJson({'call_id': callID});
    }
  }

  /**
   * Update a specific call identified by the supplied call id.
   */
  Future<shelf.Response> update(shelf.Request request) async {
    final String callID = shelf_route.getPathParameter(request, 'callid');

    model.User user;

    model.Call updatedCall;
    try {
      updatedCall = await request
          .readAsString()
          .then(JSON.decode)
          .then((Map map) => new model.Call.fromMap(map));
    } catch (error, stackTrace) {
      _log.warning(
          'Bad parameters from user '
          '${user.name} (id:${user.id})',
          error,
          stackTrace);
      return clientError(error.toString());
    }

    /// Groups able to update a call.
    List<String> updateGroups = ['Administrator'];

    bool aclCheck(model.User user) =>
        user.groups.any(updateGroups.contains) ||
        _callList.get(callID).assignedTo == user.id;

    if (callID == null || callID == "") {
      return new shelf.Response(400, body: 'Empty call_id in path.');
    }

    /// User object fetching.
    try {
      user = await authService.userOf(tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      _log.severe(msg, error, stackTrace);

      return serverError(msg);
    }

    /// The agent is not allowed to terminate the call.
    if (!aclCheck(user)) {
      return new shelf.Response.forbidden('Insufficient privileges.');
    }

    /// Verify existence of call targeted for update.
    if (_callList.containsID(callID)) {
      _callList.update(callID, updatedCall);
      return okJson(updatedCall);
    } else {
      return notFoundJson({'call_id': callID});
    }
  }
}
