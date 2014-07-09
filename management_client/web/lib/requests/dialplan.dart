part of request;

Future<Dialplan> getDialplan(int receptionId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/reception/$receptionId/dialplan?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      if (request.status == 200) {
        String body = request.responseText;
        completer.complete(new Dialplan.fromJson(JSON.decode(body)));
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

Future updateDialplan(int receptionId, String dialplan) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url =
      '${config.serverUrl}/reception/$receptionId/dialplan?token=${config.token}';

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
      if (request.status == 200) {
        String body = request.responseText;
        completer.complete(new IvrList.fromJson(JSON.decode(body)));
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
      if (request.status == 200) {
        Map rawData = JSON.decode(request.responseText);
        List<Map> rawAudiofiles = rawData['audiofiles'];
        completer.complete(rawAudiofiles.map((Map file) => new Audiofile.fromJson(file)).toList());
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

Future<List<Playlist>> getPlaylistList() {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/playlist?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      if (request.status == 200) {
        Map rawData = JSON.decode(request.responseText);
        List<Map> rawPlaylistList = rawData['playlist'];
        completer.complete(rawPlaylistList.map((Map file) => new Playlist.fromJson(file)).toList());
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

Future<Playlist> getPlaylist(int playlistId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/playlist/$playlistId?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      if (request.status == 200) {
        completer.complete(new Playlist.fromJson(JSON.decode(request.responseText)));
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
