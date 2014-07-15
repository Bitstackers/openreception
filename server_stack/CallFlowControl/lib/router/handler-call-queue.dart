part of callflowcontrol.router;

void handlerCallQueue(HttpRequest request) {

  final String context = '${libraryName}.handlerCallQueue';

  try {
    List<Model.Call> calls = new List<Model.Call>();
    Model.CallList.instance.where((Model.Call call) => call.isCall).forEach ((Model.Call call) {
      calls.add(call);
    });
  
    writeAndClose(request, JSON.encode({'calls' : calls}));
  } catch (error, stackTrace) {
    serverErrorTrace(request, error, stackTrace: stackTrace);    
  }
}
