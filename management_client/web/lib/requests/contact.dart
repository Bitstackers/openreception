part of request;

Future<List<Contact>> getEveryContact() {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/contact?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.GET, url)
      ..onLoad.listen((_) {
        String body = request.responseText;
        if (request.status == 200) {
          Map rawData = JSON.decode(body);
          List<Map> rawContacts = rawData['contacts'];
          completer.complete(rawContacts.map((Map contactJson) =>
              new Contact.fromJson(contactJson)).toList());
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

Future<Contact> getContact(int contactId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/contact/$contactId?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.GET, url)
      ..onLoad.listen((_) {
        String body = request.responseText;
        if (request.status == 200) {
          completer.complete(new Contact.fromJson(JSON.decode(body)));
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

Future<Map> updateContact(int contactId, String body) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/contact/$contactId?token=${config.token}';

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

Future<Contact> createContact(String data) {
  final String context = 'requests.createContant';
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/contact?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.PUT, url)
      ..onLoad.listen((_) {
        String body = request.responseText;
        if (request.status == 200) {
          completer.complete(new Contact.fromJson(JSON.decode(body)));
        } else if (request.status == 403) {
          completer.completeError(new ForbiddenException(body));
        } else {
          completer.completeError(new UnknowStatusCode(request.status, request.statusText, body));
        }
      })
      ..onError.listen((error) {
        //TODO logging.
        log.warning('$context Failed with error: $error');
        completer.completeError(error);
      })
      ..send(data);

  return completer.future;
}

Future<List<ContactAttribute>> getContactWithAttributes(int contactId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/contact/$contactId/reception?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        Map rawData = JSON.decode(body);
        List attributes = rawData['contacts'];
        completer.complete(attributes.map((Map attribute) => new ContactAttribute.fromJson(attribute)).toList());
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

Future<Iterable<ORModel.Reception>> getColleagues(int contactId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/contact/$contactId/colleagues?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        Map rawData = JSON.decode(body);
        List<Map> rawReceptions = rawData['receptions'];
        completer.complete(rawReceptions.map((r) => new ORModel.Reception.fromMap(r)));
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

Future<List<String>> getContacttypeList() {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/contacttypes?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.GET, url)
      ..onLoad.listen((_) {
        String body = request.responseText;
        if (request.status == 200) {
          Map rawData = JSON.decode(body);
          List<String> contacttypes = rawData['contacttypes'];
          completer.complete(contacttypes);
        } else if (request.status == 403) {
          completer.completeError(new ForbiddenException(body));
        } else {
          completer.completeError(new UnknowStatusCode(request.status, request.statusText, body));
        }
      })
      ..onError.listen((e) {
        //TODO logging.
        completer.completeError(e.toString());
      })
      ..send();

  return completer.future;
}

Future<List<String>> getAddressTypeList() {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/addresstypes?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.GET, url)
      ..onLoad.listen((_) {
        String body = request.responseText;
        if (request.status == 200) {
          Map rawData = JSON.decode(body);
          List<String> addresstypes = rawData['addresstypes'];
          completer.complete(addresstypes);
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

Future deleteContact(int contactId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/contact/$contactId?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.DELETE, url)
      ..onLoad.listen((_) {
        String body = request.responseText;
        if (request.status == 200) {
          completer.complete(new Contact.fromJson(JSON.decode(body)));
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

Future<List<ORModel.Organization>> getContactsOrganizationList(int contactId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/contact/${contactId}/organization?token=${config.token}';

  request = new HttpRequest()
      ..open(HttpMethod.GET, url)
      ..onLoad.listen((_) {
        String body = request.responseText;
        if (request.status == 200) {
          Map rawData = JSON.decode(body);
          List<Map> rawOrganizations = rawData['organizations'];
          completer.complete(rawOrganizations.map((Map r) =>
              new ORModel.Organization.fromMap(r)).toList());
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
