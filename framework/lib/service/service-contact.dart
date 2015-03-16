part of openreception.service;

class RESTContactStore implements Storage.Contact {

  static final String className = '${libraryName}.RESTContactStore';
  static final Logger log = new Logger(className);

  WebService _backend = null;
  Uri        _host;
  String     _token = '';

  RESTContactStore (Uri this._host, String this._token, this._backend);

  Future<List<Map>> calendarMap (int contactID, int receptionID) {
    Uri url = Resource.Contact.calendar(this._host, contactID, receptionID);
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


  Future<Model.Contact> get(int contactID) {
    Uri url = Resource.Contact.single(this._host, contactID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        new Model.Contact.fromMap (JSON.decode(response)));
  }

  Future<Model.Contact> create(Model.Contact contact) {
    Uri url = Resource.Contact.root(this._host);
        url = appendToken(url, this._token);

    String data = JSON.encode(contact.asMap);
    return this._backend.put(url, data).then((String response) =>
        new Model.Contact.fromMap (JSON.decode(response)));
  }

  Future<Model.Contact> update(Model.Contact contact) {
    Uri url = Resource.Contact.single(this._host, contact.ID);
        url = appendToken(url, this._token);

    String data = JSON.encode(contact.asMap);
    return this._backend.post(url, data).then((String response) =>
        new Model.Contact.fromMap (JSON.decode(response)));
  }

  Future<Model.Contact> remove(Model.Contact contact) {
    Uri url = Resource.Contact.single(this._host, contact.ID);
        url = appendToken(url, this._token);

    return this._backend.delete(url).then((String response) =>
        new Model.Contact.fromMap (JSON.decode(response)));
  }

  Future<List<Model.Contact>> list() {
    Uri url = Resource.Contact.list(this._host);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as Map)
          [Model.ContactJSONKey.Contact_LIST]
          .map((Map map) => new Model.Contact.fromMap(map))
          .toList() );
  }

  Future<Model.Contact> getByReception(int contactID, int receptionID) {
    Uri url = Resource.Contact.singleByReception(this._host, contactID, receptionID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        new Model.Contact.fromMap (JSON.decode(response)));
  }

  Future<List<Model.Contact>> listByReception(int receptionID, {Model.ContactFilter filter}) {
    Uri url = Resource.Contact.listByReception(this._host, receptionID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
       (JSON.decode(response) as List)
            .map((Map map) => new Model.Contact.fromMap(map))
            .toList() );
  }

  Future<List<Model.CalendarEvent>> calendar (int contactID, int receptionID) =>
      calendarMap (contactID, receptionID).then((List<Map> maps) =>
          maps.map((Map map) => new Model.CalendarEvent.fromMap(map, receptionID)).toList());

  Future<Model.CalendarEvent> calendarEvent (int receptionID, int contactID, int eventID) {
    Uri url = Resource.Contact.calendarEvent(this._host, contactID, receptionID, eventID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        new Model.CalendarEvent.fromMap (JSON.decode(response), receptionID));
  }

  Future<Model.CalendarEvent> calendarEventCreate (Model.CalendarEvent event) {
    Uri url = Resource.Contact.calendar (this._host, event.contactID, event.receptionID);
        url = appendToken(url, this._token);

    String data = JSON.encode(event);
    return this._backend.post(url, data).then((String response) =>
        new Model.CalendarEvent.fromMap (JSON.decode(response), event.receptionID, contactID : event.contactID));
  }

  Future<Model.CalendarEvent> calendarEventUpdate (Model.CalendarEvent event) {
    Uri url = Resource.Contact.calendarEvent (this._host, event.contactID, event.receptionID, event.ID);
        url = appendToken(url, this._token);

    String data = JSON.encode(event);
    return this._backend.put(url, data).then((String response) =>
        new Model.CalendarEvent.fromMap (JSON.decode(response), event.receptionID, contactID : event.contactID));
  }

  Future calendarEventRemove (Model.CalendarEvent event) {
    Uri url = Resource.Contact.calendarEvent(this._host, event.contactID, event.receptionID, event.ID);
        url = appendToken(url, this._token);

    return this._backend.delete(url);
  }

}