part of openreception.storage;

abstract class Contact {
  /**
   *
   */
  Future addData(model.ReceptionAttributes attr, model.User modifier);

  /**
   *
   */
  Future<model.ContactReference> create(
      model.BaseContact contact, model.User modifier);

  /**
   *
   */
  Future<model.BaseContact> get(int cid);

  /**
   *
   */
  Future<model.ReceptionAttributes> data(int cid, int rid);

  /**
   *
   */
  Future<Iterable<model.ContactReference>> list();

  /**
   *
   */
  Future<Iterable<model.ContactReference>> receptionContacts(int rid);

  /**
   *
   */
  Future<Iterable<model.ContactReference>> organizationContacts(int oid);

  /**
   *
   */
  Future<Iterable<model.OrganizationReference>> organizations(int cid);

  /**
   *
   */
  Future<Iterable<model.ReceptionReference>> receptions(int cid);

  /**
   *
   */
  Future remove(int cid, model.User modifier);

  /**
   *
   */
  Future removeData(int cid, int rid, model.User modifier);

  /**
   *
   */
  Future<model.ContactReference> update(
      model.BaseContact contact, model.User modifier);

  /**
   *
   */
  Future<model.ReceptionContactReference> updateData(
      model.ReceptionAttributes attr, model.User modifier);

  /**
   *
   */
  Future changes([int uid, int rid]);
}
