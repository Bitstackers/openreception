part of request;

Future<List<CalendarEvent>> getReceptionContactCalendar(int receptionId, int contactId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/reception/$receptionId/contact/$contactId/calendar?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        Map rawData = JSON.decode(body);
        List<Map> rawEvents = rawData['events'];
        completer.complete(rawEvents.map((Map event) => new CalendarEvent.fromJson(event)).toList());
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

Future createContactCalendarEvent(int receptionId, int contactId, String data) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/reception/${receptionId}/contact/${contactId}/calendar?token=${config.token}';

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

Future deleteContactCalendarEvent(int receptionId, int contactId, int eventId) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/reception/${receptionId}/contact/${contactId}/calendar/${eventId}?token=${config.token}';

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

Future updateContactCalendarEvent(int receptionId, int contactId, int eventId, String data) {
  final Completer completer = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/reception/${receptionId}/contact/${contactId}/calendar/${eventId}?token=${config.token}';

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
    ..send(data);

  return completer.future;
}
