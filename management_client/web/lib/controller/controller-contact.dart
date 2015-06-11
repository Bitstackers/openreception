part of openreception.managementclient.controller;

class Contact {
  final ORService.RESTContactStore _service;
  final ORService.RESTManagementStore _management;

  Contact(this._service, this._management);

  Future<Iterable<ORModel.Contact>> list(int receptionID) => _service.listByReception(receptionID);

  Future<ORModel.Contact> getByReception(int contactID, int receptionID) => _service.getByReception(contactID, receptionID);

  Future<Iterable<ORModel.BaseContact>> listAll() => _service.list();

  Future<ORModel.BaseContact> get(int contactID) => _service.get(contactID);

  Future<Iterable<ORModel.MessageEndpoint>> endpoints(int contactID, int receptionID) => _service.endpoints(contactID, receptionID);


  Future<Iterable<int>> receptions(int contactID) => _service.receptions(contactID);
}
