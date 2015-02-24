part of callflowcontrol.router;

void handlerCallList(HttpRequest request) {

  try {
    writeAndClose(request, JSON.encode({'calls' : Model.CallList.instance}));
  } catch (error, stackTrace) {
    serverErrorTrace(request, error, stackTrace: stackTrace);
  }

}
