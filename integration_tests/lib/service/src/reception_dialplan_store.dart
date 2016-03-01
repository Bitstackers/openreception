part of or_test_fw;

abstract class ReceptionDialplanStore {
  /**
   *
   */
  static Future create(Storage.ReceptionDialplan rdpStore,
      [Model.User user]) async {
    Model.ReceptionDialplan rdp = Randomizer.randomDialplan();

    Model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp, user);

    expect(createdDialplan, isNotNull);
    expect(createdDialplan.extension, isNotEmpty);

    await rdpStore.remove(createdDialplan.extension, user);
  }

  /**
   *
   */
  static Future deploy(Service.RESTDialplanStore rdpStore,
      Service.RESTReceptionStore receptionStore,
      [Model.User user]) async {
    Model.ReceptionDialplan rdp = Randomizer.randomDialplan();

    Model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp, user);
    Model.Reception createdReception = await receptionStore
        .create(Randomizer.randomReception()..dialplan = rdp.extension);

    await rdpStore.deployDialplan(rdp.extension, createdReception.uuid);

    await receptionStore.remove(createdReception.ID);
    await rdpStore.remove(createdDialplan.extension, user);
  }

  /**
   *
   */
  static Future get(Storage.ReceptionDialplan rdpStore,
      [Model.User user]) async {
    Model.ReceptionDialplan rdp = Randomizer.randomDialplan();

    Model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp, user);

    expect(
        (await rdpStore.get(createdDialplan.extension)).extension, isNotEmpty);

    await rdpStore.remove(createdDialplan.extension, user);
  }

  /**
   *
   */
  static Future list(Storage.ReceptionDialplan rdpStore,
      [Model.User user]) async {
    expect((await rdpStore.list()), new isInstanceOf<Iterable>());
  }

  /**
   *
   */
  static Future remove(Storage.ReceptionDialplan rdpStore,
      [Model.User user]) async {
    Model.ReceptionDialplan rdp = Randomizer.randomDialplan();

    Model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp, user);

    await rdpStore.remove(createdDialplan.extension, user);
    await expect(rdpStore.get(createdDialplan.extension),
        throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  /**
   *
   */
  static Future update(Storage.ReceptionDialplan rdpStore,
      [Model.User user]) async {
    Model.ReceptionDialplan rdp = Randomizer.randomDialplan();

    Model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp, user);

    expect(createdDialplan, isNotNull);
    expect(createdDialplan.extension, isNotEmpty);

    {
      Model.ReceptionDialplan changed = Randomizer.randomDialplan();
      changed.extension = createdDialplan.extension;

      createdDialplan = changed;
    }

    await rdpStore.update(createdDialplan, user);
    await rdpStore.remove(createdDialplan.extension, user);
  }
}
