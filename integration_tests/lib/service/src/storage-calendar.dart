part of or_test_fw;

abstract class StorageCalendar {
  static final Logger _log = new Logger('$libraryName.StorageCalendar');

  /**
   *
   */
  static create(Model.Owner owner, Storage.Calendar calendarStore,
      Model.User creator) async {
    Model.CalendarEntry createdEntry = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator.ID);

    await calendarStore.purge(createdEntry.ID);
  }

  /**
   *
   */
  static update(Model.Owner owner, Storage.Calendar calendarStore,
      Model.User creator) async {
    Model.CalendarEntry createdEntry = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator.ID);

    {
      Model.CalendarEntry changes = Randomizer.randomCalendarEntry()
        ..ID = createdEntry.ID
        ..owner = createdEntry.owner;
      createdEntry = changes;
    }

    await calendarStore.update(createdEntry, creator.ID);

    await calendarStore.purge(createdEntry.ID);
  }

  /**
   * Test server behaviour when trying to list calendar events associated with
   * a given owner.
   *
   * The expected behaviour is that the server should return a list of
   * CalendarEntry objects.
   */
  static get(Model.Owner owner, Storage.Calendar calendarStore,
      Model.User creator) async {
    Model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator.ID);

    Model.CalendarEntry fetched = await calendarStore.get(created.ID);

    expect(created.ID, equals(fetched.ID));
    expect(created.start.isAtSameMomentAs(fetched.start), isTrue);
    expect(created.stop.isAtSameMomentAs(fetched.stop), isTrue);
    expect(created.content, equals(fetched.content));
    expect(created.owner, equals(fetched.owner));
    expect(created.owner, equals(fetched.owner));

    ///Cleanup
    await calendarStore.purge(created.ID);
  }

  /**
   * Test server behaviour when trying to aquire a calendar event object that
   * is non-existing.
   *
   * The expected behaviour is that the server should return "Not Found".
   */
  static getNonExistingEntry(Storage.Calendar calendarStore) => expect(
      calendarStore.get(0), throwsA(new isInstanceOf<Storage.NotFound>()));

  /**
   *
   */
  static list(Model.Owner owner, Storage.Calendar calendarStore,
      Model.User creator) async {
    Model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator.ID);

    Iterable<Model.CalendarEntry> listing = await calendarStore.list(owner);

    Model.CalendarEntry fetched =
        listing.firstWhere((entry) => entry.ID == created.ID);

    expect(created.ID, equals(fetched.ID));
    expect(created.start.isAtSameMomentAs(fetched.start), isTrue);
    expect(created.stop.isAtSameMomentAs(fetched.stop), isTrue);
    expect(created.content, equals(fetched.content));
    expect(created.owner, equals(fetched.owner));
    expect(created.owner, equals(fetched.owner));

    ///Cleanup
    await calendarStore.purge(created.ID);
  }

  /**
   *
   */
  static remove(Model.Owner owner, Storage.Calendar calendarStore,
      Model.User creator) async {
    Model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator.ID);

    _log.info('Removing calendar entry');
    await calendarStore.remove(created.ID, creator.ID);

    _log.info('Asserting that the created entry is no longer found');
    expect(calendarStore.get(created.ID),
        throwsA(new isInstanceOf<Storage.NotFound>()));

    _log.info('Asserting that the created entry found in deleted query');
    Model.CalendarEntry deleted =
        await calendarStore.get(created.ID, deleted: true);

    expect(created.ID, equals(deleted.ID));
    expect(created.start.isAtSameMomentAs(deleted.start), isTrue);
    expect(created.stop.isAtSameMomentAs(deleted.stop), isTrue);
    expect(created.content, equals(deleted.content));
    expect(created.owner, equals(deleted.owner));

    _log.info('Cleaning up');

    await calendarStore.purge(created.ID);
  }

  /**
   *
   */
  static purge(Model.Owner owner, Storage.Calendar calendarStore,
      Model.User creator) async {
    Model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator.ID);

    _log.info('Purging calendar entry');
    await calendarStore.purge(created.ID);

    _log.info('Asserting that the created entry is no longer found');
    expect(calendarStore.get(created.ID),
        throwsA(new isInstanceOf<Storage.NotFound>()));

    _log.info(
        'Asserting that the created entry is no longer found among deleted');
    expect(calendarStore.get(created.ID, deleted: true),
        throwsA(new isInstanceOf<Storage.NotFound>()));

    _log.info('Cleaning up');
  }

  /**
   * Test server behaviour with regards to calendar changes.
   * This function creates an entry and asserts that a change is also present.
   */
  static Future changeOnCreate(Model.Owner owner,
      Storage.Calendar calendarStore, Model.User creator) async {
    Model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator.ID);

    _log.info('Creating a calendar event for owner $owner.');

    Iterable<Model.CalendarEntryChange> changes =
        await calendarStore.changes(created.ID);

    _log.info('Listing changes and validating.');

    expect(changes.length, equals(1));
    expect(changes.first.changedAt.millisecondsSinceEpoch,
        lessThan(new DateTime.now().millisecondsSinceEpoch));
    expect(changes.first.userID, isNot(Model.User.noID));
  }

  /**
   * Test server behaviour with regards to calendar changes.
   * This function update an entry and asserts that another change is present.
   */
  static Future changeOnUpdate(Service.RESTReceptionStore receptionStore) {
    int receptionID = 1;

    return receptionStore
        .calendar(receptionID)
        .then((Iterable<Model.CalendarEntry> entries) {
      // Update the last event in list.
      Model.CalendarEntry entry = entries.last
        ..beginsAt = new DateTime.now()
        ..until = new DateTime.now().add(new Duration(hours: 2))
        ..content = Randomizer.randomEvent();

      int updateCount = -1;

      _log.info('Updating a calendar event for reception $receptionID.');

      return receptionStore
          .calendarEntryChanges(entry.ID)
          .then((Iterable<Model.CalendarEntryChange> changes) =>
              updateCount = changes.length)
          .then((_) => receptionStore
                  .calendarEventUpdate(entry)
                  .then((Model.CalendarEntry updatedEvent) {
                return receptionStore
                    .calendarEntryChanges(updatedEvent.ID)
                    .then((Iterable<Model.CalendarEntryChange> changes) {
                  expect(changes.length, equals(updateCount + 1));
                  expect(changes.first.changedAt.millisecondsSinceEpoch,
                      lessThan(new DateTime.now().millisecondsSinceEpoch));
                  expect(changes.first.userID, isNot(Model.User.noID));
                });
              }));
    });
  }

  /**
   * Test server behaviour with regards to calendar changes.
   * This function removes an entry and asserts that no changes are present.
   */
  static Future changeOnDelete(Service.RESTReceptionStore receptionStore) {
    int receptionID = 1;

    return receptionStore
        .calendar(receptionID)
        .then((Iterable<Model.CalendarEntry> events) {
      // Update the last event in list.
      Model.CalendarEntry event = events.last;

      _log.info(
          'Got event ${event.asMap} - ${event.contactID}@${event.receptionID}');

      _log.info(
          'Deleting last (in list) calendar event for reception $receptionID.');

      return receptionStore.calendarEventRemove(event).then((_) {
        return receptionStore
            .calendarEntryChanges(event.ID)
            .then((Iterable<Model.CalendarEntryChange> changes) {
          expect(changes.length, equals(0));

          return expect(receptionStore.calendarEntryLatestChange(event.ID),
              throwsA(new isInstanceOf<Storage.NotFound>()));
        });
      });
    });
  }
}
