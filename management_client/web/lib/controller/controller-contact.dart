part of openreception.managementclient.controller;

class Contact {
  final ORService.RESTContactStore _service;

  Contact(this._service);

  Future<Iterable<ORModel.Contact>> list(int receptionID) =>
      _service.listByReception(receptionID);

  Future<Iterable<int>> contactOrganizations(int contactID) =>
      _service.organizations(contactID);

  Future<ORModel.Contact> getByReception(int contactID, int receptionID) =>
      _service.getByReception(contactID, receptionID);

  Future<Iterable<ORModel.BaseContact>> listAll() => _service.list();

  Future<ORModel.BaseContact> get(int contactID) => _service.get(contactID);

  Future<Iterable<ORModel.MessageEndpoint>> endpoints(
          int contactID, int receptionID) =>
      _service.endpoints(contactID, receptionID);

  Future<Iterable<int>> receptions(int contactID) =>
      _service.receptions(contactID);

  Future<Iterable<ORModel.BaseContact>> colleagues(int contactId) =>
      _service.colleagues(contactId);
}
