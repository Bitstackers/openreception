part of request;

Future<List<User>> getUserList() {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/user?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        Map rawData = JSON.decode(body);
        List<Map> rawUsers = rawData['users'];
        completer.complete(rawUsers.map((r) => new User.fromJson(r)).toList());
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

Future<User> getUser(int userId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/user/$userId?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        completer.complete(new User.fromJson(JSON.decode(body)));
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

Future<Map> createUser(String data) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/user?token=${config.token}';

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

Future<Map> updateUser(int userId, String body) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/user/$userId?token=${config.token}';

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

Future<Map> deleteUser(int userId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/user/$userId?token=${config.token}';

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

Future<List<UserGroup>> getUsersGroup(int userId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/user/${userId}/group?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        Map rawData = JSON.decode(body);
        List<Map> rawUserGroups = rawData['groups'];
        completer.complete(rawUserGroups.map((Map r) => new UserGroup.fromJson(r)).toList());
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

Future<List<UserGroup>> getGroupList() {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/group?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        Map rawData = JSON.decode(body);
        List<Map> rawUserGroups = rawData['groups'];
        completer.complete(rawUserGroups.map((Map r) => new UserGroup.fromJson(r)).toList());
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

Future<Map> joinUserGroup(int userId, int groupId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/user/$userId/group/$groupId?token=${config.token}';

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
    ..send();

  return completer.future;
}

Future<Map> leaveUserGroup(int userId, int groupId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/user/$userId/group/$groupId?token=${config.token}';

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

Future<List<UserIdentity>> getUserIdentities(int userId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/user/$userId/identity?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        Map rawData = JSON.decode(body);
        List<Map> rawIdentities = rawData['identities'];
        completer.complete(rawIdentities.map((Map r) => new UserIdentity.fromJson(r)).toList());
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

Future createUserIdentity(int userId, String data) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/user/$userId/identity?token=${config.token}';

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

Future deleteUserIdentity(int userId, String identity) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/user/$userId/identity/${identity}?token=${config.token}';

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
