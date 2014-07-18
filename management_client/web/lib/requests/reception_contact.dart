part of request;

Future updateReceptionContact(int receptionId, int contactId, String body) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/reception/$receptionId/contact/$contactId?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.POST, url)
      ..onLoad.listen((_) {
        completer.complete(request.responseText);
      })
      ..onError.listen((error) {
        //TODO logging.
        completer.completeError(error.toString());
      })
      ..send(body);

  return completer.future;
}

Future<Map> createReceptionContact(int receptionId, int contactId, String data) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/reception/${receptionId}/contact/${contactId}?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.PUT, url)
      ..onLoad.listen((_) {
        completer.complete(JSON.decode(request.responseText));
      })
      ..onError.listen((error) {
        //TODO logging.
        completer.completeError(error.toString());
      })
      ..send(data);

  return completer.future;
}

Future deleteReceptionContact(int receptionId, int contactId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/reception/$receptionId/contact/$contactId?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.DELETE, url)
      ..onLoad.listen((_) {
        completer.complete(JSON.decode(request.responseText));
      })
      ..onError.listen((error) {
        //TODO logging.
        completer.completeError(error.toString());
      })
      ..send();

  return completer.future;
}

Future<List<Endpoint>> getEndpointsList(int receptionId, int contactId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/reception/${receptionId}/contact/${contactId}/endpoint?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.GET, url)
      ..onLoad.listen((_) {
        if (request.status == 200) {
          Map rawData = JSON.decode(request.responseText);
          List<Map> rawEndpoints = rawData['endpoints'];
          completer.complete(rawEndpoints.map((Map end) => new Endpoint.fromJson(end)).toList());
        } else {
          completer.completeError('Bad status code. ${request.status}');
        }
      })
      ..onError.listen((e) {
        //TODO logging.
        completer.completeError(e.toString());
      })
      ..send();

  return completer.future;
}

Future<List<String>> getEndpoint(int receptionId, int contactId, String address, String addressType) {
  final Completer completer = new Completer();

  final String encodeAddress = Uri.encodeComponent(address);
  final String encodeAddressType = Uri.encodeComponent(addressType);
  HttpRequest request;
  String url = '${config.serverUrl}/reception/${receptionId}/contact/${contactId}/endpoint/${encodeAddress}/type/${encodeAddressType}?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      if (request.status == 200) {
        Map rawData = JSON.decode(request.responseText);
        completer.complete(new Endpoint.fromJson(rawData));
      } else {
        completer.completeError('Bad status code. ${request.status}');
      }
    })
    ..onError.listen((e) {
      //TODO logging.
      completer.completeError(e.toString());
    })
    ..send();

  return completer.future;
}

Future<Map> createEndpoint(int receptionId, int contactId, String data) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/reception/${receptionId}/contact/${contactId}/endpoint?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.PUT, url)
      ..onLoad.listen((_) {
        completer.complete(JSON.decode(request.responseText));
      })
      ..onError.listen((error) {
        //TODO logging.
        completer.completeError(error.toString());
      })
      ..send(data);

  return completer.future;
}

Future deleteEndpoint(int receptionId, int contactId, String address, String addressType) {
  final Completer completer = new Completer();
  final String encodeAddress = Uri.encodeComponent(address);
  final String encodeAddressType = Uri.encodeComponent(addressType);

  HttpRequest request;
  String url = '${config.serverUrl}/reception/$receptionId/contact/$contactId/endpoint/${encodeAddress}/type/${encodeAddressType}?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.DELETE, url)
      ..onLoad.listen((_) {
        completer.complete(JSON.decode(request.responseText));
      })
      ..onError.listen((error) {
        //TODO logging.
        completer.completeError(error.toString());
      })
      ..send();

  return completer.future;
}

Future updateEndpoint(int receptionId, int contactId, String address, String addressType, String body) {
  final Completer completer = new Completer();
  final String encodeAddress = Uri.encodeComponent(address);
  final String encodeAddressType = Uri.encodeComponent(addressType);

  HttpRequest request;
  String url =
      '${config.serverUrl}/reception/$receptionId/contact/$contactId/endpoint/${encodeAddress}/type/${encodeAddressType}?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.POST, url)
      ..onLoad.listen((_) {
        completer.complete(request.responseText);
      })
      ..onError.listen((error) {
        //TODO logging.
        completer.completeError(error.toString());
      })
      ..send(body);

  return completer.future;
}
