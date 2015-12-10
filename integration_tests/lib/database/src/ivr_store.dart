part of or_test_fw;

abstract class IvrStore {
  /**
   *
   */
  static Future create(Storage.Ivr ivrStore) async {
    Model.IvrMenu menu = Randomizer.randomIvrMenu();

    Model.IvrMenu createdMenu = await ivrStore.create(menu);

    expect(createdMenu, isNotNull);
    expect(createdMenu.name, equals(menu.name));

    await ivrStore.remove(createdMenu.name);
  }

  /**
   *
   */
  static Future get(Storage.Ivr ivrStore) async {
    Model.IvrMenu menu = Randomizer.randomIvrMenu();

    Model.IvrMenu createdMenu = await ivrStore.create(menu);

    expect((await ivrStore.get(createdMenu.name)).name, equals(menu.name));

    await ivrStore.remove(createdMenu.name);
  }

  /**
   *
   */
  static Future list(Storage.Ivr ivrStore) async {
    expect((await ivrStore.list()), new isInstanceOf<Iterable>());
  }

  /**
   *
   */
  static Future remove(Storage.Ivr ivrStore) async {
    Model.IvrMenu menu = Randomizer.randomIvrMenu();

    Model.IvrMenu createdMenu = await ivrStore.create(menu);

    await ivrStore.remove(createdMenu.name);
    await expect(ivrStore.get(createdMenu.name),
        throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  /**
   *
   */
  static Future update(Storage.Ivr ivrStore) async {
    Model.IvrMenu menu = Randomizer.randomIvrMenu();

    Model.IvrMenu createdMenu = await ivrStore.create(menu);

    expect(createdMenu, isNotNull);
    expect(createdMenu.name, equals(menu.name));

    {
      Model.IvrMenu changes = Randomizer.randomIvrMenu();
      changes.name = createdMenu.name;
      createdMenu = changes;
    }

    await ivrStore.update(createdMenu);

    await ivrStore.remove(createdMenu.name);
  }
}
