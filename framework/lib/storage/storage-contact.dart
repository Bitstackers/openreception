part of openreception.storage;

abstract class Contact {
  Future<model.ReceptionContactReference> addToReception(
      model.ReceptionAttributes attr, model.User modifier);

  Future<model.ContactReference> create(
      model.BaseContact contact, model.User modifier);

  Future<model.BaseContact> get(int id);

  Future<model.ReceptionAttributes> getByReception(int id, int receptionId);

  Future<Iterable<model.ContactReference>> list();

  Future<Iterable<model.ReceptionAttributes>> listByReception(int receptionId);

  Future<Iterable<model.ContactReference>> organizationContacts(
      int organizationId);

  Future<Iterable<model.OrganizationReference>> organizations(int id);

  Future<Iterable<model.ReceptionReference>> receptions(int id);

  Future remove(int id, model.User modifier);

  Future removeFromReception(int id, int receptionId, model.User modifier);

  Future<model.ContactReference> update(
      model.BaseContact contact, model.User modifier);

  Future<model.ReceptionContactReference> updateInReception(
      model.ReceptionAttributes contact, model.User modifier);
}
