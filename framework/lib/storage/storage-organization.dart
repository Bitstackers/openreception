part of openreception.storage;

abstract class Organization {

  Future<Iterable<Model.BaseContact>> contacts(int organizationID);

  Future<Model.Organization> create(Model.Organization organization);

  Future<Model.Organization> get(int organizationID);

  Future<Iterable<Model.Organization>> list();

  Future<Model.Organization> remove(int organizationID);

  Future<Model.Organization> update(Model.Organization organization);

  Future<Iterable<Model.Reception>> receptions(int organizationID);
}
