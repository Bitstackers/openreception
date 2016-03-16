part of management_tool.controller;

class Organization {
  final service.RESTOrganizationStore _service;

  Organization(this._service);

  Future<model.Organization> get(int organizationID) =>
      _service.get(organizationID);

  Future<Iterable<model.Organization>> list() => _service.list();

  Future<Iterable<model.BaseContact>> contacts(int organizationID) =>
      _service.contacts(organizationID);

  Future<Map<String, Map<String, String>>> receptionMap() =>
      _service.receptionMap();

  Future<Iterable<int>> receptions(int organizationID) =>
      _service.receptions(organizationID);

  Future remove(int organizationID) => _service.remove(organizationID);

  Future<model.Organization> create(model.Organization org) =>
      _service.create(org);

  Future<model.Organization> update(model.Organization org) =>
      _service.update(org);
}
