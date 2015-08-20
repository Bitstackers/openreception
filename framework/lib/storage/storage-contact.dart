part of openreception.storage;

abstract class Contact {

  Future<Model.BaseContact> get(int contactID);

  Future<Iterable<Model.BaseContact>> list();

  Future<Iterable<Model.Contact>> listByReception(int receptionID);

  Future<Model.Contact> getByReception(int contactID, int receptionID);

  Future remove(Model.BaseContact contact);

  Future<Model.BaseContact> create(Model.BaseContact contact);

  Future<Model.BaseContact> update(Model.BaseContact contact);

}
