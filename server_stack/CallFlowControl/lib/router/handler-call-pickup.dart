part of callflowcontrol.router;

Map pickupOK (Model.Call call) => call.toJson(); 
    //{'status' : 'ok',
    // 'call'   : call};

void handlerCallPickup(HttpRequest request) {

  String callID = pathParameterString(request.uri, "call");

  if (callID == null || callID == "") {
    clientError(request, "Empty call_id in path.");
    return;
  }
  final String context = '${libraryName}.handlerCallPickup';

  final String token   = request.uri.queryParameters['token'];
  
  bool aclCheck (User user) => true;
  
  Service.Authentication.userOf(token: token, host: config.authUrl).then((SharedModel.User user) {
    if (!aclCheck(user)) {
      forbidden(request, 'Insufficient privileges.');
      return;
    }
    
    try {
      if (!Model.PeerList.get (user.peer).registered) {
        clientError (request, "User with ${user.ID} has no peer available");
        return;
      }
    } catch (error) {
      clientError (request, "User with ${user.ID} has no peer available");
      logger.errorContext('Failed to lookup peer for user with ID ${user.ID}. Error : $error', context);
      return;
    }

    /// Park all the users calls.
    Model.CallList.instance.callsOf (user).where 
      ((Model.Call call) => call.state == Model.CallState.Speaking).forEach((Model.Call call) => call.park(user)); 
    
    Model.Call assignedCall = Model.CallList.instance.requestSpecificCall (callID, user);
    
    logger.debugContext ('Assigned call ${assignedCall.ID} to user with ID ${user.ID}', context);
    
    Controller.PBX.transfer (assignedCall, user.peer).then((_) {
      assignedCall.assignedTo = user.ID;
      writeAndClose(request, JSON.encode(pickupOK(assignedCall)));
      
    }).catchError((error, stackTrace) {
      serverErrorTrace(request, error, stackTrace: stackTrace);
    });
    
  }).catchError((error, stackTrace) {
    if (error is Model.NotFound) {
      notFound (request, {'reason' : 'No calls available.'});
    } else {
      serverErrorTrace(request, error, stackTrace: stackTrace);
    }
  }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));
}

void handlerCallPickupNext(HttpRequest request) {
  
  const String context = '${libraryName}.handlerCallPickupNext';
  final String token   = request.uri.queryParameters['token'];
  
  bool aclCheck (User user) => true;
  
  Service.Authentication.userOf(token: token, host: config.authUrl).then((User user) {
  
    if (!aclCheck(user)) {
      forbidden(request, 'Insufficient privileges.');
      return;
    }
    
    try {
      if (!Model.PeerList.get (user.peer).registered) {
        clientError (request, "User with ${user.ID} has no peer available");
        return;
      }
    } catch (error) {
      clientError (request, "User with ${user.ID} has no peer available");
      logger.errorContext('Failed to lookup peer for user with ID ${user.ID}. Error : $error', context);
      return;
    }
    
    
    Model.CallList.instance.callsOf (user).where 
      ((Model.Call call) => call.state == Model.CallState.Speaking).forEach((Model.Call call) => call.park(user));
    
    Model.Call assignedCall = Model.CallList.instance.requestCall (user);
    
    logger.debugContext ('Assigned call ${assignedCall.ID} to user with ID ${user.ID}', context);
    
    Controller.PBX.transfer (assignedCall, user.peer).then((_) {
      assignedCall.assignedTo = user.ID;
      writeAndClose(request, JSON.encode(pickupOK(assignedCall)));
    }).catchError((error, stackTrace) {
      serverErrorTrace(request, error, stackTrace: stackTrace);
    });
  }).catchError((error, stackTrace) {
    if (error is Model.NotFound) {
      notFound (request, {'reason' : 'No calls available.'});
    } else {
      serverErrorTrace(request, error, stackTrace: stackTrace);
    }
  }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));
}
