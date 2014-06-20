part of callflowcontrol.router;

void handlerCallTransfer(HttpRequest request) {

  final String context = '${libraryName}.handlerCallTransfr';

  String sourceCallID = pathParameterString(request.uri, "call");
  String destinationCallID = pathParameterString(request.uri, 'transfer');

  if (sourceCallID == null || sourceCallID == "") {
    clientError(request, "Empty call_id in path.");
    return;
  }

  ///Check valitity of the call. (Will raise exception on invalid).
  try {
    [sourceCallID, destinationCallID].forEach(Model.Call.validateID);
     
    Model.Call sourceCall      = Model.CallList.instance.get(sourceCallID);
    Model.Call destinationCall = Model.CallList.instance.get(destinationCallID);

    /// Sanity check.
    if ([sourceCall, destinationCall].every((Model.Call call) => call.state != Model.CallState.Parked)) {
      logger.infoContext('Potential invalid state detected; trying to bridge a '
                         'non-parked call in an attended transfer. uuids:'
                         '($sourceCall => $destinationCall)',context);
    }
    [sourceCall, destinationCall].forEach((Model.Call call) {
      if (!call.isCall) {
        logger.infoContext('Not a call: ${call.ID}',context);
      }
    });

    logger.debugContext('Transferring $sourceCall -> $destinationCall', context);
    
    
    Controller.PBX.bridge (sourceCall, destinationCall);
    
  } catch (error) {
    if (error is FormatException) {
      clientError(request, error.toString());
    } else if (error is Model.NotFound) {
      notFound(request, {'description' : 'At least one of the calls are '
                                         'no longer available',
                         'error' : error.toString()});
    } else {
      serverError(request, error.toString());
    }
    
    return;
  }
   
}
