part of openreception.managementclient.controller;

class Organization {
  final ORService.RESTOrganizationStore _service;

  Organization(this._service);

  Future<ORModel.Organization> get(int organizationID) => _service.get(organizationID);

  Future<Iterable<ORModel.Organization>> list() => _service.list();

  Future<Iterable<ORModel.BaseContact>> contacts(int organizationID) => _service.contacts(organizationID);

  Future<Iterable<ORModel.Reception>> receptions(int organizationID) => _service.receptions(organizationID);

}
