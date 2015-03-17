part of callflowcontrol.router;


Map hangupCallIDOK (callID) =>
    {'status'      : 'ok',
     'description' : 'Request to hang up ${callID} sent.'};

Map hangupCommandOK (peerID) =>
         {'status'      : 'ok',
          'description' : 'Request for ${peerID} to hang up sent.'};

void handlerCallHangup(HttpRequest request) {

       final String token   = request.uri.queryParameters['token'];

       bool aclCheck (ORModel.User user) => true;

       AuthService.userOf(token).then((ORModel.User user) {

         if (!aclCheck(user)) {
           forbidden(request, 'Insufficient privileges.');
           return;
         }

         try {
           ESL.Peer peer = Model.PeerList.get(user.peer);

           Model.UserStatusList.instance.update(user.ID, ORModel.UserState.HangingUp);

           Controller.PBX.hangupCommand (peer).then ((_) {

             Model.UserStatusList.instance.update(user.ID, ORModel.UserState.HandlingOffHook);

             writeAndClose(request, JSON.encode(hangupCommandOK(peer.ID)));

           }).catchError((error, stackTrace) {
             Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Unknown);
             serverErrorTrace(request, error, stackTrace: stackTrace);

           });

         } catch (error, stackTrace) {
            Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Unknown);
            serverErrorTrace(request, error, stackTrace: stackTrace);
         }
       }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));
     }

void handlerCallHangupSpecific(HttpRequest request) {

  final String callID  = pathParameterString(request.uri, 'call');
  final String token   = request.uri.queryParameters['token'];

  List<String> hangupGroups = ['Administrator'];

  bool aclCheck (ORModel.User user)
    => user.groups.any(hangupGroups.contains)
    || Model.CallList.instance.get(callID).assignedTo == user.ID;

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
      notFound (request, {'call_id' : callID});
      return;
    }

    /// Update user state.
    Model.UserStatusList.instance.update(user.ID, ORModel.UserState.HangingUp);

    Controller.PBX.hangup (targetCall).then ((_) {

      /// Update user state.
      Model.UserStatusList.instance.update(user.ID, ORModel.UserState.WrappingUp);
      writeAndClose(request, JSON.encode(hangupCallIDOK(callID)));

    }).catchError((error, stackTrace) {
      /// Update user state.
      Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Unknown);
      serverErrorTrace(request, error, stackTrace: stackTrace);

    });
  }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));
}
