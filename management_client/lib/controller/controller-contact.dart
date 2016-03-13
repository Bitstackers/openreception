part of management_tool.controller;

class Contact {
  final service.RESTContactStore _service;
  final model.User _appUser;

  Contact(this._service, this._appUser);

  Future<Iterable<model.ContactReference>> receptionContacts(int rid) =>
      _service.receptionContacts(rid);

  Future<Iterable<model.ReceptionReference>> receptions(int rid) =>
      _service.receptions(rid);

  Future<Iterable<model.OrganizationReference>> contactOrganizations(int cid) =>
      _service.organizations(cid);

  Future<model.ReceptionAttributes> getByReception(int cid, int rid) =>
      _service.data(cid, rid);

  Future<Iterable<model.ContactReference>> list() => _service.list();

  Future<model.BaseContact> get(int cid) => _service.get(cid);

  Future<model.ContactReference> update(model.BaseContact contact) =>
      _service.update(contact, _appUser);

  Future<model.ContactReference> create(model.BaseContact contact) =>
      _service.create(contact, _appUser);

  Future remove(int cid) => _service.remove(cid, _appUser);

  Future<model.ReceptionContactReference> addToReception(
          model.ReceptionAttributes attr) =>
      _service.addData(attr, _appUser);

  Future removeFromReception(int cid, int rid) =>
      _service.removeData(cid, rid, _appUser);

  Future<model.ReceptionContactReference> updateInReception(
          model.ReceptionAttributes attr) =>
      _service.updateData(attr, _appUser);

  Future<Iterable<model.ContactReference>> colleagues(int cid) {
    List<model.ContactReference> foundColleagues = [];

    return _service
        .receptions(cid)
        .then((Iterable<model.ReceptionReference> rRefs) => Future.forEach(
            rRefs,
            (rRef) => _service
                .receptionContacts(rRef.id)
                .then(foundColleagues.addAll)))
        .then((_) => foundColleagues);
  }
}
