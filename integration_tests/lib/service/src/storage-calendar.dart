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
    expect(changes.first.userID, equals(creator.ID));

    await calendarStore.purge(created.ID);
  }

  /**
   *
   */
  static Future latestChangeOnCreate(Model.Owner owner,
      Storage.Calendar calendarStore, Model.User creator) async {
    Model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator.ID);

    _log.info('Creating a calendar event for owner $owner.');

    Model.CalendarEntryChange latestChange =
        await calendarStore.latestChange(created.ID);

    _log.info('Listing changes and validating.');

    expect(latestChange.lastEntry.asMap,
        equals(new Model.CalendarEntry.empty().asMap));
    expect(latestChange.changedAt.millisecondsSinceEpoch,
        lessThan(new DateTime.now().millisecondsSinceEpoch));
    expect(latestChange.userID, equals(creator.ID));

    await calendarStore.purge(created.ID);
  }

  /**
   * Test server behaviour with regards to calendar changes.
   * This function update an entry and asserts that another change is present.
   */
  static Future changeOnUpdate(Model.Owner owner,
      Storage.Calendar calendarStore, Model.User creator) async {
    Model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator.ID);

    _log.info('Creating a calendar event for owner $owner.');

    Model.CalendarEntry changed = Randomizer.randomCalendarEntry()
      ..ID = created.ID
      ..owner = created.owner;

    await calendarStore.update(changed, creator.ID);
    Iterable<Model.CalendarEntryChange> changes =
        await calendarStore.changes(created.ID);

    _log.info('Listing changes and validating.');

    expect(changes.length, equals(2));

    expect(changes.first.lastEntry.asMap, equals(created.asMap));

    expect(changes.first.changedAt.millisecondsSinceEpoch,
        lessThan(new DateTime.now().millisecondsSinceEpoch));
    expect(changes.first.userID, equals(creator.ID));

    await calendarStore.purge(created.ID);
  }

  /**
   *
   */
  static Future latestChangeOnUpdate(Model.Owner owner,
      Storage.Calendar calendarStore, Model.User creator) async {
    Model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator.ID);

    _log.info('Creating a calendar event for owner $owner.');

    Model.CalendarEntry changed = Randomizer.randomCalendarEntry()
      ..ID = created.ID
      ..owner = created.owner;

    await calendarStore.update(changed, creator.ID);
    Iterable<Model.CalendarEntryChange> changes =
        await calendarStore.changes(created.ID);

    _log.info('Listing changes and validating.');

    expect(changes.length, equals(2));

    Model.CalendarEntryChange latestChange =
        await calendarStore.latestChange(created.ID);

    _log.info('Getting latests change and validating.');

    expect(latestChange.lastEntry.asMap, equals(created.asMap));
    expect(latestChange.changedAt.millisecondsSinceEpoch,
        lessThan(new DateTime.now().millisecondsSinceEpoch));
    expect(latestChange.userID, equals(creator.ID));

    await calendarStore.purge(created.ID);
  }

  /**
   * Test server behaviour with regards to calendar changes.
   * This function removes an entry and asserts that no changes are present.
   */
  static Future changeOnRemove(Model.Owner owner,
      Storage.Calendar calendarStore, Model.User creator) async {
    Model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator.ID);

    _log.info('Removing calendar event for owner $owner.');

    await calendarStore.remove(created.ID, creator.ID);
    Iterable<Model.CalendarEntryChange> changes =
        await calendarStore.changes(created.ID);

    _log.info('Listing changes and validating.');

    expect(changes.length, equals(2));

    expect(changes.first.lastEntry.asMap, equals(created.asMap));

    expect(changes.first.changedAt.millisecondsSinceEpoch,
        lessThan(new DateTime.now().millisecondsSinceEpoch));
    expect(changes.first.userID, equals(creator.ID));

    await calendarStore.purge(created.ID);

    expect(await calendarStore.changes(created.ID), isEmpty);
  }

  /**
   *
   */
  static Future latestChangeOnRemove(Model.Owner owner,
      Storage.Calendar calendarStore, Model.User creator) async {
    Model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator.ID);

    _log.info('Removing calendar event for owner $owner.');

    await calendarStore.remove(created.ID, creator.ID);
    Iterable<Model.CalendarEntryChange> changes =
        await calendarStore.changes(created.ID);

    _log.info('Listing changes and validating.');

    expect(changes.length, equals(2));

    _log.info('Getting latests change and validating.');
    Model.CalendarEntryChange latestChange =
        await calendarStore.latestChange(created.ID);

    _log.info('Latests change: ${latestChange.asMap}');

    expect(latestChange.lastEntry.asMap, equals(created.asMap));
    expect(latestChange.changedAt.millisecondsSinceEpoch,
        lessThan(new DateTime.now().millisecondsSinceEpoch));
    expect(latestChange.userID, equals(creator.ID));

    await calendarStore.purge(created.ID);

    expect(await calendarStore.changes(created.ID), isEmpty);

  }
}
