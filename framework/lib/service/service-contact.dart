part of openreception.service;

class RESTContactStore implements Storage.Contact {

  static final String className = '${libraryName}.RESTContactStore';

  WebService _backend = null;
  Uri        _host;
  String     _token = '';

  RESTContactStore (Uri this._host, String this._token, this._backend);

  Future<Model.Contact> get(int contactID) {
    Uri url = ContactResource.single(this._host, contactID, token: this._token);
    return this._backend.get(url).then((String response) =>
        new Model.Contact.fromMap (JSON.decode(response)));
  }

  Future<Model.Contact> create(Model.Contact contact) {
    Uri url = ContactResource.root(this._host, token: this._token);
    String data = JSON.encode(contact.asMap);
    return this._backend.put(url, data).then((String response) =>
        new Model.Contact.fromMap (JSON.decode(response)));
  }

  Future<Model.Contact> update(Model.Contact contact) {
    Uri url = ContactResource.single(this._host, contact.ID, token: this._token);
    String data = JSON.encode(contact.asMap);
    return this._backend.post(url, data).then((String response) =>
        new Model.Contact.fromMap (JSON.decode(response)));
  }

  Future<Model.Contact> remove(Model.Contact contact) {
    Uri url = ContactResource.single(this._host, contact.ID, token: this._token);
    return this._backend.delete(url).then((String response) =>
        new Model.Contact.fromMap (JSON.decode(response)));
  }

  Future<Model.Contact> save(Model.Contact contact) {
    if (contact.ID != null && contact.ID != Model.Contact.noID) {
      return this.update(contact);
    } else {
      return this.create(contact);
    }
  }

  Future<List<Model.Contact>> list() {
    Uri url = ContactResource.list(this._host, token: this._token);
    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as Map)
          [Model.ContactJSONKey.Contact_LIST]
          .map((Map map) => new Model.Contact.fromMap(map))
          .toList() );
  }
}
