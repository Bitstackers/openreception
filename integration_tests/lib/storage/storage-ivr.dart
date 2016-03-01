part of openreception_tests.storage;

abstract class Ivr {
  /**
   *
   */
  static Future create(storage.Ivr ivrStore, [model.User user]) async {
    model.IvrMenu menu = Randomizer.randomIvrMenu();

    model.IvrMenu createdMenu = await ivrStore.create(menu, user);

    expect(createdMenu, isNotNull);
    expect(createdMenu.name, equals(menu.name));

    await ivrStore.remove(createdMenu.name, user);
  }

  /**
   *
   */
  static Future get(storage.Ivr ivrStore, [model.User user]) async {
    model.IvrMenu menu = Randomizer.randomIvrMenu();

    model.IvrMenu createdMenu = await ivrStore.create(menu, user);

    expect((await ivrStore.get(createdMenu.name)).name, equals(menu.name));

    await ivrStore.remove(createdMenu.name, user);
  }

  /**
   *
   */
  static Future list(storage.Ivr ivrStore, [model.User user]) async {
    expect((await ivrStore.list()), new isInstanceOf<Iterable>());
  }

  /**
   *
   */
  static Future remove(storage.Ivr ivrStore, [model.User user]) async {
    model.IvrMenu menu = Randomizer.randomIvrMenu();

    model.IvrMenu createdMenu = await ivrStore.create(menu, user);

    await ivrStore.remove(createdMenu.name, user);
    await expect(ivrStore.get(createdMenu.name),
        throwsA(new isInstanceOf<storage.NotFound>()));
  }

  /**
   *
   */
  static Future update(storage.Ivr ivrStore, [model.User user]) async {
    model.IvrMenu menu = Randomizer.randomIvrMenu();

    model.IvrMenu createdMenu = await ivrStore.create(menu, user);

    expect(createdMenu, isNotNull);
    expect(createdMenu.name, equals(menu.name));

    {
      model.IvrMenu changes = Randomizer.randomIvrMenu();
      changes.name = createdMenu.name;
      createdMenu = changes;
    }

    await ivrStore.update(createdMenu, user);

    //await ivrStore.remove(createdMenu.name, user);
  }
}
