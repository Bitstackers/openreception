part of callflowcontrol.router;

Map parkOK (Model.Call call) =>
   {'status'   : 'ok',
     'message' : 'call parked',
     'call'    : call};

void handlerCallPark(HttpRequest request) {

  final String context = '${libraryName}.handlerCallPark';
  final String token   = request.uri.queryParameters['token'];

  String callID = pathParameterString(request.uri, "call");

  List<String> parkGroups = ['Administrator', 'Service_Agent', 'Receptionist'];

  bool aclCheck (User user)
    => user.groups.any((group)
        => parkGroups.contains(group))
    || Model.CallList.instance.get(callID).assignedTo == user.ID;

  AuthService.userOf(token).then((User user) {
    if (callID == null || callID == "") {
      clientError(request, "Empty call_id in path.");
      return;
    }

    Model.Call call = Model.CallList.instance.get(callID);

    if (!aclCheck(user)) {
      forbidden(request, 'Insufficient privileges.');
      return;
    }

    Model.UserStatusList.instance.update(user.ID, Model.UserState.Parking);

    Controller.PBX.park (call, user).then ((_) {
      Model.UserStatusList.instance.update(user.ID, Model.UserState.HandlingOffHook);

      writeAndClose(request, JSON.encode (parkOK (call)));

    }).catchError((error, stackTrace) {
        Model.UserStatusList.instance.update(user.ID, Model.UserState.Unknown);
        serverErrorTrace(request, error, stackTrace: stackTrace);
    });

  }).catchError((error, stackTrace) {
    if (error is Model.NotFound) {
      notFound (request, {'description' : 'callID : $callID'});
    } else {
      serverErrorTrace(request, error, stackTrace: stackTrace);
    }
  }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));

}
