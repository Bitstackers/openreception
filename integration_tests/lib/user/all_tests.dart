part of or_test_fw;

runUserTests () {

  group ('service.User', () {
    Transport.Client transport = null;
    Service.RESTUserStore userStore = null;
    Receptionist r;

    setUp (() {
      transport = new Transport.Client();
    });

    tearDown (() {
      transport.client.close(force : true);
    });

    test ('CORS headers present',
        () => User.isCORSHeadersPresent(transport.client));

    test ('Non-existing path',
        () => User.nonExistingPath(transport.client));

    setUp (() {
      transport = new Transport.Client();
      userStore = new Service.RESTUserStore
         (Config.userStoreUri, Config.serverToken, transport);

    });

    tearDown (() {
      userStore = null;
      transport.client.close(force : true);
    });

    test ('Non-existing user',
        () => User.nonExistingUser(userStore));

    test ('Existing user',
        () => User.existingUser(userStore));

    test ('Create',
        () => User.createUser(userStore));

    test ('Update',
        () => User.updateUser(userStore));

    test ('Remove',
        () => User.updateUser(userStore));

    test ('List users',
        () => User.listUsers(userStore));

    test ('Available group listing',
        () => User.listAllGroups(userStore));

    test ('groups (known user)',
        () => User.listGroupsOfUser(userStore));

    test ('groups (non-existing user)',
        () => User.listGroupsOfNonExistingUser(userStore));

    test ('group join',
        () => User.joinGroup(userStore));

    test ('group leave',
        () => User.leaveGroup(userStore));

    setUp (() {
      transport = new Transport.Client();
      userStore = new Service.RESTUserStore
         (Config.userStoreUri, Config.serverToken, transport);
      r = ReceptionistPool.instance.aquire();

      return r.initialize();
    });

//    tearDown (() {
//      userStore = null;
//      transport.client.close(force : true);
//
//      ReceptionistPool.instance.release(r);
//
//      return r.teardown();
//    });
//
//    test ('Create (event presence)',
//        () => User.createUserEvent(userStore, r));
//
//    test ('Update (event presence)',
//        () => User.updateUserEvent(userStore, r));
//
//    test ('Remove (event presence)',
//        () => User.removeUserEvent(userStore, r));
  });
}