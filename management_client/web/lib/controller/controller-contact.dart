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

  Future<ORModel.BaseContact> update(ORModel.BaseContact contact) =>
      _service.update(contact);

  Future<ORModel.BaseContact> create(ORModel.BaseContact contact) =>
      _service.create(contact);

  Future remove(int contactId) => _service.remove(contactId);

  Future<Iterable<ORModel.MessageEndpoint>> endpoints(
          int contactID, int receptionID) =>
      _service.endpoints(contactID, receptionID);

  Future<Iterable<int>> receptions(int contactID) =>
      _service.receptions(contactID);

  Future<ORModel.Contact> addToReception(
          ORModel.Contact contact, int receptionId) =>
      _service.addToReception(contact, receptionId);

  Future removeFromReception(int contactId, int receptionId) =>
      _service.removeFromReception(contactId, receptionId);

  Future<ORModel.Contact> updateInReception(ORModel.Contact contact) =>
      _service.updateInReception(contact);

  Future<ORModel.Contact> moveReception(
          int receptionId, int oldContactId, int newContactId) =>
      throw new UnimplementedError();

  Future<Iterable<ORModel.Contact>> colleagues(int contactId) {
    List<ORModel.Contact> foundColleagues = [];

    return _service
        .receptions(contactId)
        .then((Iterable<int> receptionIds) => Future.forEach(receptionIds,
            (int receptionId) => _service
                .listByReception(receptionId)
                .then(foundColleagues.addAll)))
        .then((_) => foundColleagues);
  }
}
