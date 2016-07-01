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

  Future remove(int oid) =>
      _service.remove(oid, _appUser).catchError(_handleError);

  Future<model.OrganizationReference> create(model.Organization org) =>
      _service.create(org, _appUser).catchError(_handleError);

  Future<model.OrganizationReference> update(model.Organization org) =>
      _service.update(org, _appUser).catchError(_handleError);

  Future<Iterable<model.Commit>> changes([int oid]) =>
      _service.changes(oid).catchError(_handleError);

  Future<String> changelog(int oid) =>
      _service.changelog(oid).catchError(_handleError);

  /**
   * Returns a map with int rid keys and organization / reception names in a
   * map as value.
   * Example:
   *  {"42": {'organization': "orgName", "reception": "recName"}}
   */
  Future<Map<int, RecOrgAggr>> receptionMap() async {
    final Map<int, RecOrgAggr> aggrMap = {};
    Iterable orgRefs = await _service.list();

    await orgRefs.forEach((model.OrganizationReference oRef) async {
      final Iterable<model.ReceptionReference> rRfefs =
          await receptions(oRef.id);

      rRfefs.forEach((model.ReceptionReference rRef) {
        aggrMap[rRef.id] = new RecOrgAggr(oRef, rRef);
      });
    });

    return aggrMap;
  }
}

/**
 * Reception/organization aggregation holder class.
 */
class RecOrgAggr {
  final model.OrganizationReference organization;
  final model.ReceptionReference reception;

  const RecOrgAggr(this.organization, this.reception);
}
