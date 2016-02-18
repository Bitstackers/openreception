part of management_tool.controller;

class Contact {
  final service.RESTContactStore _service;

  Contact(this._service);

  Future<Iterable<model.Contact>> list(int receptionID) =>
      _service.listByReception(receptionID);

  Future<Iterable<int>> contactOrganizations(int contactID) =>
      _service.organizations(contactID);

  Future<model.Contact> getByReception(int contactID, int receptionID) =>
      _service.getByReception(contactID, receptionID);

  Future<Iterable<model.BaseContact>> listAll() => _service.list();

  Future<model.BaseContact> get(int contactID) => _service.get(contactID);

  Future<model.BaseContact> update(model.BaseContact contact) =>
      _service.update(contact);

  Future<model.BaseContact> create(model.BaseContact contact) =>
      _service.create(contact);

  Future remove(int contactId) => _service.remove(contactId);

  Future<Iterable<int>> receptions(int contactID) =>
      _service.receptions(contactID);

  Future<model.Contact> addToReception(
          model.Contact contact, int receptionId) =>
      _service.addToReception(contact, receptionId);

  Future removeFromReception(int contactId, int receptionId) =>
      _service.removeFromReception(contactId, receptionId);

  Future<model.Contact> updateInReception(model.Contact contact) =>
      _service.updateInReception(contact);

  Future<Iterable<model.Contact>> colleagues(int contactId) {
    List<model.Contact> foundColleagues = [];

    return _service
        .receptions(contactId)
        .then((Iterable<int> receptionIds) => Future.forEach(
            receptionIds,
            (int receptionId) => _service
                .listByReception(receptionId)
                .then(foundColleagues.addAll)))
        .then((_) => foundColleagues);
  }
}
