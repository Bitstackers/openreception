part of openreception.storage;

abstract class Contact {

  Future<Model.Contact> get(int organizationID);

  Future<List<Model.Contact>> list();

  Future<Model.Contact> remove(Model.Contact Contact);

  Future<Model.Contact> create(Model.Contact Contact);

  Future<Model.Contact> update(Model.Contact Contact);
}
