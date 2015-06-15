part of openreception.managementclient.controller;

class Organization {
  final ORService.RESTOrganizationStore _service;

  Organization(this._service);

  Future<ORModel.Organization> get(int organizationID) => _service.get(organizationID);

  Future<Iterable<ORModel.Organization>> list() => _service.list();

  Future<Iterable<ORModel.BaseContact>> contacts(int organizationID) => _service.contacts(organizationID);

  Future<Iterable<int>> receptions(int organizationID) => _service.receptions(organizationID);

  Future remove (int organizationID) => _service.remove(organizationID);

  Future<ORModel.Organization> create(ORModel.Organization org) => _service.create(org);

  Future<ORModel.Organization> update(ORModel.Organization org) => _service.update(org);
}
