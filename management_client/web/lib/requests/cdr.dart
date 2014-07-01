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
      if (request.status == 200) {
        Map rawData = JSON.decode(request.responseText);
        List<Map> rawEntries = rawData['cdr_stats'];
        completer.complete(rawEntries.map((r) => new Cdr_Entry.fromJson(r)).toList());
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
