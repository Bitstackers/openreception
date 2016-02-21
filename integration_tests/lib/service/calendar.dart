part of or_test_fw;

void runCalendarTests() {
  group('Service.Calendar', () {
    Service.RESTCalendarStore calendarStore;
    Transport.Client transport;
    Service.RESTContactStore contactStore;
    Service.RESTReceptionStore receptionStore;
    Service.RESTUserStore userStore;
    Receptionist r;
    Model.BaseContact contact;
    Model.Reception reception;
    Model.Owner owner;
    Model.User creator;

    /**
     * Setup/teardown Basic CRUD tests for contact owner.
     */
    setUp(() async {
      transport = new Transport.Client();

      calendarStore = new Service.RESTCalendarStore(
          Config.calendarStoreUri, Config.serverToken, transport);

      contactStore = new Service.RESTContactStore(
          Config.contactStoreUri, Config.serverToken, transport);

      userStore = new Service.RESTUserStore(
          Config.userStoreUri, Config.serverToken, transport);

      contact = await contactStore.create(Randomizer.randomBaseContact());
      creator = await userStore.create(Randomizer.randomUser());

      owner = new Model.OwningContact(contact.id);
    });

    tearDown(() async {
      transport.client.close(force: true);
      await contactStore.remove(contact.id);
      await userStore.remove(creator.id);
    });

    test('get (non-existing)',
        () => StorageCalendar.getNonExistingEntry(calendarStore));

    /**
     * Basic CRUD tests for contact owner.
     */
    test('create (contact owner)',
        () => StorageCalendar.create(owner, calendarStore, creator));

    test('get (contact owner)',
        () => StorageCalendar.get(owner, calendarStore, creator));

    test('update (contact owner)',
        () => StorageCalendar.update(owner, calendarStore, creator));
    test('list (contact owner)',
        () => StorageCalendar.list(owner, calendarStore, creator));
    test('purge (contact owner)',
        () => StorageCalendar.purge(owner, calendarStore, creator));

    test('remove (contact owner)',
        () => StorageCalendar.remove(owner, calendarStore, creator));

    /**
     * Setup/teardown Basic CRUD tests for reception owner.
     */
    setUp(() async {
      transport = new Transport.Client();

      calendarStore = new Service.RESTCalendarStore(
          Config.calendarStoreUri, Config.serverToken, transport);

      userStore = new Service.RESTUserStore(
          Config.userStoreUri, Config.serverToken, transport);

      receptionStore = new Service.RESTReceptionStore(
          Config.receptionStoreUri, Config.serverToken, transport);

      reception = await receptionStore.create(Randomizer.randomReception());
      creator = await userStore.create(Randomizer.randomUser());

      owner = new Model.OwningReception(reception.ID);
    });

    tearDown(() async {
      transport.client.close(force: true);
      await receptionStore.remove(reception.ID);
      await userStore.remove(creator.id);
    });

    /**
     * Basic CRUD tests for reception owner.
     */
    test('get (reception owner)',
        () => StorageCalendar.get(owner, calendarStore, creator));

    test('create (reception owner)',
        () => StorageCalendar.create(owner, calendarStore, creator));

    test('list (reception owner)',
        () => StorageCalendar.list(owner, calendarStore, creator));

    test('remove (reception owner)',
        () => StorageCalendar.remove(owner, calendarStore, creator));

    test('update (reception owner)',
        () => StorageCalendar.update(owner, calendarStore, creator));

    test('purge (reception owner)',
        () => StorageCalendar.purge(owner, calendarStore, creator));

    /**
     * Tests for event presence upon creating calendar entries for contacts.
     */
    setUp(() async {
      transport = new Transport.Client();
      r = ReceptionistPool.instance.aquire();
      contactStore = new Service.RESTContactStore(
          Config.contactStoreUri, r.authToken, transport);
      calendarStore = new Service.RESTCalendarStore(
          Config.calendarStoreUri, r.authToken, transport);

      contact = await contactStore.create(Randomizer.randomBaseContact());

      owner = new Model.OwningContact(contact.id);

      return r.initialize();
    });

    tearDown(() async {
      await contactStore.remove(contact.id);

      transport.client.close(force: true);
      ReceptionistPool.instance.release(r);
      await r.teardown();
    });

    test(
        'create (contact owner - event presence)',
        () => RESTCalendarStore.calendarEntryCreateEvent(
            owner, calendarStore, r));

    test(
        'update (contact owner - event presence)',
        () => RESTCalendarStore.calendarEntryUpdateEvent(
            owner, calendarStore, r));

    test(
        'delete (contact owner - event presence)',
        () => RESTCalendarStore.calendarEntryDeleteEvent(
            owner, calendarStore, r));

    test('change listing on create (contact owner)',
        () => StorageCalendar.changeOnCreate(owner, calendarStore, r.user));

    test(
        'latest change on create (contact owner)',
        () =>
            StorageCalendar.latestChangeOnCreate(owner, calendarStore, r.user));

    test('change listing on update (contact owner)',
        () => StorageCalendar.changeOnUpdate(owner, calendarStore, r.user));

    test(
        'latest change on update (contact owner)',
        () =>
            StorageCalendar.latestChangeOnUpdate(owner, calendarStore, r.user));

    test('change listing on remove (contact owner)',
        () => StorageCalendar.changeOnRemove(owner, calendarStore, r.user));

    test(
        'latest change on remove (contact owner)',
        () =>
            StorageCalendar.latestChangeOnRemove(owner, calendarStore, r.user));

    /**
   * Tests for event presence upon creating calendar entries for receptions.
   */
    setUp(() async {
      transport = new Transport.Client();
      r = ReceptionistPool.instance.aquire();
      receptionStore = new Service.RESTReceptionStore(
          Config.receptionStoreUri, r.authToken, transport);
      calendarStore = new Service.RESTCalendarStore(
          Config.calendarStoreUri, r.authToken, transport);

      reception = await receptionStore.create(Randomizer.randomReception());

      owner = new Model.OwningReception(reception.ID);

      return r.initialize();
    });

    tearDown(() async {
      await receptionStore.remove(reception.ID);

      transport.client.close(force: true);
      ReceptionistPool.instance.release(r);
      await r.teardown();
    });

    test(
        'create (reception owner - event presence)',
        () => RESTCalendarStore.calendarEntryCreateEvent(
            owner, calendarStore, r));

    test(
        'update (reception owner - event presence)',
        () => RESTCalendarStore.calendarEntryUpdateEvent(
            owner, calendarStore, r));

    test(
        'delete (reception owner - event presence)',
        () => RESTCalendarStore.calendarEntryDeleteEvent(
            owner, calendarStore, r));

    test('change listing on create (reception owner)',
        () => StorageCalendar.changeOnCreate(owner, calendarStore, r.user));

    test(
        'latest change on create (reception owner)',
        () =>
            StorageCalendar.latestChangeOnCreate(owner, calendarStore, r.user));

    test('change listing on update (reception owner)',
        () => StorageCalendar.changeOnUpdate(owner, calendarStore, r.user));

    test(
        'latest change on update (reception owner)',
        () =>
            StorageCalendar.latestChangeOnUpdate(owner, calendarStore, r.user));

    test('change listing on remove (reception owner)',
        () => StorageCalendar.changeOnRemove(owner, calendarStore, r.user));

    test(
        'latest change on remove (reception owner)',
        () =>
            StorageCalendar.latestChangeOnRemove(owner, calendarStore, r.user));
  });
}
