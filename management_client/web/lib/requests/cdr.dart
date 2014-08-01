part of request;

Future<List<Cdr_Entry>> getCdrEntries(DateTime from, DateTime to) {
  final Completer completer = new Completer();

  HttpRequest request;
  String fromParameter = 'date_from=${(from.millisecondsSinceEpoch/1000).floor()}';
  String toParameter = 'date_to=${(to.millisecondsSinceEpoch/1000).floor()}';
  String url = '${config.cdrUrl}/cdr?token=${config.token}&${fromParameter}&${toParameter}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      String body = request.responseText;
      if (request.status == 200) {
        Map rawData = JSON.decode(body);
        List<Map> rawEntries = rawData['cdr_stats'];
        completer.complete(rawEntries.map((r) => new Cdr_Entry.fromJson(r)).toList());
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
