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
  
  Service.Authentication.userOf(token: token, host: config.authUrl).then((User user) {

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
    
    });
  }).catchError((error) {
    if (error is Model.NotFound) {
      notFound (request, {'description' : 'callID : $callID'});
    }
  });
}
