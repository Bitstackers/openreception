part of cdrserver.router;


void cdrHandler(HttpRequest request) {

  DateTime start  = new DateTime.fromMillisecondsSinceEpoch(int.parse (request.uri.queryParameters['date_from'])*1000);
  DateTime end    = new DateTime.fromMillisecondsSinceEpoch(int.parse (request.uri.queryParameters['date_to'])*1000);
  bool inbound    = false;

  print (start.toString() + " - " + end.toString());

  if (request.uri.queryParameters['inbound'] == "true") {
    inbound = true;
  }

  db.cdrList(inbound, start, end).then((List orglist) {
    writeAndClose(request, JSON.encode({'cdr_stats' : orglist}));
  }).catchError((error) => serverError(request, error.toString()));

}
