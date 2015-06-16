part of openreception.service;

/**
 *
 */
class RESTCDRService implements Storage.CDR {
  static final String className = '${libraryName}.RESTCDRStore';

  WebService _backend = null;
  Uri _host;
  String _token = '';

  RESTCDRService(Uri this._host, String this._token, this._backend);

  /**
   *
   */
  Future<Iterable<Model.CDREntry>> listEntries(DateTime from, DateTime to) {
    String fromParameter =
        'date_from=${(from.millisecondsSinceEpoch/1000).floor()}';
    String toParameter = 'date_to=${(to.millisecondsSinceEpoch/1000).floor()}';

    Uri url = Resource.CDR.list(this._host, fromParameter, toParameter);
    url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) {
      Iterable decodedData = JSON.decode(response)['cdr_stats'];

      return decodedData.map((r) => new Model.CDREntry.fromJson(r));
    });
  }

  /**
   *
   */
  Future<Iterable<Model.CDRCheckpoint>> checkpoints() {
    Uri url = Resource.CDR.checkpoint(this._host);
    url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        new Model.CalendarEntry.fromMap(JSON.decode(response)));
  }

  /**
   *
   */

  Future<Model.CDRCheckpoint> createCheckpoint(Model.CDRCheckpoint checkpoint) {
    Uri url = Resource.CDR.checkpoint(this._host);
    url = appendToken(url, this._token);

    return this._backend.post(url, JSON.encode(checkpoint))
      .then((String response) =>
        new Model.CalendarEntry.fromMap(JSON.decode(response)));
  }
}
