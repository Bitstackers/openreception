part of request;

Future<List<User>> getUserList() {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/user?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      if (request.status == 200) {
        Map rawData = JSON.decode(request.responseText);
        List<Map> rawUsers = rawData['users'];
        completer.complete(rawUsers.map((r) => new User.fromJson(r)
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

Future<User> getUser(int userId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/user/$userId?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      if (request.status == 200) {
        completer.complete(
            new User.fromJson(JSON.decode(request.responseText)));
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

Future<Map> createUser(String data) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/user?token=${config.token}';

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

Future<Map> updateUser(int userId, String body) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/user/$userId?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.POST, url)
    ..onLoad.listen((_) {
      completer.complete(JSON.decode(request.responseText));
    })
    ..onError.listen((error) {
      //TODO logging.
      completer.completeError(error.toString());
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
      completer.complete(JSON.decode(request.responseText));
    })
    ..onError.listen((error) {
      //TODO logging.
      completer.completeError(error.toString());
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
      if (request.status == 200) {
        Map rawData = JSON.decode(request.responseText);
        List<Map> rawUserGroups = rawData['groups'];
        completer.complete(rawUserGroups.map((r) => new UserGroup.fromJson(r)).toList());
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

Future<List<UserGroup>> getGroupList() {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/group?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      if (request.status == 200) {
        Map rawData = JSON.decode(request.responseText);
        List<Map> rawUserGroups = rawData['groups'];
        completer.complete(rawUserGroups.map((r) => new UserGroup.fromJson(r)).toList());
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

Future<Map> joinUserGroup(int userId, int groupId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/user/$userId/group/$groupId?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.PUT, url)
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

Future<Map> leaveUserGroup(int userId, int groupId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/user/$userId/group/$groupId?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.DELETE, url)
    ..onLoad.listen((_) {
      if(request.status == 200) {
        completer.complete(JSON.decode(request.responseText));
      } else {
        completer.completeError(JSON.decode(request.responseText));
      }
    })
    ..onError.listen((error) {
      //TODO logging.
      completer.completeError(error.toString());
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
      if (request.status == 200) {
        Map rawData = JSON.decode(request.responseText);
        List<Map> rawIdentities = rawData['identities'];
        completer.complete(rawIdentities.map((r) => new UserIdentity.fromJson(r)).toList());
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

Future createUserIdentity(int userId, String data) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/user/$userId/identity?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.PUT, url)
    ..onLoad.listen((_) {
      if (request.status == 200) {
        Map rawData = JSON.decode(request.responseText);
        completer.complete();
      } else {
        completer.completeError('Bad status code. ${request.status}');
      }
    })
    ..onError.listen((e) {
      //TODO logging.
      completer.completeError(e.toString());
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
      if (request.status == 200) {
        Map rawData = JSON.decode(request.responseText);
        completer.complete();
      } else {
        completer.completeError('Bad status code. ${request.status}');
      }
    })
    ..onError.listen((error) {
      //TODO logging.
      completer.completeError(error);
    })
    ..send();

  return completer.future;
}
