part of callflowcontrol.router;

void handlerCallList(HttpRequest request) {

  final String context = '${libraryName}.handlerCallList';

  try {
    writeAndClose(request, JSON.encode({'calls' : Model.CallList.instance}));
  } catch (error) {
    serverError(request, error.toString());    
  }
}
