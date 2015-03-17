part of cdrserver.router;

void cdrHandler(HttpRequest request) {
  if(!request.uri.queryParameters.containsKey('date_from')) {
    clientError(request, 'Missing parameter: date_from');
    return;
  }
  if(!request.uri.queryParameters.containsKey('date_to')) {
    clientError(request, 'Missing parameter: date_to');
    return;
  }

  DateTime start, end;
  bool inbound;
  try {
    start = new DateTime.fromMillisecondsSinceEpoch(int.parse (request.uri.queryParameters['date_from'])*1000);
    end   = new DateTime.fromMillisecondsSinceEpoch(int.parse (request.uri.queryParameters['date_to'])*1000);
    inbound   = false;
  } catch(error) {
    clientError(request, 'Bad parameter: ${error}');
    return;
  }

  if (request.uri.queryParameters['inbound'] == "true") {
    inbound = true;
  }

  db.cdrList(inbound, start, end)
    .then((List orglist) => writeAndClose(request, JSON.encode({'cdr_stats' : orglist})))
    .catchError((error) => serverError(request, error.toString()));
}
