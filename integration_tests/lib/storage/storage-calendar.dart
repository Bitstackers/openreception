part of openreception_tests.storage;

abstract class Calendar {
  static final Logger _log = new Logger('$_libraryName.Calendar');

  /**
   *
   */
  static create(model.Owner owner, storage.Calendar calendarStore,
      model.User creator) async {
    model.CalendarEntry createdEntry = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator);

    await calendarStore.remove(createdEntry.id, creator);
  }

  /**
   *
   */
  static update(model.Owner owner, storage.Calendar calendarStore,
      model.User creator) async {
    model.CalendarEntry createdEntry = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator);

    {
      model.CalendarEntry changes = Randomizer.randomCalendarEntry()
        ..id = createdEntry.id
        ..owner = createdEntry.owner;
      createdEntry = changes;
    }

    await calendarStore.update(createdEntry, creator);

    await calendarStore.remove(createdEntry.id, creator);
  }

  /**
   * Test server behaviour when trying to list calendar events associated with
   * a given owner.
   *
   * The expected behaviour is that the server should return a list of
   * CalendarEntry objects.
   */
  static Future get(model.Owner owner, storage.Calendar calendarStore,
      model.User creator) async {
    model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator);

    model.CalendarEntry fetched = await calendarStore.get(created.id);
    _log.finest('Created:');
    _log.finest(created.toJson());
    _log.finest('Fetched:');
    _log.finest(fetched.toJson());
    final oneMs = new Duration(milliseconds: 1);

    expect(created.id, equals(fetched.id));
    expect(created.start.difference(fetched.start), lessThan(oneMs));
    expect(created.stop.difference(fetched.stop), lessThan(oneMs));
    expect(created.content, equals(fetched.content));
    expect(created.owner, equals(fetched.owner));
    expect(created.owner, equals(fetched.owner));

    ///Cleanup
    await calendarStore.remove(created.id, creator);
  }

  /**
   * Test server behaviour when trying to aquire a calendar event object that
   * is non-existing.
   *
   * The expected behaviour is that the server should return "Not Found".
   */
  static Future getNonExistingEntry(ServiceAgent sa) async {
    try {
      await sa.calendarStore.get(-1);
      fail('Expected NotFound exception');
    } on storage.NotFound {
      // Successs
      await new Future.delayed(new Duration(milliseconds: 10));
    }
  }

  /**
   *
   */
  static list(model.Owner owner, storage.Calendar calendarStore,
      model.User creator) async {
    model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator);

    Iterable<model.CalendarEntry> listing = await calendarStore.list(owner);

    model.CalendarEntry fetched =
        listing.firstWhere((entry) => entry.id == created.id);

    final oneMs = new Duration(milliseconds: 1);

    expect(created.id, equals(fetched.id));
    expect(created.start.difference(fetched.start), lessThan(oneMs));
    expect(created.stop.difference(fetched.stop), lessThan(oneMs));
    expect(created.content, equals(fetched.content));
    expect(created.owner, equals(fetched.owner));
    expect(created.owner, equals(fetched.owner));

    ///Cleanup
    await calendarStore.remove(created.id, creator);
  }

  /**
   *
   */
  static remove(model.Owner owner, storage.Calendar calendarStore,
      model.User creator) async {
    model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator);

    _log.info('Removing calendar entry');
    await calendarStore.remove(created.id, creator);

    _log.info('Asserting that the created entry is no longer found');
    expect(calendarStore.get(created.id),
        throwsA(new isInstanceOf<storage.NotFound>()));
  }

  /**
   * Test server behaviour with regards to calendar changes.
   * This function creates an entry and asserts that a change is also present.
   */
  static Future changeOnCreate(model.Owner owner,
      storage.Calendar calendarStore, model.User creator) async {
    model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator);

    _log.info('Creating a calendar event for owner $owner.');

    Iterable<model.CalendarEntryChange> changes =
        await calendarStore.changes(created.id);

    _log.info('Listing changes and validating.');

    expect(changes.length, equals(1));
    expect(changes.first.changedAt.millisecondsSinceEpoch,
        lessThan(new DateTime.now().millisecondsSinceEpoch));
    expect(changes.first.userId, equals(creator.id));

    await calendarStore.remove(created.id, creator);
  }

  /**
   *
   */
  static Future latestChangeOnCreate(model.Owner owner,
      storage.Calendar calendarStore, model.User creator) async {
    model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator);

    _log.info('Creating a calendar event for owner $owner.');

    model.CalendarEntryChange latestChange =
        await calendarStore.latestChange(created.id);

    _log.info('Listing changes and validating.');

    // expect(latestChange.lastEntry.asMap,
    //     equals(new model.CalendarEntry.empty().toJson()));
    // expect(latestChange.changedAt.millisecondsSinceEpoch,
    //     lessThan(new DateTime.now().millisecondsSinceEpoch));
    // expect(latestChange.userID, equals(creator.uuid));
  }

  /**
   * Test server behaviour with regards to calendar changes.
   * This function update an entry and asserts that another change is present.
   */
  static Future changeOnUpdate(model.Owner owner,
      storage.Calendar calendarStore, model.User creator) async {
    model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator);

    _log.info('Creating a calendar event for owner $owner.');

    model.CalendarEntry changed = Randomizer.randomCalendarEntry()
      ..id = created.id
      ..owner = created.owner;

    await calendarStore.update(changed, creator);
    Iterable<model.CalendarEntryChange> changes =
        await calendarStore.changes(created.id);

    _log.info('Listing changes and validating.');

    expect(changes.length, equals(2));

    //expect(changes.first.lastEntry.asMap, equals(created.toJson()));

    expect(changes.first.changedAt.millisecondsSinceEpoch,
        lessThan(new DateTime.now().millisecondsSinceEpoch));
//    expect(changes.first.userID, equals(creator.uuid));
  }

  /**
   *
   */
  static Future latestChangeOnUpdate(model.Owner owner,
      storage.Calendar calendarStore, model.User creator) async {
    model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator);

    _log.info('Creating a calendar event for owner $owner.');

    model.CalendarEntry changed = Randomizer.randomCalendarEntry()
      ..id = created.id
      ..owner = created.owner;

    await calendarStore.update(changed, creator);
    Iterable<model.CalendarEntryChange> changes =
        await calendarStore.changes(created.id);

    _log.info('Listing changes and validating.');

    expect(changes.length, equals(2));

    model.CalendarEntryChange latestChange =
        await calendarStore.latestChange(created.id);

    _log.info('Getting latests change and validating.');

    // expect(latestChange.lastEntry.asMap, equals(created.asMap));
    // expect(latestChange.changedAt.millisecondsSinceEpoch,
    //     lessThan(new DateTime.now().millisecondsSinceEpoch));
    // expect(latestChange.userID, equals(creator.uuid));
  }

  /**
   * Test server behaviour with regards to calendar changes.
   * This function removes an entry and asserts that no changes are present.
   */
  static Future changeOnRemove(model.Owner owner,
      storage.Calendar calendarStore, model.User creator) async {
    model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator);

    _log.info('Removing calendar event for owner $owner.');

    await calendarStore.remove(created.id, creator);
    Iterable<model.CalendarEntryChange> changes =
        await calendarStore.changes(created.id);

    _log.info('Listing changes and validating.');

    expect(changes.length, equals(2));

    // expect(changes.first.lastEntry.asMap, equals(created.asMap));
    //
    // expect(changes.first.changedAt.millisecondsSinceEpoch,
    //     lessThan(new DateTime.now().millisecondsSinceEpoch));
    // expect(changes.first.userID, equals(creator.uuid));
    //
    // await calendarStore.purge(created.uuid);
    //
    expect(await calendarStore.changes(created.id), isEmpty);
  }

  /**
   *
   */
  static Future latestChangeOnRemove(model.Owner owner,
      storage.Calendar calendarStore, model.User creator) async {
    model.CalendarEntry created = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, creator);

    _log.info('Removing calendar event for owner $owner.');

    await calendarStore.remove(created.id, creator);
    Iterable<model.CalendarEntryChange> changes =
        await calendarStore.changes(created.id);

    _log.info('Listing changes and validating.');

    expect(changes.length, equals(2));

    _log.info('Getting latests change and validating.');
    model.CalendarEntryChange latestChange =
        await calendarStore.latestChange(created.id);

    _log.info('Latests change: ${latestChange.toJson()}');

    // expect(latestChange.lastEntry.asMap, equals(created.asMap));
    // expect(latestChange.changedAt.millisecondsSinceEpoch,
    //     lessThan(new DateTime.now().millisecondsSinceEpoch));
    // expect(latestChange.userID, equals(creator.id));
    //
    // expect(await calendarStore.changes(created.uuid), isEmpty);
  }
}
