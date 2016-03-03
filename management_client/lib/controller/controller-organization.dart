part of management_tool.controller;

class Organization {
  final service.RESTOrganizationStore _service;
  final model.User _appUser;

  Organization(this._service, this._appUser);

  Future<model.Organization> get(int oid) => _service.get(oid);

  Future<Iterable<model.OrganizationReference>> list() => _service.list();

  Future<Iterable<model.ContactReference>> contacts(int oid) =>
      _service.contacts(oid);

  Future<Iterable<model.ReceptionReference>> receptions(int oid) =>
      _service.receptions(oid);

  Future remove(int oid) => _service.remove(oid, _appUser);

  Future<model.OrganizationReference> create(model.Organization org) =>
      _service.create(org, _appUser);

  Future<model.OrganizationReference> update(model.Organization org) =>
      _service.update(org, _appUser);
}
