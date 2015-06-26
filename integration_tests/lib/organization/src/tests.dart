part of or_test_fw;

abstract class Organization {
  static Logger log = new Logger('$libraryName.Organization');

  /**
   * Test for the presence of CORS headers.
   */
  static Future isCORSHeadersPresent(HttpClient client) {
    Uri uri = Uri.parse('${Config.organizationStoreUri}/nonexistingpath');

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
      uri = Resource.Organization.single(Config.organizationStoreUri, 1);
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
        '${Config.organizationStoreUri}/nonexistingpath?token=${Config.serverToken}');

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
   * Test server behaviour when trying to aquire a organization object that
   * does not exist.
   *
   * The expected behaviour is that the server should return a Not Found error.
   */
  static void nonExistingOrganization(Storage.Organization organizationStore) {
    log.info('Checking server behaviour on a non-existing organization.');

    return expect(organizationStore.get(-1),
        throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  /**
   * Test server behaviour when trying to aquire a organization object that
   * exists.
   *
   * The expected behaviour is that the server should return the
   * Organization object.
   */
  static void existingOrganization(Storage.Organization organizationStore) {
    const int organizationID = 1;
    log.info('Checking server behaviour on an existing organization.');

    return expect(organizationStore.get(organizationID), isNotNull);
  }

  /**
   * Test server behaviour when trying to aquire a list of organization objects
   *
   * The expected behaviour is that the server should return a list of
   * Organization objects.
   */
  static Future list(Storage.Organization organizationStore) {
    log.info('Checking server behaviour on list of organizations.');

    return organizationStore
        .list()
        .then((Iterable<Model.Organization> organizations) {
      expect(organizations, isNotNull);
      expect(organizations, isNotEmpty);
      expect(organizations.every((org) => org.id != Model.Organization.noID), isTrue);
    });
  }

  /**
   * Test server behaviour when trying to list contacts associated with
   * a given organization.
   *
   * The expected behaviour is that the server should return a list of
   * BaseContact objects.
   */
  static Future existingOrganizationContacts(
      Storage.Organization organizationStore) {
    int organizationID = 1;

    log.info('Looking up contact list for organization $organizationID.');

    return organizationStore
        .contacts(organizationID)
        .then((Iterable<Model.BaseContact> contacts) {
      expect(contacts, isNotEmpty);
      expect(contacts, isNotNull);
    });
  }

  /**
   * Test server behaviour when trying to list contacts associated with
   * a non-existing organization.
   *
   * The expected behaviour is that the server should return an empty list.
   */
  static Future nonExistingOrganizationContacts(
      Storage.Organization organizationStore) {
    int organizationID = -1;

    log.info('Looking up contact list for organization $organizationID.');

    return organizationStore
        .contacts(organizationID)
        .then((Iterable<Model.BaseContact> contacts) {
      expect(contacts, isEmpty);
      expect(contacts, isNotNull);
    });
  }

  /**
   * Test server behaviour when trying to list receptions associated with
   * a given organization.
   *
   * The expected behaviour is that the server should return a list of
   * BaseContact objects.
   */
  static Future existingOrganizationReceptions(
      Storage.Organization organizationStore) {
    int organizationID = 1;

    log.info('Looking up contact list for organization $organizationID.');

    return organizationStore
        .receptions(organizationID)
        .then((Iterable<int> receptionsIDs) {
      expect(receptionsIDs, isNotEmpty);
      expect(receptionsIDs, isNotNull);
    });
  }

  /**
   * Test server behaviour when trying to list receptions associated with
   * a non-existing organization.
   *
   * The expected behaviour is that the server should return an empty list.
   */
  static Future nonExistingOrganizationReceptions(
      Storage.Organization organizationStore) {
    int organizationID = -1;

    log.info('Looking up contact list for organization $organizationID.');

    return organizationStore
        .receptions(organizationID)
        .then((Iterable<int> receptionsIDs) {
      expect(receptionsIDs, isEmpty);
      expect(receptionsIDs, isNotNull);
    });
  }

  /**
   * Test server behaviour when trying to create a new empty organization
   * which is invalid.
   *
   * The expected behaviour is that the server should return an error.
   */
  static void createEmpty(Storage.Organization organizationStore) {

    Model.Organization organization = new Model.Organization.empty();

    log.info('Creating a new empty/invalid organization ${organization.asMap}');

    return expect(organizationStore.create(organization),
        throwsA(new isInstanceOf<Storage.ServerError>()));
  }

  /**
   * Test server behaviour when trying to create a new organization.
   *
   * The expected behaviour is that the server should return the created
   * Organization object.
   */
  static Future create(Storage.Organization organizationStore) {

    Model.Organization organization = Randomizer.randomOrganization();

    log.info('Creating a new organization ${organization.asMap}');

    return organizationStore
        .create(organization)
        .then((Model.Organization createdOrganization) {
      expect(createdOrganization.id, greaterThan(Model.Organization.noID));

      expect(organization.billingType, createdOrganization.billingType);
      expect(organization.flag, createdOrganization.flag);
      expect(organization.fullName, createdOrganization.fullName);
    });
  }

  /**
   * Test server behaviour when trying to update a organization event object that
   * exists.
   *
   * The expected behaviour is that the server should return the updated
   * Organization object.
   */
  static Future update(Storage.Organization organizationStore) {
    return organizationStore.list().then((Iterable<Model.Organization> orgs) {

      // Update the last event in list.
      Model.Organization organization = orgs.last;

      log.info('Got organization ${organization.asMap}');
      {
        Model.Organization randOrg = Randomizer.randomOrganization();
        log.info('Updating with info ${randOrg.asMap}');

        organization.flag = randOrg.flag;
        organization.fullName = randOrg.fullName;
        organization.billingType = randOrg.billingType;
      }
      return organizationStore
          .update(organization)
          .then((Model.Organization updatedOrganization) {
        expect(updatedOrganization.id, greaterThan(Model.Organization.noID));

        expect(organization.billingType, updatedOrganization.billingType);
        expect(organization.flag, updatedOrganization.flag);
        expect(organization.fullName, updatedOrganization.fullName);
      });
    });
  }

  /**
   * Test server behaviour when trying to update a organization object that
   * exists but with invalid data.
   *
   * The expected behaviour is that the server should return an error,
   */
  static Future updateInvalid(Storage.Organization organizationStore) {
    return organizationStore.list().then((Iterable<Model.Organization> orgs) {

      // Update the last event in list.
      Model.Organization organization = orgs.last;

      log.info('Got organization ${organization.asMap}');
      organization.fullName = null;
      return expect(organizationStore.update(organization),
              throwsA(new isInstanceOf<Storage.ServerError>()));
    });
  }

  /**
   * Test server behaviour when trying to delete an organization that exists.
   *
   * The expected behaviour is that the server should succeed.
   */
  static Future remove(Storage.Organization organizationStore) {
    return organizationStore.list().then((Iterable<Model.Organization> orgs) {

      // Update the last event in list.
      Model.Organization org = orgs.last;

      log.info('Targeting organization for removal: ${org.asMap}');

      return organizationStore.remove(org.id).then((_) {
        return expect(organizationStore.get(org.id),
            throwsA(new isInstanceOf<Storage.NotFound>()));
      });
    });
  }

  /**
   * Test server behaviour when trying to delete an organization that
   * do not exists.
   *
   * The expected behaviour is that the server should return Not Found error.
   */
  static void removeNonExisting(Storage.Organization organizationStore) {
      const int NonExistingOrganizationId = -1;

      log.info('Targeting organization for removal. Id: ${NonExistingOrganizationId}');

      return expect(organizationStore.remove(NonExistingOrganizationId),
          throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  /**
   * Test server behaviour when trying to create a new organization.
   *
   * The expected behaviour is that the server should return the created
   * Organization object and send out a OrganizationChange notification.
   */
  static Future createEvent(
      Storage.Organization organizationStore, Receptionist receptionist) {
    Model.Organization organization = Randomizer.randomOrganization();
    log.info('Creating a new organization ${organization.asMap}');

    return organizationStore
        .create(organization)
        .then((Model.Organization createdOrganization) {
      expect(createdOrganization.id, greaterThan(Model.Organization.noID));

      expect(organization.billingType, createdOrganization.billingType);
      expect(organization.flag, createdOrganization.flag);
      expect(organization.fullName, createdOrganization.fullName);
      return receptionist
          .waitFor(eventType: Event.Key.organizationChange)
          .then((Event.OrganizationChange event) {
        expect(event.orgID, equals(createdOrganization.id));
        expect(event.state, equals(Event.OrganizationState.CREATED));
      });
    });
  }

  /**
   * Test server behaviour when trying to update an organization.
   *
   * The expected behaviour is that the server should return the created
   * Organization object and send out a OrganizationChange notification.
   */
  static Future updateEvent(
      Storage.Organization organizationStore, Receptionist receptionist) {
    return organizationStore.list().then((Iterable<Model.Organization> orgs) {

      // Update the last event in list.
      Model.Organization organization = orgs.last;

      log.info('Got organization ${organization.asMap}');
      {
        Model.Organization randOrg = Randomizer.randomOrganization();
        log.info('Updating with info ${randOrg.asMap}');

        organization.flag = randOrg.flag;
        organization.fullName = randOrg.fullName;
        organization.billingType = randOrg.billingType;
      }
      return organizationStore
          .update(organization)
          .then((Model.Organization updatedOrganization) {
        expect(updatedOrganization.id, greaterThan(Model.Organization.noID));

        expect(organization.billingType, updatedOrganization.billingType);
        expect(organization.flag, updatedOrganization.flag);
        expect(organization.fullName, updatedOrganization.fullName);

        return receptionist
            .waitFor(eventType: Event.Key.organizationChange)
            .then((Event.OrganizationChange event) {
          expect(event.orgID, equals(updatedOrganization.id));
          expect(event.state, equals(Event.OrganizationState.UPDATED));
        });
      });
    });
  }

  /**
   * Test server behaviour when trying to delete an organization.
   *
   * The expected behaviour is that the server should return the created
   * Organization object and send out a OrganizationChange notification.
   */
  static Future deleteEvent(
      Storage.Organization organizationStore, Receptionist receptionist) {
    return organizationStore.list().then((Iterable<Model.Organization> orgs) {

      // Update the last event in list.
      Model.Organization org = orgs.last;

      log.info('Targeting organization for removal: ${org.asMap}');

      return organizationStore.remove(org.id).then((_) {
        return receptionist
            .waitFor(eventType: Event.Key.organizationChange)
            .then((Event.OrganizationChange event) {
          expect(event.orgID, equals(org.id));
          expect(event.state, equals(Event.OrganizationState.DELETED));
        });
      });
    });
  }
}
