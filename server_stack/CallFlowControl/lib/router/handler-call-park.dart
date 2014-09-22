part of callflowcontrol.router;

Map parkOK (Model.Call call) =>
   {'status'   : 'ok',
     'message' : 'call parked',
     'call'    : call};

void handlerCallPark(HttpRequest request) {

  final String context = '${libraryName}.handlerCallPark';
  final String token   = request.uri.queryParameters['token'];

  String callID = pathParameterString(request.uri, "call");

  List<String> parkGroups = ['Administrator'];

  bool aclCheck (User user)
    => user.groups.any((group)
        => parkGroups.contains(group))
    || Model.CallList.instance.get(callID).assignedTo == user.ID;

  print ('Parking call $callID');

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

    Controller.PBX.park (call, user).then ((_) {
      writeAndClose(request, JSON.encode (parkOK (call)));

    }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));

  }).catchError((error, stackTrace) {
    if (error is Model.NotFound) {
      notFound (request, {'description' : 'callID : $callID'});
    } else {
      serverErrorTrace(request, error, stackTrace: stackTrace);
    }
  }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));

}
