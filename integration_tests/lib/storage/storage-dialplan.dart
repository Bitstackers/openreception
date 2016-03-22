part of openreception_tests.storage;

abstract class ReceptionDialplan {
  /**
   *
   */
  static Future create(
      storage.ReceptionDialplan rdpStore, model.User user) async {
    model.ReceptionDialplan rdp = Randomizer.randomDialplan();

    model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp, user);

    expect(createdDialplan, isNotNull);
    expect(createdDialplan.extension, isNotEmpty);

    await rdpStore.remove(createdDialplan.extension, user);
  }

  /**
   *
   */
  static Future get(storage.ReceptionDialplan rdpStore,
      [model.User user]) async {
    model.ReceptionDialplan rdp = Randomizer.randomDialplan();

    model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp, user);

    expect(
        (await rdpStore.get(createdDialplan.extension)).extension, isNotEmpty);

    await rdpStore.remove(createdDialplan.extension, user);
  }

  /**
   *
   */
  static Future list(storage.ReceptionDialplan rdpStore,
      [model.User user]) async {
    expect((await rdpStore.list()), new isInstanceOf<Iterable>());
  }

  /**
   *
   */
  static Future remove(storage.ReceptionDialplan rdpStore,
      [model.User user]) async {
    model.ReceptionDialplan rdp = Randomizer.randomDialplan();

    model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp, user);

    await rdpStore.remove(createdDialplan.extension, user);
    await expect(rdpStore.get(createdDialplan.extension),
        throwsA(new isInstanceOf<storage.NotFound>()));
  }

  /**
   *
   */
  static Future update(storage.ReceptionDialplan rdpStore,
      [model.User user]) async {
    model.ReceptionDialplan rdp = Randomizer.randomDialplan();

    model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp, user);

    expect(createdDialplan, isNotNull);
    expect(createdDialplan.extension, isNotEmpty);

    {
      model.ReceptionDialplan changed = Randomizer.randomDialplan();
      changed.extension = createdDialplan.extension;

      createdDialplan = changed;
    }

    await rdpStore.update(createdDialplan, user);
    await rdpStore.remove(createdDialplan.extension, user);
  }
}
