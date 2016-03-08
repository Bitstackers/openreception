part of openreception_tests.support;

class ServiceAgent {
  final Directory runpath;
  final TestEnvironment env;
  final model.User user;
  String authToken = '';
  Transport.WebSocketClient _ws;

  Stream<Event.Event> get notifications => notificationSocket.eventStream;

  void cleanup() {
    if (_ws != null) {
      _ws.close();
    }
  }

  void set notificationSocket(Service.NotificationSocket ns) {
    _notificationSocket = ns;
  }

  Service.NotificationSocket get notificationSocket {
    if (_notificationSocket == null) {
      _ws = new Transport.WebSocketClient();
      _ws.connect(
          Uri.parse('${Config.NotificationSocketUri}/?token=${authToken}'));
      _notificationSocket = new Service.NotificationSocket(_ws);
    }

    return _notificationSocket;
  }

  Service.NotificationSocket _notificationSocket;

  /**
   *
   */
  storage.User _userStore;

  void set userStore(storage.User uStore) {
    _userStore = uStore;
  }

  storage.User get userStore {
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
  storage.Calendar _calendarStore;
  void set calendarStore(storage.Calendar cs) {
    _calendarStore = cs;
  }

  storage.Calendar get calendarStore {
    if (_calendarStore == null) {
      _calendarStore = env.calendarStore;
    }

    return _calendarStore;
  }

  /**
   *
   */
  storage.Contact _contactStore;

  void set contactStore(storage.Contact cStore) {
    _contactStore = cStore;
  }

  storage.Contact get contactStore {
    if (_contactStore == null) {
      _contactStore = env.contactStore;
    }

    return _contactStore;
  }

  /**
   *
   */
  storage.Message _messageStore;

  void set messageStore(storage.Message mStore) {
    _messageStore = mStore;
  }

  storage.Message get messageStore {
    if (_messageStore == null) {
      _messageStore = env.messageStore;
    }

    return _messageStore;
  }

  /**
   *
   */
  storage.MessageQueue _messageQueue;
  void set messageQueue(storage.MessageQueue mq) {
    _messageQueue = mq;
  }

  storage.MessageQueue get messageQueue {
    if (_messageQueue == null) {
      _messageQueue = env.messageQueue;
    }

    return _messageQueue;
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
    await userStore.remove(target.id, user);
  }

  /**
   *
   */
  Future<model.BaseContact> createsContact({model.BaseContact contact}) async {
    final newContact =
        contact != null ? contact : Randomizer.randomBaseContact();

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

    final rRef = await contactStore.addData(attributes, user);
    return contactStore.data(rRef.contact.id, rRef.reception.id);
  }

  /**
   *
   */
  Future<model.ReceptionContactReference> updatesReceptionAttributes(
      model.ReceptionAttributes attr) async {
    final attributes = Randomizer.randomAttributes()
      ..contactId = attr.contactId
      ..receptionId = attr.receptionId;

    return await contactStore.updateData(attributes, user);
  }

  /**
   *
   */
  Future removesContactFromReception(
      model.BaseContact contact, model.Reception reception) async {
    await contactStore.removeData(contact.id, reception.id, user);
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
  Future<model.Reception> updatesReception(model.Reception rec) async {
    final randRec = Randomizer.randomReception()
      ..organizationId = rec.organizationId
      ..id = rec.id;

    final bc = await receptionStore.update(randRec, user);

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
    final model.User newUser = Randomizer.randomUser();

    newUser.id = (await userStore.create(newUser, user)).id;

    return newUser;
  }

  /**
   *
   */
  Future<model.User> updatesUser(model.User u) async {
    final model.User updated = Randomizer.randomUser()..id = u.id;
    final uRef = await userStore.update(updated, user);

    return userStore.get(uRef.id);
  }

  /**
   *
   */
  Future<model.Message> createsMessage(model.MessageContext context,
      {model.Message msg}) async {
    msg = msg == null ? Randomizer.randomMessage() : msg;

    model.ReceptionAttributes contact =
        await contactStore.data(context.cid, context.rid);

    msg
      ..context = context
      ..recipients = contact.endpoints.toSet()
      ..sender = user;

    return messageStore.create(msg, user);
  }

  /**
   *
   */
  Future<model.Message> updatesMessage(model.Message msg) async {
    msg = Randomizer.randomMessage()
      ..id = msg.id
      ..context = msg.context
      ..recipients = msg.recipients
      ..sender = msg.sender;

    return messageStore.create(msg, user);
  }

  /**
   *
   */
  Future<model.Message> removesMessage(model.Message msg) async {
    return messageStore.remove(msg.id, user);
  }
}
