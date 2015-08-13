part of or_test_fw;

abstract class User {
  static Logger log = new Logger('$libraryName.User');

  /**
   * Test for the presence of CORS headers.
   */
  static Future isCORSHeadersPresent(HttpClient client) {
    Uri uri = Uri.parse('${Config.userStoreUri}/nonexistingpath');

    log.info('Checking CORS headers on a non-existing URL.');
    return client
        .getUrl(uri)
        .then((HttpClientRequest request) => request
            .close()
            .then((HttpClientResponse response) {
      if (response.headers['access-control-allow-origin'] == null &&
          response.headers['Access-Control-Allow-Origin'] == null) {
        fail('No CORS headers on path $uri');
      }
    })).then((_) {
      log.info('Checking CORS headers on an existing URL.');
      uri = Resource.User.single(Config.userStoreUri, 1);
      return client.getUrl(uri).then((HttpClientRequest request) => request
          .close()
          .then((HttpClientResponse response) {
        if (response.headers['access-control-allow-origin'] == null &&
            response.headers['Access-Control-Allow-Origin'] == null) {
          fail('No CORS headers on path $uri');
        }
      }));
    });
  }

  /**
   * Test server behaviour when trying to access a resource not associated with
   * a handler.
   *
   * The expected behaviour is that the server should return a Not Found error.
   */
  static Future nonExistingPath(HttpClient client) {
    Uri uri = Uri.parse(
        '${Config.userStoreUri}/nonexistingpath?token=${Config.serverToken}');

    log.info('Checking server behaviour on a non-existing path.');

    return client
        .getUrl(uri)
        .then((HttpClientRequest request) => request
            .close()
            .then((HttpClientResponse response) {
      if (response.statusCode != 404) {
        fail('Expected to received a 404 on path $uri');
      }
    }))
        .then((_) => log.info('Got expected status code 404.'))
        .whenComplete(() => client.close(force: true));
  }

  /**
   * Test server behaviour when trying to aquire a user object that does
   * not exist.
   *
   * The expected behaviour is that the server should return a Not Found error.
   */
  static void nonExistingUser(Storage.User userStore) {
    log.info('Checking server behaviour on a non-existing user.');

    return expect(
        userStore.get(-1), throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  /**
   * Test server behaviour when trying to aquire a user object that exists.
   *
   * The expected behaviour is that the server should return the
   * User object.
   */
  static void existingUser(Storage.User userStore) {
    const int userID = 1;
    log.info('Checking server behaviour on an existing user.');

    return expect(userStore.get(userID), isNotNull);
  }

  /**
   *
   */
  static Future createUser(Storage.User userStore) {
    log.info('Checking server behaviour on an user creation.');

    Model.User newUser = Randomizer.randomUser();

    return userStore.create(newUser).then((Model.User createdUser) {

      expect (createdUser.address, equals (newUser.address));
      expect (createdUser.googleAppcode, equals (newUser.googleAppcode));
      expect (createdUser.googleUsername, equals (newUser.googleUsername));
      expect (createdUser.ID, isNotNull);
      expect (createdUser.ID, greaterThan(Model.User.noID));
      expect (createdUser.name, equals (newUser.name));
      expect (createdUser.peer, equals (newUser.peer));
      expect (createdUser.portrait, equals (newUser.portrait));

      return userStore.remove(createdUser.ID);
    });
  }

  /**
   *
   */
  static Future createUserEvent(Storage.User userStore,
                                   Receptionist receptionist) {
    log.info('Checking server behaviour on an user creation.');

    Model.User newUser = Randomizer.randomUser();

    return userStore.create(newUser).then((Model.User createdUser) {
      return receptionist.waitFor(eventType: Event.Key.userChange)
        .then((Event.UserChange userChange) {
          expect (userChange.state, equals(Event.UserObjectState.CREATED));
          expect (userChange.userID, equals(createdUser.ID));
          return userStore.remove(createdUser.ID);
      });
    });
  }


  /**
   *
   */
  static Future updateUser(Storage.User userStore) {
    log.info('Checking server behaviour on an user updating.');

    return userStore.create(Randomizer.randomUser())
      .then((Model.User createdUser) {

      Model.User changedUser = Randomizer.randomUser()..ID = createdUser.ID;

      return userStore.update(changedUser).then((Model.User updatedUser) {

        expect (changedUser.address, equals (updatedUser.address));
        expect (changedUser.googleAppcode, equals (updatedUser.googleAppcode));
        expect (changedUser.googleUsername, equals (updatedUser.googleUsername));
        expect (changedUser.ID, equals(updatedUser.ID));
        expect (changedUser.name, equals (updatedUser.name));
        expect (changedUser.peer, equals (updatedUser.peer));
        expect (changedUser.portrait, equals (updatedUser.portrait));

        return userStore.remove(createdUser.ID);
      });
    });
  }

  /**
   *
   */
  static Future updateUserEvent(Storage.User userStore,
                                   Receptionist receptionist) {
    log.info('Checking server behaviour on an user updating.');

    return userStore.create(Randomizer.randomUser())
      .then((Model.User createdUser) {

      Model.User changedUser = Randomizer.randomUser()..ID = createdUser.ID;

      return receptionist.waitFor(eventType: Event.Key.userChange)
        .then((Event.UserChange userChange) {
          expect (userChange.state, equals(Event.UserObjectState.CREATED));
          receptionist.eventStack.clear();
      })
      .then((_) =>
        userStore.update(changedUser).then((Model.User updatedUser) {

        expect (changedUser.address, equals (updatedUser.address));
        expect (changedUser.googleAppcode, equals (updatedUser.googleAppcode));
        expect (changedUser.googleUsername, equals (updatedUser.googleUsername));
        expect (changedUser.ID, equals(updatedUser.ID));
        expect (changedUser.name, equals (updatedUser.name));
        expect (changedUser.peer, equals (updatedUser.peer));
        expect (changedUser.portrait, equals (updatedUser.portrait));

        return receptionist.waitFor(eventType: Event.Key.userChange)
                .then((Event.UserChange userChange) {
                  expect (userChange.state, equals(Event.UserObjectState.UPDATED));
                  expect (userChange.userID, equals(createdUser.ID));
                  return userStore.remove(createdUser.ID);
        }).then((_) =>
            userStore.remove(createdUser.ID));
      }));
    });

  }

  /**
   *
   */
  static Future removeUser(Storage.User userStore) {
    log.info('Checking server behaviour on an user removal.');

    return userStore.create(Randomizer.randomUser())
      .then((Model.User createdUser) {
        expect (createdUser.ID, greaterThan(Model.User.noID));

        return userStore.remove(createdUser.ID)
          .then((_) {
            expect (userStore.get(createdUser.ID),
              throwsA(new isInstanceOf<Storage.NotFound>()));
        });
    });
  }

  /**
   *
   */
  static Future removeUserEvent(Storage.User userStore,
                                Receptionist receptionist) {
    log.info('Checking server behaviour on an user removal.');

    return userStore.create(Randomizer.randomUser())
      .then((Model.User createdUser) {
        expect (createdUser.ID, greaterThan(Model.User.noID));

        return receptionist.waitFor(eventType: Event.Key.userChange)
          .then((Event.UserChange userChange) {
            expect (userChange.state, equals(Event.UserObjectState.CREATED));
            receptionist.eventStack.clear();
        })
        .then((_) => userStore.remove(createdUser.ID))
        .then((_) => receptionist.waitFor(eventType: Event.Key.userChange)
            .then((Event.UserChange userChange) {
              expect (userChange.state, equals(Event.UserObjectState.DELETED));
              expect (userChange.userID, equals(createdUser.ID));
        }));
    });
  }

  /**
   * Test server behaviour when trying to aquire a list of user objects
   *
   * The expected behaviour is that the server should return a list of
   * User objects.
   */
  static Future listUsers(Storage.User userStore) {
    log.info('Checking server behaviour on list of users.');

    return userStore.list().then((Iterable<Model.User> users) {
      expect(users, isNotNull);
      expect(users, isNotEmpty);
    });
  }

  /**
   * Test server behaviour when trying to list all available groups
   *
   * The expected behaviour is that the server should return a list of
   * UserGroup objects.
   */
  static Future listAllGroups(Storage.User userStore) {
    log.info('Looking up group list.');

    return userStore.groups().then((Iterable<Model.UserGroup> groups) {
      expect(groups, isNotNull);
      expect(groups, isNotEmpty);
    });
  }

  /**
   * Test server behaviour when trying to list all available groups
   *
   * The expected behaviour is that the server should return a list of
   * UserGroup objects.
   */
  static Future listGroupsOfUser(Storage.User userStore) {
    log.info('Looking up group list of user.');

    return userStore.userGroups(2).then((Iterable<Model.UserGroup> groups) {
      expect(groups, isNotNull);
      expect(groups, isNotEmpty);
    });
  }

  /**
   * Test server behaviour when trying to list all available groups
   *
   * The expected behaviour is that the server should return a list of
   * UserGroup objects.
   */
  static Future listGroupsOfNonExistingUser(Storage.User userStore) {
    log.info('Looking up group list of user.');

    return userStore.userGroups(-1).then((Iterable<Model.UserGroup> groups) {
      expect(groups, isNotNull);
      expect(groups, isEmpty);
    });
  }

  /**
   * Add a user to a group.
   */

  static Future joinGroup(Storage.User userStore) {
    Model.User newUser = Randomizer.randomUser();

    newUser.groups = [];

    return userStore.create(newUser).then((Model.User createdUser) {

      expect (createdUser.groups, isEmpty);

      return userStore.groups().then((Iterable<Model.UserGroup> groups) {
        Model.UserGroup addedGroup = groups.first;

        return userStore.joinGroup(createdUser.ID, addedGroup.id)
          .then((_) {
            return userStore.get(createdUser.ID).then((Model.User fetchedUser) {
              expect (fetchedUser.groups, isNotEmpty);
              expect (fetchedUser.groups, contains(addedGroup));
            });
        });
      })
      /// Finalization - cleanup.
      .then((_) => userStore.remove(createdUser.ID));
    });
  }

  /**
   * Remove a user from a group.
   */

  static Future leaveGroup(Storage.User userStore) {
    Model.User newUser = Randomizer.randomUser();

    newUser.groups = [];

    return userStore.create(newUser).then((Model.User createdUser) {

      expect (createdUser.groups, isEmpty);

      return userStore.groups().then((Iterable<Model.UserGroup> groups) {
        Model.UserGroup addedGroup = groups.first;

        return userStore.joinGroup(createdUser.ID, addedGroup.id)
          .then((_) => userStore.get(createdUser.ID)
           .then((Model.User fetchedUser) =>
               userStore.leaveGroup(createdUser.ID, addedGroup.id)
             .then((_) => userStore.get(createdUser.ID)
                .then((Model.User fetchedUser) {
                  expect (fetchedUser.groups, isEmpty);
            }))));
        })
      /// Finalization - cleanup.
      .then((_) => userStore.remove(createdUser.ID));
    });
  }

  /**
   * Add an identity to a user.
   */

  static Future addUserIdentity(Storage.User userStore) {
    Model.User newUser = Randomizer.randomUser();

    newUser.identities = [];

    return userStore.create(newUser).then((Model.User createdUser) {

      expect (createdUser.identities, isEmpty);
      Model.UserIdentity identity = new Model.UserIdentity.empty()
        ..identity =Randomizer.randomUserEmail()
        ..userId = createdUser.ID;

        return userStore.addIdentity(identity)
          .then((_) => userStore.get(createdUser.ID)
            .then((Model.User fetchedUser) {
              expect (fetchedUser.identities, isNotEmpty);
              expect (fetchedUser.identities, contains(identity));
            }))
      /// Finalization - cleanup.
      .then((_) => userStore.remove(createdUser.ID));
    });
  }
}
