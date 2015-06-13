part of openreception.service;

class RESTOrganizationStore implements Storage.Organization {

  static final String className = '${libraryName}.RESTOrganizationStore';

  WebService _backend = null;
  Uri        _host;
  String     _token = '';

  RESTOrganizationStore (Uri this._host, String this._token, this._backend);

  Future<Iterable<Model.BaseContact>> contacts(int organizationID) {
    Uri url = Resource.Organization.contacts(this._host, organizationID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
      (JSON.decode(response) as Iterable).map((Map map) =>
        new Model.BaseContact.fromMap (map)));
  }

  Future<Iterable<int>> receptions(int organizationID) {
    Uri url = Resource.Organization.receptions(_host, organizationID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
      (JSON.decode(response)));
  }

  Future<Model.Organization> get(int organizationID) {
    Uri url = Resource.Organization.single(this._host, organizationID);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        new Model.Organization.fromMap (JSON.decode(response)));
  }

  Future<Model.Organization> create(Model.Organization organization) {
    Uri url = Resource.Organization.root(this._host);
        url = appendToken(url, this._token);

    String data = JSON.encode(organization.asMap);
    return this._backend.post(url, data).then((String response) =>
        new Model.Organization.fromMap (JSON.decode(response)));
  }

  Future<Model.Organization> update(Model.Organization organization) {
    Uri url = Resource.Organization.single(this._host, organization.id);
        url = appendToken(url, this._token);

    String data = JSON.encode(organization.asMap);
    return this._backend.put(url, data).then((String response) =>
        new Model.Organization.fromMap (JSON.decode(response)));
  }

  Future remove(int organizationID) {
    Uri url = Resource.Organization.single(this._host, organizationID);
        url = appendToken(url, this._token);

    return this._backend.delete(url).then((String response) =>
        new Model.Organization.fromMap (JSON.decode(response)));
  }

  Future<Iterable<Model.Organization>> list() {
    Uri url = Resource.Organization.list(this._host, token: this._token);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable)
          .map((Map map) => new Model.Organization.fromMap(map)));
  }
}
