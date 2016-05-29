part of management_tool.controller;

class Organization {
  final service.RESTOrganizationStore _service;
  final model.User _appUser;

  Organization(this._service, this._appUser);

  Future<model.Organization> get(int oid) =>
      _service.get(oid).catchError(_handleError);

  Future<Iterable<model.OrganizationReference>> list() =>
      _service.list().catchError(_handleError);

  Future<Iterable<model.BaseContact>> contacts(int oid) =>
      _service.contacts(oid).catchError(_handleError);

  Future<Iterable<model.ReceptionReference>> receptions(int oid) =>
      _service.receptions(oid).catchError(_handleError);

  Future<Map<String, Map<String, String>>> receptionMap() =>
      _service.receptionMap().catchError(_handleError);

  Future remove(int oid) =>
      _service.remove(oid, _appUser).catchError(_handleError);

  Future<model.OrganizationReference> create(model.Organization org) =>
      _service.create(org, _appUser).catchError(_handleError);

  Future<model.OrganizationReference> update(model.Organization org) =>
      _service.update(org, _appUser).catchError(_handleError);

  Future<Iterable<model.Commit>> changes([int oid]) =>
      _service.changes(oid).catchError(_handleError);
}
