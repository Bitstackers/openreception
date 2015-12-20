part of or_test_fw;

abstract class ContactStore {
  ///TODO: Rename logger
  static final Logger log = new Logger('$libraryName.ContactStore');

  /**
   * Test for the presence of CORS headers.
   */
  static Future isCORSHeadersPresent(HttpClient client) {
    Uri uri = Uri.parse('${Config.contactStoreUri}/nonexistingpath');

    log.info('Checking CORS headers on a non-existing URL.');
    return client
        .getUrl(uri)
        .then((HttpClientRequest request) =>
            request.close().then((HttpClientResponse response) {
              if (response.headers['access-control-allow-origin'] == null &&
                  response.headers['Access-Control-Allow-Origin'] == null) {
                fail('No CORS headers on path $uri');
              }
            }))
        .then((_) {
      log.info('Checking CORS headers on an existing URL.');
      uri = Resource.Reception.single(Config.contactStoreUri, 1);
      return client.getUrl(uri).then((HttpClientRequest request) =>
          request.close().then((HttpClientResponse response) {
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
        '${Config.contactStoreUri}/nonexistingpath?token=${Config.serverToken}');

    log.info('Checking server behaviour on a non-existing path.');

    return client
        .getUrl(uri)
        .then((HttpClientRequest request) =>
            request.close().then((HttpClientResponse response) {
              if (response.statusCode != 404) {
                fail('Expected to received a 404 on path $uri');
              }
            }))
        .then((_) => log.info('Got expected status code 404.'))
        .whenComplete(() => client.close(force: true));
  }

  /**
   * Test server behaviour when trying to aquire a contact object that
   * does not exist.
   *
   * The expected behaviour is that the server should return a Not Found error.
   */
  static void nonExistingContact(Storage.Contact contactStore) {
    log.info('Checking server behaviour on a non-existing contact.');

    return expect(
        contactStore.get(-1), throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  /**
   * Test server behaviour when trying to aquire a list of contact objects from
   * a reception.
   *
   * The expected behaviour is that the server should return a list of
   * contact objects.
   */
  static Future listByReception(Storage.Contact contactStore) {
    const int receptionID = 1;
    log.info(
        'Checking server behaviour on list of contacts in reception $receptionID.');

    return contactStore
        .listByReception(receptionID)
        .then((Iterable<Model.Contact> contacts) {
      expect(contacts, isNotNull);
      expect(contacts, isNotEmpty);
    });
  }

  /**
   * Test server behaviour when trying to aquire a list of base contact objects.
   *
   * The expected behaviour is that the server should return a list of
   * base contact objects.
   */
  static Future list(Storage.Contact contactStore) {
    log.info('Checking server behaviour on list of base contacts.');

    return contactStore.list().then((Iterable<Model.BaseContact> contacts) {
      expect(contacts, isNotNull);
      expect(contacts, isNotEmpty);
    });
  }

  /**
   *
   */
  static Future receptions(Storage.Contact contactStore) {
    return contactStore.receptions(1).then((Iterable<int> receptions) {
      expect(receptions, isNotNull);
    });
  }

  /**
   *
   */
  static Future organizations(Storage.Contact contactStore) {
    return contactStore.organizations(1).then((Iterable<int> organizations) {
      expect(organizations, isNotNull);
    });
  }

  /**
   *
   */
  static Future organizationContacts(Storage.Contact contactStore) {
    return contactStore
        .organizationContacts(1)
        .then((Iterable<Model.BaseContact> contacts) {
      expect(contacts, isNotNull);
      expect(contacts, isNotEmpty);
    });
  }

  /**
   *
   */
  static Future getByReception(Storage.Contact contactStore) {
    return contactStore.getByReception(1, 1).then((Model.Contact contact) {
      expect(contact, isNotNull);
    });
  }

  /**
   * Test server behaviour when trying to aquire a list of base contact objects.
   *
   * The expected behaviour is that the server should return a list of
   * base contact objects.
   */
  static Future get(Storage.Contact contactStore) {
    log.info('Checking server behaviour on list of base contacts.');

    Model.BaseContact contact = Randomizer.randomBaseContact();

    log.info('Creating a new base contact.');

    return contactStore.create(contact).then(
        (Model.BaseContact createdContact) => contactStore
                .get(createdContact.id)
                .then((Model.BaseContact contact) {
              expect(contact, isNotNull);
            }).then((_) => contactStore.remove(createdContact.id)));
  }

  /**
   * Test server behaviour when trying to aquire a list of contact objects from
   * a non existing reception.
   *
   * The expected behaviour is that the server should return an empty list.
   */
  static Future listContactsByNonExistingReception(
      Storage.Contact contactStore) {
    const int receptionID = -1;
    log.info(
        'Checking server behaviour on list of contacts in reception $receptionID.');

    return contactStore
        .listByReception(receptionID)
        .then((Iterable<Model.Contact> contacts) {
      expect(contacts, isEmpty);
    });
  }

  /**
   * Test server behaviour when trying to create a new base contact object is
   * created.
   * The expected behaviour is that the server should return the created
   * BaseContact object.
   */
  static Future create(Storage.Contact contactStore) {
    Model.BaseContact contact = Randomizer.randomBaseContact();

    log.info('Creating a new base contact.');

    return contactStore
        .create(contact)
        .then((Model.BaseContact createdContact) {
      expect(createdContact.id, isNot(Model.Contact.noID));
      expect(createdContact.id, isNotNull);

      expect(contact.contactType, equals(createdContact.contactType));
      expect(contact.fullName, equals(createdContact.fullName));
      expect(contact.enabled, equals(createdContact.enabled));

      return contactStore.remove(createdContact.id);
    });
  }

  /**
   * Test server behaviour when trying to delete a base contact object that
   * exists.
   *
   * The expected behaviour is that the server should succeed.
   */
  static Future remove(Storage.Contact contactStore) {
    Model.BaseContact contact = Randomizer.randomBaseContact();

    return contactStore
        .create(contact)
        .then((Model.BaseContact createdContact) {
      log.info('Got contact ${createdContact.asMap}. Deleting it.');

      return contactStore.remove(createdContact.id).then((_) => expect(
          contactStore.get(contact.id),
          throwsA(new isInstanceOf<Storage.NotFound>())));
    });
  }

  /**
   * Test server behaviour when trying to update an existingbase contact.
   * The expected behaviour is that the server should return the updated
   * BaseContact object.
   */
  static Future update(Storage.Contact contactStore) {
    Model.BaseContact contact = Randomizer.randomBaseContact();

    return contactStore
        .create(contact)
        .then((Model.BaseContact createdContact) {
      log.info('Got event ${createdContact.asMap}. Updating local info');

      {
        Model.BaseContact randBC = Randomizer.randomBaseContact();
        randBC.id = createdContact.id;
        createdContact = randBC;
      }

      log.info('Updating local info to ${createdContact.asMap}');

      return contactStore
          .update(createdContact)
          .then((Model.BaseContact updatedContact) {
        expect(updatedContact.id, isNot(Model.Contact.noID));
        expect(updatedContact.id, isNotNull);

        expect(createdContact.contactType, equals(updatedContact.contactType));
        expect(createdContact.fullName, equals(updatedContact.fullName));
        expect(createdContact.enabled, equals(updatedContact.enabled));

        return contactStore.remove(createdContact.id);
      });
    });
  }

  /**
   * Test server behaviour when trying to retrieve an endpoint list of a
   * contact.
   *
   * The expected behaviour is that the server should succeed.
   */
  static Future endpoints(Storage.Endpoint endpointStore) {
    int receptionID = 1;
    int contactID = 4;

    return endpointStore
        .list(receptionID, contactID)
        .then((Iterable<Model.MessageEndpoint> endpoints) {
      expect(endpoints, isNotNull);

      expect(
          endpoints
              .every((Model.MessageEndpoint ep) => ep is Model.MessageEndpoint),
          isTrue);
    });
  }

  /**
   *
   */
  static Future endpointCreate(Storage.Endpoint endpointStore) {
    int receptionID = 1;
    int contactID = 1;

    Model.MessageEndpoint ep = Randomizer.randomMessageEndpoint();

    return endpointStore
        .create(receptionID, contactID, ep)
        .then((Model.MessageEndpoint createdEntry) {
      expect(createdEntry.address, equals(ep.address));
      expect(createdEntry.confidential, equals(ep.confidential));
      expect(createdEntry.description, equals(ep.description));
      expect(createdEntry.enabled, equals(ep.enabled));
      expect(createdEntry.type, equals(ep.type));

      return endpointStore.remove(createdEntry.id);
    });
  }

  /**
   *
   */
  static Future endpointRemove(Storage.Endpoint endpointStore) {
    int receptionID = 1;
    int contactID = 4;

    Model.MessageEndpoint ep = Randomizer.randomMessageEndpoint();

    return endpointStore
        .create(receptionID, contactID, ep)
        .then((Model.MessageEndpoint createdEndpoint) {
      return endpointStore.remove(createdEndpoint.id).then((_) => endpointStore
              .list(receptionID, contactID)
              .then((Iterable<Model.MessageEndpoint> endpoints) {
            if (endpoints.contains(ep)) {
              fail('endpoint $ep not removed.');
            }
          }));
    });
  }

  /**
   *
   */
  static Future endpointUpdate(Storage.Endpoint endpointStore) {
    int receptionID = 1;
    int contactID = 4;

    Model.MessageEndpoint ep = Randomizer.randomMessageEndpoint();

    return endpointStore
        .create(receptionID, contactID, ep)
        .then((Model.MessageEndpoint createdEndpoint) {
      Model.MessageEndpoint newEp = Randomizer.randomMessageEndpoint();
      newEp.id = createdEndpoint.id;

      log.info(newEp.asMap);

      return endpointStore
          .update(newEp)
          .then((_) => endpointStore
                  .list(receptionID, contactID)
                  .then((Iterable<Model.MessageEndpoint> endpoints) {
                log.info(endpoints);
                log.info(endpoints);
                expect(endpoints.contains(newEp), isTrue);
              }))
          .then((_) => endpointStore.remove(createdEndpoint.id));
    });
  }

  /**
   * Test server behaviour when trying to retrieve an phone list of a
   * contact.
   *
   * The expected behaviour is that the server should succeed.
   */
  static Future phones(Storage.Contact contactStore) {
    int receptionID = 1;
    int contactID = 4;

    return contactStore
        .phones(contactID, receptionID)
        .then((Iterable<Model.PhoneNumber> endpoints) {
      expect(endpoints, isNotNull);
    });
  }

  /**
   *
   */
  static Future distributionList(Storage.DistributionList dlistStore) {
    int receptionID = 1;
    int contactID = 4;

    return dlistStore
        .list(receptionID, contactID)
        .then((Iterable<Model.DistributionListEntry> endpoints) {
      expect(endpoints, isNotNull);
      log.fine(endpoints);

      expect(
          endpoints.every((Model.DistributionListEntry mr) =>
              mr is Model.DistributionListEntry),
          isTrue);
    });
  }

  /**
   *
   */
  static Future distributionRecipientAdd(Storage.DistributionList dlistStore) {
    int receptionID = 1;
    int contactID = 1;

    Model.DistributionListEntry rcp = Randomizer.randomDistributionListEntry()
      ..contactID = 1
      ..receptionID = 3;

    return dlistStore
        .addRecipient(receptionID, contactID, rcp)
        .then((Model.DistributionListEntry createdRecipient) {
      expect(createdRecipient.contactID, equals(rcp.contactID));
      expect(createdRecipient.contactName, equals(rcp.contactName));
      expect(createdRecipient.receptionID, equals(rcp.receptionID));
      expect(createdRecipient.receptionName, equals(rcp.receptionName));
      expect(
          createdRecipient.id, greaterThan(Model.DistributionListEntry.noId));

      return dlistStore
          .list(receptionID, contactID)
          .then((Model.DistributionList dlist) {
        expect(dlist.contains(createdRecipient), isTrue);
      }).then((_) => dlistStore.removeRecipient(createdRecipient.id));
    });
  }

  /**
   *
   */
  static Future distributionRecipientRemove(
      Storage.DistributionList dlistStore) {
    int receptionID = 1;
    int contactID = 1;

    Model.DistributionListEntry rcp = Randomizer.randomDistributionListEntry()
      ..contactID = 1
      ..receptionID = 3;

    return dlistStore
        .addRecipient(receptionID, contactID, rcp)
        .then((Model.DistributionListEntry createdRecipient) {
      return dlistStore.removeRecipient(createdRecipient.id).then((_) =>
          dlistStore
              .list(receptionID, contactID)
              .then((Model.DistributionList dlist) {
            if (dlist.contains(rcp)) {
              fail('endpoint $rcp not removed.');
            }
          }));
    });
  }

  /**
   *
   */
  static Future addToReception(Storage.Contact contactStore) {
    Model.BaseContact contact = Randomizer.randomBaseContact();

    log.info('Creating a new base contact.');

    return contactStore
        .create(contact)
        .then((Model.BaseContact createdBaseContact) {
      Model.Contact contact = Randomizer.randomContact()
        ..ID = createdBaseContact.id;

      return contactStore
          .addToReception(contact, 1)
          .then((_) => contactStore.removeFromReception(contact.ID, 1));
    });
  }

  /**
   *
   */
  static Future updateInReception(Storage.Contact contactStore) {
    Model.BaseContact contact = Randomizer.randomBaseContact();

    log.info('Creating a new base contact.');

    return contactStore
        .create(contact)
        .then((Model.BaseContact createdBaseContact) {
      Model.Contact contact = Randomizer.randomContact()
        ..ID = createdBaseContact.id;

      return contactStore
          .addToReception(contact, 1)
          .then((Model.Contact updatedContact) =>
              contactStore.updateInReception(updatedContact))
          .then((_) => contactStore.removeFromReception(contact.ID, 1));
    });
  }

  /**
   *
   */
  static Future deleteFromReception(Storage.Contact contactStore) {
    Model.BaseContact contact = Randomizer.randomBaseContact();

    log.info('Creating a new base contact.');

    return contactStore
        .create(contact)
        .then((Model.BaseContact createdBaseContact) {
      Model.Contact contact = Randomizer.randomContact()
        ..ID = createdBaseContact.id;

      return contactStore
          .addToReception(contact, 1)
          .then((_) => contactStore.removeFromReception(contact.ID, 1));
    });
  }
}
