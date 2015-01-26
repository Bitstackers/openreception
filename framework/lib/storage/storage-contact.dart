part of openreception.storage;

abstract class Contact {

  Future<Model.Contact> get(int organizationID);

  Future<List<Model.Contact>> list();

  Future<Model.Contact> remove(Model.Contact Contact);

  Future<Model.Contact> save(Model.Contact Contact);
}
