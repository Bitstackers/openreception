part of openreception.storage;

abstract class Organization {

  Future<Model.Organization> get(int organizationID);

  Future<List<Model.Organization>> list();

  Future<Model.Organization> remove(Model.Organization organization);

  Future<Model.Organization> save(Model.Organization organization);
}
