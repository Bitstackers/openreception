part of callflowcontrol.router;


Map hangupOK (callID) =>
    {'status'      : 'ok',
     'description' : 'Request to hang up ${callID} sent.'};

void handlerCallHangup(HttpRequest request) {

  final String context = '${libraryName}.handlerCallHangup';

  final String callID  = pathParameterString(request.uri, 'call');
  final String token   = request.uri.queryParameters['token'];

  List<String> hangupGroups = ['Administrator'];

  bool aclCheck (User user)
    => user.groups.any(hangupGroups.contains)
    || Model.CallList.instance.get(callID).assignedTo == user.ID;

  if (callID == null || callID == "") {
    clientError(request, "Empty call_id in path.");
    return;
  }

  AuthService.userOf(token).then((User user) {

    if (!aclCheck(user)) {
      forbidden(request, 'Insufficient privileges.');
      return;
    }

    try {
      Model.Call call = Model.CallList.instance.get(callID);

      Controller.PBX.hangup (call).then ((_) =>
        writeAndClose(request, JSON.encode(hangupOK(callID)))
      ).catchError((error, stackTrace) {
        if (error is Model.NotFound) {
          notFound (request, {'call_id' : callID});
       } else {
         serverErrorTrace(request, error, stackTrace: stackTrace);
       }

      }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));

    } catch (error, stackTrace) {
      if (error is Model.NotFound) {
        notFound (request, {'call_id' : callID});
     } else {
       serverErrorTrace(request, error, stackTrace: stackTrace);
     }
    }
  }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));
}
