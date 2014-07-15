part of callflowcontrol.router;

void handlerCallList(HttpRequest request) {

  final String context = '${libraryName}.handlerCallList';

  try {
    writeAndClose(request, JSON.encode({'calls' : Model.CallList.instance}));
  } catch (error, stackTrace) {
    serverErrorTrace(request, error, stackTrace: stackTrace);    
  }
  
}
