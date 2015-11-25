part of or_test_fw;

abstract class IvrStore {

  /**
   *
   */
  static Future create(Storage.Ivr ivrStore) async {
    Model.IvrMenu menu = new Model.IvrMenu('test', new Model.Playback('test'));

    Model.IvrMenu createdMenu = await ivrStore.create(menu);

    expect(createdMenu, isNotNull);
    expect(createdMenu.id, greaterThan(Model.IvrMenu.noId));

    await ivrStore.remove(createdMenu.id);
  }

  /**
   *
   */
  static Future get(Storage.Ivr ivrStore) async {
    Model.IvrMenu menu = new Model.IvrMenu('test', new Model.Playback('test'));

    Model.IvrMenu createdMenu = await ivrStore.create(menu);

    expect((await ivrStore.get(createdMenu.id)).id,
        greaterThan(Model.IvrMenu.noId));

    await ivrStore.remove(createdMenu.id);
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
    Model.IvrMenu menu = new Model.IvrMenu('test', new Model.Playback('test'));

    Model.IvrMenu createdMenu = await ivrStore.create(menu);

    await ivrStore.remove(createdMenu.id);
    await expect(ivrStore.get(createdMenu.id),
        throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  /**
   *
   */
  static Future update(Storage.Ivr ivrStore) async {
    Model.IvrMenu menu = new Model.IvrMenu('test', new Model.Playback('test'));

    Model.IvrMenu createdMenu = await ivrStore.create(menu);

    expect(createdMenu, isNotNull);
    expect(createdMenu.id, greaterThan(Model.IvrMenu.noId));

    await ivrStore.update(createdMenu);

    await ivrStore.remove(createdMenu.id);
  }
}
