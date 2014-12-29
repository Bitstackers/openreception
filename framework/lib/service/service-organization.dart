part of openreception.service;

class RESTOrganizationStore implements Storage.Organization {

  static final String className = '${libraryName}.RESTOrganizationStore';

  WebService _backed = null;
  Uri        _host;
  String     _token = '';

  RESTOrganizationStore (Uri this._host, String this._token, this._backed);

  Future<Model.Organization> get(int organizationID) =>
      this._backed.get
        (appendToken(OrganizationResource.single
           (this._host, organizationID), this._token))
      .then((String response)
        => new Model.Organization.fromMap (JSON.decode(response)));

  Future<Model.Organization> create(Model.Organization organization) =>
      this._backed.post
        (appendToken
           (OrganizationResource.root(this._host), this._token), JSON.encode(organization.asMap))
      .then((String response)
        => new Model.Organization.fromMap (JSON.decode(response)));

  Future<Model.Organization> update(Model.Organization organization) =>
      this._backed.put
        (appendToken
          (OrganizationResource.single(this._host, organization.id), this._token), JSON.encode (organization.asMap))
      .then((String response)
        => new Model.Organization.fromMap (JSON.decode(response)));

  Future<Model.Organization> save(Model.Organization organization) {
    if (organization.id != null && organization.id != Model.Organization.noID) {
      return this.update(organization);
    } else {
      return this.create(organization);
    }
  }

  Future<List<Model.Organization>> list() =>
      this._backed.get(appendToken(OrganizationResource.list(this._host),this._token))
      .then((String response)
        => (JSON.decode(response) as List).map((Map map) => new Model.Organization.fromMap(map)));
}
