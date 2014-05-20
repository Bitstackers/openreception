part of callflowcontrol.router;

void handlerCallOrignate(HttpRequest request) {
  String reception_id = pathParameterString(request.uri, 'reception');
  String contact_id = pathParameterString(request.uri, 'contact');
  String extension = pathParameterString(request.uri, 'originate');
  
  print ('Originating to ${extension} in context ${contact_id}@${reception_id}');

  final String context = '${libraryName}.handlerCallOrignate';

  getUserMap(request, config.authUrl).then((Map user) {
    clientSocket.connect(config.callFlowHost, config.callFlowPort).then((clientSocket client) {
      Map socketRequest = {
        'resource': 'call_originate',
        'parameters': {
          'contact_id': contact_id,
          'reception_id': reception_id,
          'extension': extension
        },
        'user': user
      };

      return client.command(socketRequest).then((Response response) {
        writeAndClose(request, JSON.encode(response.content));
      });
    }).catchError((error) {
      if (error is NotFound) {
        resourceNotFound(request);
      } else if (error is BadRequest) {
        clientError(request, error.toString());
      } else if (error is NotAuthorized) {
        forbidden(request, error.toString());
      } else {
        serverError(request, error.toString());
      }

    });
  });

}
