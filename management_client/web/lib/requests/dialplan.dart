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
          completer.complete(new Dialplan.fromJson(JSON.decode(
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

Future<List<Audiofile>> getAudiofileList() {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/audiofiles?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      if (request.status == 200) {
        Map rawData = JSON.decode(request.responseText);
        List<Map> rawAudiofiles = rawData['audiofiles'];
        completer.complete(rawAudiofiles.map((file) => new Audiofile.fromJson(file)).toList());
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
