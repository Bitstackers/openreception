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

      contact =
          await contactStore.create(Randomizer.randomBaseContact(), creator);

      owner = new Model.OwningContact(contact.uuid);
    });

    tearDown(() async {
      transport.client.close(force: true);
    });

    test('get (non-existing)',
        () => storeTest.Calendar.getNonExistingEntry(calendarStore));

    /**
     * Basic CRUD tests for contact owner.
     */
    test('create (contact owner)',
        () => storeTest.Calendar.create(owner, calendarStore, creator));

    test('get (contact owner)',
        () => storeTest.Calendar.get(owner, calendarStore, creator));

    test('update (contact owner)',
        () => storeTest.Calendar.update(owner, calendarStore, creator));

    test('list (contact owner)',
        () => storeTest.Calendar.list(owner, calendarStore, creator));

    test('remove (contact owner)',
        () => storeTest.Calendar.remove(owner, calendarStore, creator));

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

      owner = new Model.OwningReception(reception.uuid);
    });

    tearDown(() async {
      transport.client.close(force: true);
      await receptionStore.remove(reception.uuid);
      await userStore.remove(creator.uuid);
    });

    /**
     * Basic CRUD tests for reception owner.
     */
    test('get (reception owner)',
        () => storeTest.Calendar.get(owner, calendarStore, creator));

    test('create (reception owner)',
        () => storeTest.Calendar.create(owner, calendarStore, creator));

    test('list (reception owner)',
        () => storeTest.Calendar.list(owner, calendarStore, creator));

    test('remove (reception owner)',
        () => storeTest.Calendar.remove(owner, calendarStore, creator));

    test('update (reception owner)',
        () => storeTest.Calendar.update(owner, calendarStore, creator));

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

      owner = new Model.OwningContact(contact.uuid);

      return r.initialize();
    });

    tearDown(() async {
      await contactStore.remove(contact.uuid);

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
        () => storeTest.Calendar.changeOnCreate(owner, calendarStore, r.user));

    test(
        'latest change on create (contact owner)',
        () => storeTest.Calendar
            .latestChangeOnCreate(owner, calendarStore, r.user));

    test('change listing on update (contact owner)',
        () => storeTest.Calendar.changeOnUpdate(owner, calendarStore, r.user));

    test(
        'latest change on update (contact owner)',
        () => storeTest.Calendar
            .latestChangeOnUpdate(owner, calendarStore, r.user));

    test('change listing on remove (contact owner)',
        () => storeTest.Calendar.changeOnRemove(owner, calendarStore, r.user));

    test(
        'latest change on remove (contact owner)',
        () => storeTest.Calendar
            .latestChangeOnRemove(owner, calendarStore, r.user));

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
