part of openreception_tests.support;

class ServiceAgent {
  final Directory runpath;
  final TestEnvironment env;
  final model.User user;
  String authToken = '';

  /**
   *
   */
  filestore.User _userStore;
  filestore.User get userStore {
    if (_userStore == null) {
      _userStore = env.userStore;
    }

    return _userStore;
  }

  /**
   *
   */
  filestore.Ivr _ivrStore;
  filestore.Ivr get ivrStore {
    if (_ivrStore == null) {
      _ivrStore = env.ivrStore;
    }

    return _ivrStore;
  }

  /**
   *
   */
  filestore.ReceptionDialplan _dialplanStore;
  filestore.ReceptionDialplan get dialplanStore {
    if (_dialplanStore == null) {
      _dialplanStore = env.dialplanStore;
    }

    return _dialplanStore;
  }

  /**
   *
   */
  filestore.Calendar _calendarStore;
  filestore.Calendar get calendarStore {
    if (_calendarStore == null) {
      _calendarStore = env.calendarStore;
    }

    return _calendarStore;
  }

  /**
   *
   */
  filestore.Contact _contactStore;
  filestore.Contact get contactStore {
    if (_contactStore == null) {
      _contactStore = env.contactStore;
    }

    return _contactStore;
  }

  /**
   *
   */
  storage.Reception _receptionStore;

  void set receptionStore(storage.Reception rStore) {
    _receptionStore = rStore;
  }

  storage.Reception get receptionStore {
    if (_receptionStore == null) {
      _receptionStore = env.receptionStore;
    }

    return _receptionStore;
  }

  /**
   *
   */
  storage.Organization _organizationStore;

  void set organizationStore(storage.Organization oStore) {
    _organizationStore = oStore;
  }

  storage.Organization get organizationStore {
    if (_organizationStore == null) {
      _organizationStore = env.organizationStore;
    }

    return _organizationStore;
  }

  /**
   *
   */
  ServiceAgent(this.runpath, this.user, this.env) {}

  /**
   *
   */
  Future removesUser(model.User target) async {
    await userStore.ready;
    await userStore.remove(target.id, user);
  }

  /**
   *
   */
  Future<model.BaseContact> createsContact({model.BaseContact contact}) async {
    final newContact =
        contact != null ? contact : Randomizer.randomBaseContact();

    await contactStore.ready;
    final bc = await contactStore.create(newContact, user);

    return contactStore.get(bc.id);
  }

  /**
   *
   */
  Future<model.ReceptionAttributes> addsContactToReception(
      model.BaseContact contact, model.Reception rec) async {
    final attributes = Randomizer.randomAttributes();
    attributes
      ..contactId = contact.id
      ..receptionId = rec.id;

    final rRef = await contactStore.addToReception(attributes, user);
    return contactStore.getByReception(rRef.contact.id, rRef.reception.id);
  }

  /**
   *
   */
  Future<model.ReceptionContactReference> updatesReceptionAttributes(
      model.ReceptionAttributes attr) async {
    final attributes = Randomizer.randomAttributes()
      ..contactId = attr.contactId
      ..receptionId = attr.receptionId;

    return await contactStore.updateInReception(attributes, user);
  }

  /**
   *
   */
  Future removesContactFromReception(
      model.BaseContact contact, model.Reception reception) async {
    await contactStore.removeFromReception(contact.id, reception.id, user);
  }

  /**
   *
   */
  Future<model.Reception> createsReception(model.Organization org,
      [model.Reception rec]) async {
    final randRec = (rec != null ? rec : Randomizer.randomReception())
      ..organizationId = org.id;
    final bc = await receptionStore.create(randRec, user);

    return receptionStore.get(bc.id);
  }

  /**
   *
   */
  Future removesReception(model.Reception rec) async {
    await receptionStore.remove(rec.id, user);
  }

  /**
   *
   */
  Future<model.Reception> updateReception(model.Reception rec) async {
    final ref = await receptionStore.update(rec, user);

    return receptionStore.get(ref.id);
  }

  /**
   *
   */
  Future<model.Organization> createsOrganization() async {
    final randOrg = Randomizer.randomOrganization();
    final ref = await organizationStore.create(randOrg, user);

    return organizationStore.get(ref.id);
  }

  /**
   *
   */
  Future deletesOrganization(model.Organization org) async {
    await organizationStore.remove(org.id, user);
  }

  /**
   *
   */
  Future<model.Organization> updatesOrganization(model.Organization org) async {
    final randOrg = Randomizer.randomOrganization()..id = org.id;
    final ref = await organizationStore.update(randOrg, user);

    return organizationStore.get(ref.id);
  }

  /**
   *
   */
  Future<model.User> createsUser() async {
    await userStore.ready;
    final model.User newUser = Randomizer.randomUser();

    newUser.id = (await userStore.create(newUser, user)).id;

    return newUser;
  }
}
