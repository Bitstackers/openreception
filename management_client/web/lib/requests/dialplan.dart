part of request;

Future<Dialplan> getDialplan(int receptionId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/reception/$receptionId/dialplan?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        completer.complete(new Dialplan.fromJson(JSON.decode(body)));
      } else if (request.status == 403) {
        completer.completeError(new ForbiddenException(body));
      } else if (request.status == 500) {
        completer.completeError(new InternalServerError(body));
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

Future updateDialplan(int receptionId, String dialplan) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/reception/$receptionId/dialplan?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.POST, url)
    ..onLoad.listen((_) {
      try {
        String body = request.responseText;
        if (request.status == 200) {
          completer.complete(new Dialplan.fromJson(JSON.decode(body)));
        } else if (request.status == 403) {
          completer.completeError(new ForbiddenException(body));
        } else if (request.status == 500) {
          completer.completeError(new InternalServerError(body));
        } else {
          completer.completeError(new UnknowStatusCode(request.status, request.statusText, body));
        }
      } catch (e) {
        completer.completeError('Exception in updateDialplan ${e}');
      }
    })
    ..onError.listen((e) {
      //TODO logging.
      completer.completeError(e.toString());
    })
    ..send(dialplan);

  return completer.future;
}

Future<IvrList> getIvr(int receptionId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/reception/$receptionId/ivr?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        completer.complete(new IvrList.fromJson(JSON.decode(body)));
      } else if (request.status == 403) {
        completer.completeError(new ForbiddenException(body));
      } else if (request.status == 500) {
        completer.completeError(new InternalServerError(body));
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

Future updateIvr(int receptionId, String ivrList) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/reception/$receptionId/ivr?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.POST, url)
    ..onLoad.listen((_) {
      try {
        if (request.status == 200) {
          completer.complete(JSON.decode(request.responseText));
        } else {
          completer.completeError('Bad status code. ${request.status}');
        }
      } catch (e) {
        completer.completeError('Exception in updateIvr ${e}');
      }
    })
    ..onError.listen((e) {
      //TODO logging.
      completer.completeError(e.toString());
    })
    ..send(ivrList);

  return completer.future;
}

Future<List<Audiofile>> getAudiofileList(int receptionId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/reception/${receptionId}/audiofiles?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        Map rawData = JSON.decode(body);
        List<Map> rawAudiofiles = rawData['audiofiles'];
        completer.complete(rawAudiofiles.map((Map file) => new Audiofile.fromJson(file)).toList());
      } else if (request.status == 403) {
        completer.completeError(new ForbiddenException(body));
      } else if (request.status == 500) {
        completer.completeError(new InternalServerError(body));
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

Future<List<Playlist>> getPlaylistList() {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/playlist?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        Map rawData = JSON.decode(body);
        List<Map> rawPlaylistList = rawData['playlist'];
        completer.complete(rawPlaylistList.map((Map file) => new Playlist.fromJson(file)).toList());
      } else if (request.status == 403) {
        completer.completeError(new ForbiddenException(body));
      } else if (request.status == 500) {
        completer.completeError(new InternalServerError(body));
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

Future<Playlist> getPlaylist(int playlistId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/playlist/$playlistId?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        completer.complete(new Playlist.fromJson(JSON.decode(body)));
      } else if (request.status == 403) {
        completer.completeError(new ForbiddenException(body));
      } else if (request.status == 500) {
        completer.completeError(new InternalServerError(body));
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

Future<Map> createPlaylist(String data) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/playlist?token=${config.token}';

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

Future<Map> updatePlaylist(int playlistId, String body) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/playlist/$playlistId?token=${config.token}';

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

Future<Map> deletePlaylist(int playlistId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/playlist/$playlistId?token=${config.token}';

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

Future<List<DialplanTemplate>> getDialplanTemplates() {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/dialplantemplate?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      Map bodyMap = JSON.decode(request.responseText);
      List templateRoot = bodyMap['templates'];
      List<DialplanTemplate> list = templateRoot.map((Map json) => new DialplanTemplate.fromJson(json)).toList();
      completer.complete(list);
    })
    ..onError.listen((error) {
      //TODO logging.
      completer.completeError(error.toString());
    })
    ..send();

  return completer.future;
}

/**
 * Calls the user, and starts the recordings menu, for the specified [filename].
 */
Future<Map> recordSoundFile(int receptionId, String filename) {
  final Completer completer = new Completer();
  final encodeFileName = Uri.encodeComponent(filename);

  HttpRequest request;
  String url = '${config.serverUrl}/reception/$receptionId/record?token=${config.token}&filename=${encodeFileName}';

  request = new HttpRequest()
    ..open(HttpMethod.POST, url)
    ..onLoad.listen((_) {
      completer.complete(JSON.decode(request.responseText));
    })
    ..onError.listen((error) {
      //TODO logging.
      completer.completeError(error);
    })
    ..send();

  return completer.future;
}

/**
 * Deletes the recorded file: [filename].
 */
Future<Map> deleteSoundFile(int receptionId, String filename) {
  final Completer completer = new Completer();
  final encodeFilename = Uri.encodeComponent(filename);

  HttpRequest request;
  String url = '${config.serverUrl}/reception/$receptionId/record?token=${config.token}&filename=${encodeFilename}';

  request = new HttpRequest()
    ..open(HttpMethod.DELETE, url)
    ..onLoad.listen((_) {
      completer.complete(JSON.decode(request.responseText));
    })
    ..onError.listen((error) {
      //TODO logging.
      completer.completeError(error);
    })
    ..send();

  return completer.future;
}
