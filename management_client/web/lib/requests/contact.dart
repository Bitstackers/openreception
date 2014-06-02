part of request;

Future<List<Contact>> getEveryContact() {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/contact?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.GET, url)
      ..onLoad.listen((_) {
        if (request.status == 200) {
          Map rawData = JSON.decode(request.responseText);
          List<Map> rawReceptions = rawData['contacts'];
          completer.complete(rawReceptions.map((r) => new Contact.fromJson(r)
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

Future<Contact> getContact(int contactId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/contact/$contactId?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.GET, url)
      ..onLoad.listen((_) {
        if (request.status == 200) {
          completer.complete(new Contact.fromJson(JSON.decode(
              request.responseText)));
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

Future updateContact(int contactId, String body) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/contact/$contactId?token=${config.token}';

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

Future<Map> createContact(String data) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/contact?token=${config.token}';

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

Future<List<ReceptionContact_ReducedReception>> getAContactsEveryReception(int
    contactId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/contact/$contactId/reception?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.GET, url)
      ..onLoad.listen((_) {
        if (request.status == 200) {
          Map rawData = JSON.decode(request.responseText);
          List<Map> rawReceptions = rawData['contacts'];
          completer.complete(rawReceptions.map((r) =>
              new ReceptionContact_ReducedReception.fromJson(r)).toList());
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

Future<List<String>> getContacttypeList() {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/contacttypes?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.GET, url)
      ..onLoad.listen((_) {
        if (request.status == 200) {
          Map rawData = JSON.decode(request.responseText);
          List<String> contacttypes = rawData['contacttypes'];
          completer.complete(contacttypes);
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

Future deleteContact(int contactId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/contact/$contactId?token=${config.token}';

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

Future<List<Organization>> getContactsOrganizationList(int contactId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/contact/${contactId}/organization?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.GET, url)
      ..onLoad.listen((_) {
        if (request.status == 200) {
          Map rawData = JSON.decode(request.responseText);
          List<Map> rawOrganizations = rawData['organizations'];
          completer.complete(rawOrganizations.map((r) =>
              new Organization.fromJson(r)).toList());
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
