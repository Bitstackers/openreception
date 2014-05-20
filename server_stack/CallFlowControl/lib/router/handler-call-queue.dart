part of callflowcontrol.router;

void handlerCallQueue(HttpRequest request) {

  final String context = '${libraryName}.handlerCallList';

  getUserMap(request, config.authUrl).then((Map user) {
    clientSocket.connect(config.callFlowHost, config.callFlowPort).then((clientSocket client) {
      Map socketRequest = {
        "resource": "call_list",
        "parameters": request.uri.queryParameters,
        "user": user
      };

      print(JSON.encode(socketRequest));
      return client.command(socketRequest).then((Response response) {
        Map json = response.content;

        List<Map> queue = new List<Map>();

        (json['calls'] as List).where((Map call) => call['is_call']).forEach((Map call) {
          queue.add(call);
        });


        writeAndClose(request, JSON.encode({
          'calls': queue
        }));
      });
    }).catchError((error) {
      if (error is NotFound) {
        resourceNotFound(request);
      } else if (error is BadRequest) {
        clientError(request, error.toString());
      } else {
        serverError(request, error.toString());
      }
    });
  });
}
