part of openreception.service;

class RESTReceptionStore implements Storage.Reception {

  static final String className = '${libraryName}.RESTReceptionStore';

  WebService _backend = null;
  Uri        _host;
  String     _token = '';

  RESTReceptionStore (Uri this._host, String this._token, this._backend);

  /**
   * Returns a reception as a pure map.
   */
  Future<Map> getMap(int receptionID) {
    Uri url = Resource.Reception.single(this._host, receptionID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response)
        => JSON.decode(response));
  }

  /**
   * Returns a reception list as a list of maps.
   */
  Future<Iterable<Map>> listMap () {
    Uri url = Uri.parse('${this._host}/reception/TMPfullList');
        url = appendToken(url, this._token);

    return this._backend.get(url)
      .then((String response) => (JSON.decode(response)));
  }

  Future<Map> removeMap(int receptionID) {
    Uri url = Resource.Reception.single(this._host, receptionID);
        url = appendToken(url, this._token);

    return this._backend.delete(url).then((String response) =>
        JSON.decode(response));
  }


  Future<Map> saveMap (Map receptionMap) {
    return new Future.error(new UnimplementedError());
  }

  Future<List<Map>> calendarMap (int receptionID) {
    Uri url = Resource.Reception.calendar(this._host, receptionID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) {
      var decodedData = JSON.decode(response);

      if (decodedData is Map) {
        return  (JSON.decode(response)
            ['CalendarEvents'] as List);

      } else {
        return (JSON.decode(response) as List);
      }
    });
  }

  Future<Map> calendarEventMap (int receptionID, int eventID) {
    return new Future.error(new UnimplementedError());
  }

  Future<Map> calendarEventCreateMap (Map eventMap) {
    return new Future.error(new UnimplementedError());
  }

  Future<Map> calendarEventUpdateMap (Map eventMap) {
    return new Future.error(new UnimplementedError());
  }

  Future calendarEventRemoveMap (Map eventMap) {
    return new Future.error(new UnimplementedError());
  }


  Future<Model.Reception> get(int receptionID) =>
      this.getMap(receptionID).then((Map map) =>
          new Model.Reception.fromMap (map));


  Future<Model.Reception> create(Model.Reception reception) {
    Uri url = Resource.Reception.root(this._host);
        url = appendToken(url, this._token);

    String data = JSON.encode(reception.asMap);

    return this._backend.post(url, data).then((String response) =>
        new Model.Reception.fromMap (JSON.decode(response)));
  }

  Future<Model.Reception> update(Model.Reception reception) {
    Uri url = Resource.Reception.single(this._host, reception.ID);
        url = appendToken(url, this._token);

    String data = JSON.encode(reception.asMap);

    return this._backend.put(url, data).then((String response) =>
        new Model.Reception.fromMap (JSON.decode(response)));
  }

  Future<Model.Reception> remove(int receptionID) {
    Uri url = Resource.Reception.single(this._host, receptionID);
        url = appendToken(url, this._token);

    return this._backend.delete(url).then((String response) =>
        new Model.Reception.fromMap (JSON.decode(response)));
  }

  Future<Model.Reception> save(Model.Reception reception) {
    if (reception.ID != null && reception.ID != Model.Reception.noID) {
      return this.update(reception);
    } else {
      return this.create(reception);
    }
  }

  Future<Iterable<Model.Reception>> list() {
    Uri url = Resource.Reception.list(this._host);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as List)
          .map((Map map) => new Model.Reception.fromMap(map)));
  }

  /**
   * Retrieves and autocasts a calendar list from the store.
   */
  Future<List<Model.CalendarEntry>> calendar (int receptionID) =>
      this.calendarMap(receptionID).then((List<Map> calendarMaps) =>
          calendarMaps.map((Map calendarMap) =>
              new Model.CalendarEntry.fromMap(calendarMap)).toList());

  Future<Model.CalendarEntry> calendarEvent (int receptionID, int eventID) {
    Uri url = Resource.Reception.calendarEvent(this._host, receptionID, eventID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        new Model.CalendarEntry.fromMap (JSON.decode(response)));
  }

  Future<Model.CalendarEntry> calendarEventCreate (Model.CalendarEntry event) {
    Uri url = Resource.Reception.calendar (this._host, event.receptionID);
        url = appendToken(url, this._token);

    String data = JSON.encode(event);

    return this._backend.post(url, data).then((String response) =>
        new Model.CalendarEntry.fromMap (JSON.decode(response)));
  }

  Future<Model.CalendarEntry> calendarEventUpdate (Model.CalendarEntry event) {
    Uri url = Resource.Reception.calendarEvent (this._host, event.receptionID, event.ID);
        url = appendToken(url, this._token);

    String data = JSON.encode(event);
    return this._backend.put(url, data).then((String response) =>
        new Model.CalendarEntry.fromMap (JSON.decode(response)));
  }

  Future calendarEventRemove (Model.CalendarEntry event) {
    Uri url = Resource.Reception.calendarEvent(this._host, event.receptionID, event.ID);
        url = appendToken(url, this._token);

    return this._backend.delete(url);
  }
}
