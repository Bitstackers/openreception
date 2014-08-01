part of request;

Future<List<Organization>> getOrganizationList() {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/organization?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        Map rawData = JSON.decode(body);
        List<Map> rawOrganizations = rawData['organizations'];
        completer.complete(rawOrganizations.map((Map org) =>
            new Organization.fromJson(org)).toList());
      } else if (request.status == 403) {
        completer.completeError(new ForbiddenException(body));
      } else {
        completer.completeError(new UnknowStatusCode(request.status, request.statusText, body));
      }
    })
    ..onError.listen((error) {
      //TODO logging.
      completer.completeError(error);
    })
    ..send();

  return completer.future;
}

Future<List<Contact>> getOrganizationContactList(int organizationId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/organization/$organizationId/contact?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        Map rawData = JSON.decode(body);
        List<Map> rawReceptions = rawData['contacts'];
        completer.complete(rawReceptions.map((r) => new Contact.fromJson(r)
            ).toList());
      } else if (request.status == 403) {
        completer.completeError(new ForbiddenException(body));
      } else {
        completer.completeError(new UnknowStatusCode(request.status, request.statusText, body));
      }
    })
    ..onError.listen((error) {
      //TODO logging.
      completer.completeError(error);
    })
    ..send();

  return completer.future;
}

Future<List<Reception>> getAnOrganizationsReceptionList(int organizationId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/organization/$organizationId/reception?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        Map rawData = JSON.decode(body);
        List<Map> rawReceptions = rawData['receptions'];
        completer.complete(rawReceptions.map((reception) => new Reception.fromJson(reception)).toList());
      } else if (request.status == 403) {
        completer.completeError(new ForbiddenException(body));
      } else {
        completer.completeError(new UnknowStatusCode(request.status, request.statusText, body));
      }
    })
    ..onError.listen((error) {
      //TODO logging.
      completer.completeError(error);
    })
    ..send();

  return completer.future;
}

Future<Organization> getOrganization(int organizationId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/organization/$organizationId?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        completer.complete(new Organization.fromJson(JSON.decode(body)));
      } else if (request.status == 403) {
        completer.completeError(new ForbiddenException(body));
      } else {
        completer.completeError(new UnknowStatusCode(request.status, request.statusText, body));
      }
    })
    ..onError.listen((error) {
      //TODO logging.
      completer.completeError(error);
    })
    ..send();

  return completer.future;
}

Future<Map> createOrganization(String data) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/organization?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.PUT, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        completer.complete(JSON.decode(body));
      } else if (request.status == 403) {
        completer.completeError(new ForbiddenException(body));
      } else {
        completer.completeError(new UnknowStatusCode(request.status, request.statusText, body));
      }
    })
    ..onError.listen((error) {
      //TODO logging.
      completer.completeError(error);
    })
    ..send(data);

  return completer.future;
}

Future<Map> updateOrganization(int organizationId, String body) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/organization/$organizationId?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.POST, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        completer.complete(JSON.decode(body));
      } else if (request.status == 403) {
        completer.completeError(new ForbiddenException(body));
      } else {
        completer.completeError(new UnknowStatusCode(request.status, request.statusText, body));
      }
    })
    ..onError.listen((error) {
      //TODO logging.
      completer.completeError(error);
    })
    ..send(body);

  return completer.future;
}

Future<Map> deleteOrganization(int organizationId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/organization/$organizationId?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.DELETE, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        completer.complete(JSON.decode(body));
      } else if (request.status == 403) {
        completer.completeError(new ForbiddenException(body));
      } else {
        completer.completeError(new UnknowStatusCode(request.status, request.statusText, body));
      }
    })
    ..onError.listen((error) {
      //TODO logging.
      completer.completeError(error);
    })
    ..send();

  return completer.future;
}
