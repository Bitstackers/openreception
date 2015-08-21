part of openreception.storage;

abstract class Contact {

  Future<Model.Contact> addToReception(Model.Contact contact, int receptionID);

  Future<Model.BaseContact> create(Model.BaseContact contact);

  Future<Model.BaseContact> get(int contactID);

  Future<Model.Contact> getByReception(int contactID, int receptionID);

  Future<Iterable<Model.BaseContact>> list();

  Future<Iterable<Model.Contact>> listByReception(int receptionID);

  Future<Iterable<Model.BaseContact>> organizationContacts(int organizationId);

  Future<Iterable<int>> organizations (int contactID);

  @deprecated
  Future<Iterable<Model.PhoneNumber>> phones(int contactID, int receptionID);

  Future<Iterable<int>> receptions (int contactID);

  Future remove(int contactId);

  Future<Model.Contact> removeFromReception(int contactId, int receptionID);

  Future<Model.BaseContact> update(Model.BaseContact contact);

  Future<Model.Contact> updateInReception(Model.Contact contact);
}
