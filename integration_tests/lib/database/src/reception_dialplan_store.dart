part of or_test_fw;

abstract class ReceptionDialplanStore {

  /**
   *
   */
  static Future create(Storage.ReceptionDialplan rdpStore) async {
    Model.ReceptionDialplan rdp = Randomizer.randomDialplan();

    print(rdp.toJson());

    Model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp);

    expect(createdDialplan, isNotNull);
    expect(createdDialplan.id, greaterThan(Model.ReceptionDialplan.noId));

    await rdpStore.remove(createdDialplan.id);
  }

  /**
   *
   */
  static Future get(Storage.ReceptionDialplan rdpStore) async {
    Model.ReceptionDialplan rdp = Randomizer.randomDialplan();

    Model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp);

    expect((await rdpStore.get(createdDialplan.id)).id,
        greaterThan(Model.ReceptionDialplan.noId));

    await rdpStore.remove(createdDialplan.id);
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

    await rdpStore.remove(createdDialplan.id);
    await expect(rdpStore.get(createdDialplan.id),
        throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  /**
   *
   */
  static Future update(Storage.ReceptionDialplan rdpStore) async {

    Model.ReceptionDialplan rdp = Randomizer.randomDialplan();

    Model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp);

    expect(createdDialplan, isNotNull);
    expect(createdDialplan.id, greaterThan(Model.ReceptionDialplan.noId));

    {
      Model.ReceptionDialplan changed = Randomizer.randomDialplan();
      changed.id = createdDialplan.id;

      createdDialplan = changed;
    }

    await rdpStore.update(createdDialplan);
    await rdpStore.remove(createdDialplan.id);
  }
}
