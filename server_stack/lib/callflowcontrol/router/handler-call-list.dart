part of callflowcontrol.router;

abstract class Call {

  static void list(HttpRequest request) {
    try {
      writeAndClose(request, JSON.encode({'calls' : Model.CallList.instance}));
    } catch (error, stackTrace) {
      serverErrorTrace(request, error, stackTrace: stackTrace);
    }
  }

  static void get(HttpRequest request) {
    String callID = pathParameterString(request.uri, 'call');

    try {
      Model.Call call = Model.CallList.instance.get (callID);
      writeAndClose(request, JSON.encode(call));
    } catch (error, stackTrace) {
      if (error is Model.NotFound) {
        notFound(request, {});
      } else {
        serverErrorTrace(request, error, stackTrace: stackTrace);
      }
    }
  }

}

