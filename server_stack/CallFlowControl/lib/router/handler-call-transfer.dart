part of callflowcontrol.router;

void handlerCallTransfer(HttpRequest request) {

  final String context = '${libraryName}.handlerCallTransfr';
  final String token   = request.uri.queryParameters['token'];

  String sourceCallID        = pathParameterString(request.uri, "call");
  String destinationCallID   = pathParameterString(request.uri, 'transfer');
  Model.Call sourceCall      = null;
  Model.Call destinationCall = null;

  if (sourceCallID == null || sourceCallID == "") {
    clientError(request, "Empty call_id in path.");
    return;
  }

  ///Check valitity of the call. (Will raise exception on invalid).
  try {
    [sourceCallID, destinationCallID].forEach(Model.Call.validateID);
  } on FormatException catch (_) {
      clientError(request, 'Error in call id format (empty, null, nullID)');
      return;
  }

  try {
    Model.Call sourceCall      = Model.CallList.instance.get(sourceCallID);
    Model.Call destinationCall = Model.CallList.instance.get(destinationCallID);
  } on Model.NotFound catch (_) {
    notFound(request, {'description' : 'At least one of the calls are '
                                       'no longer available'});
    return;
  }

  /// Sanity check - are any of the calls already bridged?
  if ([sourceCall, destinationCall].every((Model.Call call) => call.state != Model.CallState.Parked)) {
    logger.infoContext('Potential invalid state detected; trying to bridge a '
                       'non-parked call in an attended transfer. uuids:'
                       '($sourceCall => $destinationCall)',context);
  }

  /// Sanity check - are any of the calls just a channel?
  [sourceCall, destinationCall].forEach((Model.Call call) {
    if (!call.isCall) {
      logger.infoContext('Not a call: ${call.ID}',context);
    }
  });

  logger.debugContext('Transferring $sourceCall -> $destinationCall', context);

  AuthService.userOf(token).then((ORModel.User user) {
    /// Update user state.
    Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Transferring);

    Controller.PBX.bridge (sourceCall, destinationCall).then((_) {
      /// Update user state.
      Model.UserStatusList.instance.update(user.ID, ORModel.UserState.WrappingUp);
      writeAndClose(request, '{"status" : "ok"}');

    }).catchError((error, stackTrace) {
      /// Update user state.
      Model.UserStatusList.instance.update(user.ID, ORModel.UserState.Unknown);
      serverErrorTrace(request, error, stackTrace : stackTrace);
    });

  }).catchError((error, stackTrace) {
    serverErrorTrace(request, error, stackTrace: stackTrace);
  });

}
