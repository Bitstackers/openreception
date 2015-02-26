part of openreception.service;

class RESTOrganizationStore implements Storage.Organization {

  static final String className = '${libraryName}.RESTOrganizationStore';

  WebService _backend = null;
  Uri        _host;
  String     _token = '';

  RESTOrganizationStore (Uri this._host, String this._token, this._backend);

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
    return this._backend.put(url, data).then((String response) =>
        new Model.Organization.fromMap (JSON.decode(response)));
  }

  Future<Model.Organization> update(Model.Organization organization) {
    Uri url = Resource.Organization.single(this._host, organization.id);
        url = appendToken(url, this._token);

    String data = JSON.encode(organization.asMap);
    return this._backend.post(url, data).then((String response) =>
        new Model.Organization.fromMap (JSON.decode(response)));
  }

  Future<Model.Organization> remove(Model.Organization organization) {
    Uri url = Resource.Organization.single(this._host, organization.id);
        url = appendToken(url, this._token);

    return this._backend.delete(url).then((String response) =>
        new Model.Organization.fromMap (JSON.decode(response)));
  }

  Future<Model.Organization> save(Model.Organization organization) {
    if (organization.id != null && organization.id != Model.Organization.noID) {
      return this.update(organization);
    } else {
      return this.create(organization);
    }
  }

  Future<List<Model.Organization>> list() {
    Uri url = Resource.Organization.list(this._host, token: this._token);
        url = appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as Map)
          [Model.OrganizationJSONKey.ORGANIZATION_LIST]
          .map((Map map) => new Model.Organization.fromMap(map))
          .toList() );
  }
}
