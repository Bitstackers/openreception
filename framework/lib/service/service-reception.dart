part of openreception.service;

class RESTReceptionStore implements Storage.Reception {

  static final String className = '${libraryName}.RESTReceptionStore';

  WebService _backend = null;
  Uri        _host;
  String     _token = '';

  RESTReceptionStore (Uri this._host, String this._token, this._backend);

  Future<Model.Reception> get(int receptionID) {
    Uri url = ReceptionResource.single(this._host, receptionID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response)
        => new Model.Reception.fromMap (JSON.decode(response)));
  }

  Future<Model.Reception> create(Model.Reception reception) {
    Uri url = ReceptionResource.root(this._host);
        url = appendToken(url, this._token);

    String data = JSON.encode(reception.asMap);

    return this._backend.post(url, data).then((String response) =>
        new Model.Reception.fromMap (JSON.decode(response)));
  }

  Future<Model.Reception> update(Model.Reception reception) {
    Uri url = ReceptionResource.single(this._host, reception.ID);
        url = appendToken(url, this._token);

    String data = JSON.encode(reception.asMap);

    return this._backend.put(url, data).then((String response) =>
        new Model.Reception.fromMap (JSON.decode(response)));
  }

  Future<Model.Reception> remove(int receptionID) {
    Uri url = ReceptionResource.single(this._host, receptionID);
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

  //{int limit: 100, Model.ReceptionFilter filter}
  Future<List<Model.ReceptionStub>> list() {
    Uri url = ReceptionResource.list(this._host);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as Map)
          [Model.ReceptionJSONKey.RECEPTION_LIST]
          .map((Map map) => new Model.ReceptionStub.fromMap(map))
          .toList());
  }

  Future<List<Model.CalendarEvent>> calendar (int receptionID) {
    Uri url = ReceptionResource.calendar(this._host, receptionID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) {
      var decodedData = JSON.decode(response);

      if (decodedData is Map) {
        return  (JSON.decode(response)
            ['CalendarEvents'] as List)
            .map((Map map) => new Model.CalendarEvent.fromMap(map, receptionID))
            .toList();

      } else {
        return (JSON.decode(response) as List)
               .map((Map map) => new Model.CalendarEvent.fromMap(map, receptionID))
               .toList();

      }
    });
  }

  Future<Model.CalendarEvent> calendarEvent (int receptionID, int eventID) {
    Uri url = ReceptionResource.calendarEvent(this._host, receptionID, eventID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        new Model.CalendarEvent.fromMap (JSON.decode(response), receptionID));
  }

  Future<Model.CalendarEvent> calendarEventCreate (Model.CalendarEvent event) {
    Uri url = ReceptionResource.calendar (this._host, event.receptionID);
        url = appendToken(url, this._token);

    String data = JSON.encode(event);
    return this._backend.post(url, data).then((String response) =>
        new Model.CalendarEvent.fromMap (JSON.decode(response), event.receptionID));
  }

  Future<Model.CalendarEvent> calendarEventUpdate (Model.CalendarEvent event) {
    Uri url = ReceptionResource.calendarEvent (this._host, event.receptionID, event.ID);
        url = appendToken(url, this._token);

    String data = JSON.encode(event);
    return this._backend.put(url, data).then((String response) =>
        new Model.CalendarEvent.fromMap (JSON.decode(response), event.receptionID));
  }


  Future calendarEventRemove (Model.CalendarEvent event) {
    Uri url = ReceptionResource.calendarEvent(this._host, event.receptionID, event.ID);
        url = appendToken(url, this._token);

    return this._backend.delete(url);
  }
}
