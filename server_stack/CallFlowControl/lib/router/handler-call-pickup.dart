part of callflowcontrol.router;

void handlerCallPickup(HttpRequest request) {

  String callID = pathParameterString(request.uri, "call");

  if (callID == null || callID == "") {
    clientError(request, "Empty call_id in path.");
    return;
  }


  final String context = '${libraryName}.handlerCallList';

  getUserMap(request, config.authUrl).then((Map user) {
    clientSocket.connect(config.callFlowHost, config.callFlowPort).then((clientSocket client) {
      Map socketRequest = {
        "resource": "call_pickup",
        "parameters": {
          "call_id": callID
        },
        "user": user
      };

      print(JSON.encode(socketRequest));
      return client.command(socketRequest).then((Response response) {
        print (response.content);
        writeAndClose(request, JSON.encode(response.content));
      });
    }).catchError((error) {
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
}

void handlerCallPickupNext(HttpRequest request) {

  final String context = '${libraryName}.handlerCallList';

  getUserMap(request, config.authUrl).then((Map user) {
    clientSocket.connect(config.callFlowHost, config.callFlowPort).then((clientSocket client) {
      Map socketRequest = {
        "resource": "call_pickup_next",
        "parameters": {},
        "user": user
      };

      print(JSON.encode(socketRequest));
      return client.command(socketRequest).then((Response response) {
        writeAndClose(request, JSON.encode(response.content));
      });
    }).catchError((error) {
      if (error is NotFound) {
        resourceNotFound(request);
      } else if (error is BadRequest) {
        clientError(request, error.toString());
      }
      else {
        serverError(request, error.toString());
      }
    });
  });
}
