part of openreception.service;

class RESTContactStore implements Storage.Contact {

  static final String className = '${libraryName}.RESTContactStore';
  static final Logger log = new Logger(className);

  WebService _backend = null;
  Uri        _host;
  String     _token = '';

  RESTContactStore (Uri this._host, String this._token, this._backend);

  Future<Iterable<Map>> calendarMap (int contactID, int receptionID) {
    Uri url = Resource.Contact.calendar(this._host, contactID, receptionID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) {
      var decodedData = JSON.decode(response);

      if (decodedData is Map) {
        return  (JSON.decode(response)
            ['CalendarEvents'] as Iterable);

      } else {
        return (JSON.decode(response) as Iterable);
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

  Future<Iterable<Model.Contact>> list() {
    Uri url = Resource.Contact.list(this._host);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as Map)
          [Model.ContactJSONKey.Contact_LIST]
          .map((Map map) => new Model.Contact.fromMap(map)));
  }

  Future<Model.Contact> getByReception(int contactID, int receptionID) {
    Uri url = Resource.Contact.singleByReception(this._host, contactID, receptionID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        new Model.Contact.fromMap (JSON.decode(response)));
  }

  Future<Iterable<Model.Contact>> listByReception(int receptionID, {Model.ContactFilter filter}) {
    Uri url = Resource.Contact.listByReception(this._host, receptionID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
       (JSON.decode(response) as Iterable)
            .map((Map map) => new Model.Contact.fromMap(map)));
  }

  Future<Iterable<Model.CalendarEntry>> calendar (int contactID, int receptionID) =>
      calendarMap (contactID, receptionID).then((Iterable<Map> maps) =>
          maps.map((Map map) =>
              new Model.CalendarEntry.fromMap (map)));

  Future<Model.CalendarEntry> calendarEvent (int receptionID, int contactID, int eventID) {
    Uri url = Resource.Contact.calendarEvent(this._host, contactID, receptionID, eventID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) {
      Map responseMap = null;
      try {
        responseMap = JSON.decode(response);
      } catch (error) {
        return new Future.error
          (new ArgumentError
            ('Failed to response parse as JSON string : `$response`'));
      }

      return new Model.CalendarEntry.fromMap (responseMap);
    });
  }

  Future<Model.CalendarEntry> calendarEventCreate (Model.CalendarEntry event) {
    Uri url = Resource.Contact.calendar (this._host, event.contactID, event.receptionID);
        url = appendToken(url, this._token);

    String data = JSON.encode(event);
    return this._backend.post(url, data).then((String response) =>
        new Model.CalendarEntry.fromMap (JSON.decode(response)));
  }

  Future<Model.CalendarEntry> calendarEventUpdate (Model.CalendarEntry event) {
    Uri url = Resource.Contact.calendarEvent (this._host, event.contactID, event.receptionID, event.ID);
        url = appendToken(url, this._token);

    String data = JSON.encode(event);
    return this._backend.put(url, data).then((String response) =>
        new Model.CalendarEntry.fromMap (JSON.decode(response)));
  }

  Future calendarEventRemove (Model.CalendarEntry event) {
    Uri url = Resource.Contact.calendarEvent(this._host, event.contactID, event.receptionID, event.ID);
        url = appendToken(url, this._token);

    return this._backend.delete(url);
  }

  Future<Iterable<Map>> endpointsMap (int contactID, int receptionID) {
    Uri url = Resource.Contact.endpoints(this._host, contactID, receptionID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then(JSON.decode);
  }

  Future<Iterable<Model.MessageEndpoint>> endpoints (int contactID, int receptionID) =>
    this.endpointsMap(contactID, receptionID).then((Iterable<Map> maps) =>
        maps.map((Map map) => new Model.MessageEndpoint.fromMap(map)));

  Future<Iterable<Map>> phonesMap (int contactID, int receptionID) {
    Uri url = Resource.Contact.phones(this._host, contactID, receptionID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then(JSON.decode);
  }

  Future<Iterable<Model.PhoneNumber>> phones (int contactID, int receptionID) =>
    this.endpointsMap(contactID, receptionID).then((Iterable<Map> maps) =>
        maps.map((Map map) => new Model.PhoneNumber.fromMap(map)));

  Future<Iterable<Model.CalendarEntryChange>> calendarEntryChanges(entryID) {
    Uri url = Resource.Contact.calendarEventChanges(this._host, entryID);
        url = appendToken(url, this._token);

    return this._backend.get(url)
      .then(JSON.decode)
      .then((Iterable<Map> maps) =>
        maps.map((Map map) =>
          new Model.CalendarEntryChange.fromMap(map)));

  }

  Future<Model.CalendarEntryChange> calendarEntryLatestChange(entryID) {
    Uri url = Resource.Contact.calendarEventLatestChange(this._host, entryID);
        url = appendToken(url, this._token);

    return this._backend.get(url)
      .then(JSON.decode)
      .then((Map map) =>
        new Model.CalendarEntryChange.fromMap(map));
  }

}