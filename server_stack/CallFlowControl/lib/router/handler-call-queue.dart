part of callflowcontrol.router;

void handlerCallQueue(HttpRequest request) {

  bool available(Model.Call call) => call.inbound &&
                                     (call.state == Model.CallState.Queued ||
                                      call.state == Model.CallState.Created);

  try {
    List<Model.Call> queuedCalls =
        Model.CallList.instance.where(available).toList(growable: false);

    writeAndClose(request, JSON.encode({
      'calls': queuedCalls
    }));
  } catch (error, stackTrace) {
    serverErrorTrace(request, error, stackTrace: stackTrace);
  }
}
