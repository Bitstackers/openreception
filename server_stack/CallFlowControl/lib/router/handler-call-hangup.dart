part of callflowcontrol.router;


void handlerCallHangup(HttpRequest request) {
  String callID = pathParameterString(request.uri, "call");

  if (callID == null || callID == "") {
    clientError(request, "Empty call_id in path.");
    return;
  }

  final String context = '${libraryName}.handlerCallHangup';

  getUserMap(request, config.authUrl).then((Map user) {

    extractContent(request).then((String content) {
      clientSocket.connect().then((clientSocket client) {
        client.command({
          "resource": "call_hangup",
          "parameters": {
            "call_id": callID
          },
          "user": user

        }).then((Response response) {
          writeAndClose(request, JSON.encode(response.content));
        }).catchError((Error error) {
          if (error is NotFound) {
            resourceNotFound(request);
          } else if (error is BadRequest) {
            clientError(request, error.toString());
          } else {
            serverError(request, error.toString());
          }
        });
      });
    });
  });
}
