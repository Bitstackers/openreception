part of callflowcontrol.router;

void handlerCallTransfer(HttpRequest request) {

  String callID = pathParameterString(request.uri, "call");
  String destinationCallID = pathParameterString(request.uri, 'transfer');

  if (callID == null || callID == "") {
    clientError(request, "Empty call_id in path.");
    return;
  }


  final String context = '${libraryName}.handlerCallHangup';

  getUserMap(request, config.authUrl).then((Map user) {
    extractContent(request).then((String content) {
      clientSocket.connect(config.callFlowHost, config.callFlowPort).then((clientSocket client) {
        client.command({
          "resource": "call_transfer",
          "parameters": {
            "source": callID,
            "destination" : destinationCallID
          },
          "user": user
        }).then((Response response) {
          writeAndClose(request, JSON.encode(response.content));
        }).catchError((Error error) {
          if (error is NotFound) {
            resourceNotFound(request);
          } else if (error is BadRequest) {
            clientError(request, error.toString());
          } else if (error is NotAuthorized) {
            forbidden(request, error.toString());
          }
          else {
            serverError(request, error.toString());
          }
        });
      });
    });
  });
}
