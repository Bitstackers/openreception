part of request;

Future<List<Reception>> getReceptionList() {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/reception?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.GET, url)
      ..onLoad.listen((_) {
        if (request.status == 200) {
          Map rawData = JSON.decode(request.responseText);
          List<Map> rawReceptions = rawData['receptions'];
          completer.complete(rawReceptions.map((r) => new Reception.fromJson(r)
              ).toList());
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

Future<List<CustomReceptionContact>> getReceptionContactList(int receptionId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/reception/$receptionId/contact?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.GET, url)
      ..onLoad.listen((_) {
        if (request.status == 200) {
          Map rawData = JSON.decode(request.responseText);
          List<Map> rawReceptions = rawData['receptionContacts'];
          completer.complete(rawReceptions.map((r) =>
              new CustomReceptionContact.fromJson(r)).toList());
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

Future<Reception> getReception(int organization, int receptionId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/organization/$organization/reception/$receptionId?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      if (request.status == 200) {
        completer.complete(new Reception.fromJson(JSON.decode(request.responseText)));
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

Future<Map> createReception(int organizationId, String data) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/organization/$organizationId/reception?token=${config.token}';

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

Future updateReception(int organizationId, int receptionId, String data) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/organization/$organizationId/reception/$receptionId?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.POST, url)
      ..onLoad.listen((_) {
        completer.complete(request.responseText);
      })
      ..onError.listen((error) {
        //TODO logging.
        completer.completeError(error.toString());
      })
      ..send(data);

  return completer.future;
}

Future deleteReception(int organizationId, int receptionId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/organization/$organizationId/reception/$receptionId?token=${config.token}';

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
