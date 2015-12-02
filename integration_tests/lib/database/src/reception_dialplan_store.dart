part of or_test_fw;

abstract class ReceptionDialplanStore {

  /**
   *
   */
  static Future create(Storage.ReceptionDialplan rdpStore) async {
    Model.ReceptionDialplan rdp = Randomizer.randomDialplan();

    Model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp);

    expect(createdDialplan, isNotNull);
    expect(createdDialplan.extension, isNotEmpty);

    await rdpStore.remove(createdDialplan.extension);
  }

  /**
   *
   */
  static Future get(Storage.ReceptionDialplan rdpStore) async {
    Model.ReceptionDialplan rdp = Randomizer.randomDialplan();

    Model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp);

    expect((await rdpStore.get(createdDialplan.extension)).extension,
           isNotEmpty);

    await rdpStore.remove(createdDialplan.extension);
  }

  /**
   *
   */
  static Future list(Storage.ReceptionDialplan rdpStore) async {
    expect((await rdpStore.list()), new isInstanceOf<Iterable>());
  }

  /**
   *
   */
  static Future remove(Storage.ReceptionDialplan rdpStore) async {
    Model.ReceptionDialplan rdp = Randomizer.randomDialplan();

    Model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp);

    await rdpStore.remove(createdDialplan.extension);
    await expect(rdpStore.get(createdDialplan.extension),
        throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  /**
   *
   */
  static Future update(Storage.ReceptionDialplan rdpStore) async {

    Model.ReceptionDialplan rdp = Randomizer.randomDialplan();

    Model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp);

    expect(createdDialplan, isNotNull);
    expect(createdDialplan.extension, isNotEmpty);

    {
      Model.ReceptionDialplan changed = Randomizer.randomDialplan();
      changed.extension = createdDialplan.extension;

      createdDialplan = changed;
    }

    await rdpStore.update(createdDialplan);
    await rdpStore.remove(createdDialplan.extension);
  }
}
