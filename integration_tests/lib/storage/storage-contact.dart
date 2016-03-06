part of openreception_tests.storage;

abstract class Contact {
  static final Logger _log = new Logger('$_libraryName.ContactStore');

  /**
   * Test server behaviour when trying to aquire a contact object that
   * does not exist.
   *
   * The expected behaviour is that the server should return a Not Found error.
   */
  static Future nonExistingContact(ServiceAgent sa) async {
    _log.info('Checking server behaviour on a non-existing contact.');

    await expect(
        sa.contactStore.get(-1), throwsA(new isInstanceOf<storage.NotFound>()));
  }

  /**
   * Test server behaviour when trying to aquire a list of contact objects from
   * a reception.
   *
   * The expected behaviour is that the server should return a list of
   * contact objects.
   */
  static Future listByReception(ServiceAgent sa) async {
    final con1 = await sa.createsContact();
    final con2 = await sa.createsContact();
    final con3 = await sa.createsContact();
    final con4 = await sa.createsContact();

    final org1 = await sa.createsOrganization();
    final org2 = await sa.createsOrganization();

    final rec1 = await sa.createsReception(org1);
    final rec2 = await sa.createsReception(org2);

    await sa.addsContactToReception(con1, rec1);
    await sa.addsContactToReception(con2, rec1);
    await sa.addsContactToReception(con3, rec1);
    await sa.addsContactToReception(con4, rec2);

    final Iterable<model.ContactReference> cRefs1 =
        await sa.contactStore.receptionContacts(rec1.id);

    final Iterable<model.ContactReference> cRefs2 =
        await sa.contactStore.receptionContacts(rec2.id);

    _log.finest('Fetched 1: ' + cRefs1.map((cref) => cref.id).join(', '));
    _log.finest('Fetched 2: ' + cRefs2.map((cref) => cref.id).join(', '));

    expect(cRefs1.length, equals(3));
    expect(cRefs2.length, equals(1));

    expect(cRefs1.any((ref) => ref.id == con1.id), isTrue);
    expect(cRefs1.any((ref) => ref.id == con2.id), isTrue);
    expect(cRefs1.any((ref) => ref.id == con3.id), isTrue);
    expect(cRefs1.any((ref) => ref.id == con4.id), isFalse);
    expect(cRefs2.any((ref) => ref.id == con1.id), isFalse);
    expect(cRefs2.any((ref) => ref.id == con2.id), isFalse);
    expect(cRefs2.any((ref) => ref.id == con3.id), isFalse);
    expect(cRefs2.any((ref) => ref.id == con4.id), isTrue);
  }

  /**
   * Test server behaviour when trying to aquire a list of base contact objects.
   *
   * The expected behaviour is that the server should return a list of
   * base contact objects.
   */
  static Future list(ServiceAgent sa) async {
    _log.info('Checking server behaviour on list of base contacts.');

    final con1 = await sa.createsContact();
    final con2 = await sa.createsContact();
    final con3 = await sa.createsContact();
    final con4 = await sa.createsContact();

    final Iterable<model.ContactReference> crefs = await sa.contactStore.list();

    _log.finest('Contact 1: ${con1.id}');
    _log.finest('Contact 2: ${con2.id}');
    _log.finest('Contact 3: ${con3.id}');
    _log.finest('Contact 4: ${con4.id}');
    _log.finest('Fetched: ' + crefs.map((cref) => cref.id).join(', '));
    expect(crefs.length, equals(4));

    expect(crefs.any((ref) => ref.id == con1.id), isTrue);
    expect(crefs.any((ref) => ref.id == con2.id), isTrue);
    expect(crefs.any((ref) => ref.id == con3.id), isTrue);
    expect(crefs.any((ref) => ref.id == con4.id), isTrue);
  }

  /**
   *
   */
  static Future receptions(ServiceAgent sa) async {
    final con = await sa.createsContact();

    final org1 = await sa.createsOrganization();
    final org2 = await sa.createsOrganization();

    final rec1 = await sa.createsReception(org1);
    final rec2 = await sa.createsReception(org2);

    await sa.addsContactToReception(con, rec1);
    await sa.addsContactToReception(con, rec2);

    Iterable<model.ReceptionReference> rRefs =
        await sa.contactStore.receptions(con.id);

    _log.finest('Reception 1: ${rec1.id}');
    _log.finest('Reception 2: ${rec2.id}');
    _log.finest('Fetched: ' + rRefs.map((cref) => cref.id).join(', '));
    expect(rRefs.length, equals(2));

    expect(rRefs.any((ref) => ref.id == rec1.id), isTrue);
    expect(rRefs.any((ref) => ref.id == rec2.id), isTrue);
  }

  /**
   *
   */
  static Future organizations(ServiceAgent sa) async {
    final con = await sa.createsContact();

    final org1 = await sa.createsOrganization();
    final org2 = await sa.createsOrganization();

    final rec1 = await sa.createsReception(org1);
    final rec2 = await sa.createsReception(org2);

    await sa.addsContactToReception(con, rec1);
    await sa.addsContactToReception(con, rec2);

    Iterable<model.ReceptionReference> rRefs =
        await sa.contactStore.receptions(con.id);
    expect(rRefs.length, equals(2));

    Iterable<model.OrganizationReference> oRefs =
        await sa.contactStore.organizations(con.id);

    _log.finest('Organization 1: ${org1.id}');
    _log.finest('Organization 2: ${org2.id}');
    _log.finest('Fetched: ' + oRefs.map((cref) => cref.id).join(', '));
    expect(oRefs.length, equals(2));

    expect(oRefs.any((cref) => cref.id == org1.id), isTrue);
    expect(oRefs.any((cref) => cref.id == org2.id), isTrue);
  }

  /**
   *
   */
  static Future organizationContacts(ServiceAgent sa) async {
    final org = await sa.createsOrganization();
    final rec1 = await sa.createsReception(org);
    final con1 = await sa.createsContact();

    final rec2 = await sa.createsReception(org);
    final con2 = await sa.createsContact();

    await sa.addsContactToReception(con1, rec1);
    await sa.addsContactToReception(con2, rec2);

    Iterable<model.ContactReference> cRefs =
        await sa.contactStore.organizationContacts(org.id);

    _log.finest('Contact 1: ${con1.id}');
    _log.finest('Contact 2: ${con2.id}');
    _log.finest('Fetched: ' + cRefs.map((cref) => cref.id).join(', '));
    expect(cRefs.length, equals(2));

    expect(cRefs.any((cref) => cref.id == con1.id), isTrue);
    expect(cRefs.any((cref) => cref.id == con2.id), isTrue);
  }

  /**
   *
   */
  static Future getByReception(ServiceAgent sa) async {
    _log.info('Setting up reception data');

    final org = await sa.createsOrganization();
    final rec = await sa.createsReception(org);
    final con = await sa.createsContact();

    await sa.addsContactToReception(con, rec);

    final model.ReceptionAttributes contact =
        await sa.contactStore.data(con.id, rec.id);
    expect(contact, isNotNull);
  }

  /**
   * Test server behaviour when trying to aquire a list of base contact objects.
   *
   * The expected behaviour is that the server should return a list of
   * base contact objects.
   */
  static Future get(ServiceAgent sa) async {
    _log.info('Creating a new base contact.');

    final contact = Randomizer.randomBaseContact();
    contact.id = (await sa.createsContact(contact: contact)).id;
    final fetched = await sa.contactStore.get(contact.id);

    expect(contact.id, equals(fetched.id));
    expect(contact.contactType, equals(fetched.contactType));
    expect(contact.enabled, equals(fetched.enabled));
    expect(contact.name, equals(fetched.name));
    expect(contact.reference.toJson(), equals(fetched.reference.toJson()));
    expect(contact.toJson(), equals(fetched.toJson()));
  }

  /**
   * Test server behaviour when trying to aquire a list of contact objects from
   * a non existing reception.
   *
   * The expected behaviour is that the server should return an empty list.
   */
  static Future listContactsByNonExistingReception(ServiceAgent sa) async {
    const int receptionId = -1;
    _log.info(
        'Checking server behaviour on list of contacts in reception $receptionId.');

    final Iterable<model.ContactReference> contacts =
        await sa.contactStore.receptionContacts(receptionId);

    expect(contacts, isEmpty);
  }

  /**
   * Test server behaviour when trying to create a new base contact object is
   * created.
   * The expected behaviour is that the server should return the created
   * BaseContact object.
   */
  static Future create(ServiceAgent sa) async {
    _log.info('Creating a new base contact.');

    final contact = Randomizer.randomBaseContact();
    final ref = await sa.contactStore.create(contact, sa.user);
    contact.id = ref.id;
    final fetched = await sa.contactStore.get(ref.id);

    expect(contact.id, equals(fetched.id));
    expect(contact.contactType, equals(fetched.contactType));
    expect(contact.enabled, equals(fetched.enabled));
    expect(contact.name, equals(fetched.name));
    expect(contact.reference.toJson(), equals(fetched.reference.toJson()));
    expect(contact.toJson(), equals(fetched.toJson()));
  }

  /**
   * Test server behaviour when trying to delete a base contact object that
   * exists.
   *
   * The expected behaviour is that the server should succeed.
   */
  static Future remove(ServiceAgent sa) async {
    final model.BaseContact contact = Randomizer.randomBaseContact();

    final ref = await sa.contactStore.create(contact, sa.user);
    final fetched = await sa.contactStore.get(ref.id);

    _log.info('Got contact ${fetched.toJson()}. Deleting it.');

    await sa.contactStore.remove(ref.id, sa.user);

    try {
      await sa.contactStore.get(ref.id);
      fail('expected storage.NotFound ');
    } on storage.NotFound {
      // Success!
    }
  }

  /**
   * Test server behaviour when trying to update an existingbase contact.
   * The expected behaviour is that the server should return the updated
   * BaseContact object.
   */
  static Future update(ServiceAgent sa) async {
    final model.BaseContact contact = Randomizer.randomBaseContact();
    final ref = await sa.contactStore.create(contact, sa.user);

    _log.info('Got event ${contact.toJson()}. Updating local info');

    final model.BaseContact updated = Randomizer.randomBaseContact()
      ..id = ref.id;

    _log.info('Updating local info to ${contact.toJson()}');

    await sa.contactStore.update(updated, sa.user);

    final fetched = await sa.contactStore.get(ref.id);

    expect(ref.id, equals(fetched.id));
    expect(updated.id, equals(fetched.id));
    expect(updated.contactType, equals(fetched.contactType));
    expect(updated.enabled, equals(fetched.enabled));
    expect(updated.name, equals(fetched.name));
    expect(updated.reference.toJson(), equals(fetched.reference.toJson()));
    expect(updated.toJson(), equals(fetched.toJson()));
  }

  /**
   * Test server behaviour when trying to retrieve an endpoint list of a
   * contact.
   *
   * The expected behaviour is that the server should succeed.
   */
  static Future endpoints(ServiceAgent sa) async {
    _log.info('Setting up reception data');

    final org = await sa.createsOrganization();
    final rec = await sa.createsReception(org);
    final con = await sa.createsContact();

    await sa.addsContactToReception(con, rec);

    final model.ReceptionAttributes contact =
        await sa.contactStore.data(con.id, rec.id);
    expect(contact.endpoints, isNotEmpty);
  }

  /**
   *
   */
  static Future endpointCreate(ServiceAgent sa) async {
    _log.info('Setting up reception data');

    final org = await sa.createsOrganization();
    final rec = await sa.createsReception(org);
    final con = await sa.createsContact();

    await sa.addsContactToReception(con, rec);

    final model.ReceptionAttributes attr =
        await sa.contactStore.data(con.id, rec.id);

    final eps = [
      Randomizer.randomMessageEndpoint(),
      Randomizer.randomMessageEndpoint()
    ];

    attr.endpoints = eps;

    await sa.contactStore.updateData(attr, sa.user);

    final model.ReceptionAttributes attrUpdated =
        await sa.contactStore.data(con.id, rec.id);

    expect(attrUpdated.endpoints.toList(), equals(eps.toList()));
  }

  /**
   *
   */
  static Future endpointRemove(ServiceAgent sa) async {
    _log.info('Setting up reception data');

    final org = await sa.createsOrganization();
    final rec = await sa.createsReception(org);
    final con = await sa.createsContact();

    await sa.addsContactToReception(con, rec);

    final model.ReceptionAttributes attr =
        await sa.contactStore.data(con.id, rec.id);

    final eps = [
      Randomizer.randomMessageEndpoint(),
      Randomizer.randomMessageEndpoint()
    ];

    attr.endpoints = eps;

    await sa.contactStore.updateData(attr, sa.user);

    model.ReceptionAttributes attrUpdated =
        await sa.contactStore.data(con.id, rec.id);

    expect(attrUpdated.endpoints.toList(), equals(eps.toList()));

    attr.endpoints = eps..removeLast();

    await sa.contactStore.updateData(attr, sa.user);

    attrUpdated = await sa.contactStore.data(con.id, rec.id);

    expect(attrUpdated.endpoints.toList(), equals(eps.toList()));

    attr.endpoints = [];

    await sa.contactStore.updateData(attr, sa.user);

    attrUpdated = await sa.contactStore.data(con.id, rec.id);

    expect(attrUpdated.endpoints, equals([]));
  }

  /**
   *
   */
  static Future endpointUpdate(ServiceAgent sa) async {
    _log.info('Setting up reception data');

    final org = await sa.createsOrganization();
    final rec = await sa.createsReception(org);
    final con = await sa.createsContact();

    await sa.addsContactToReception(con, rec);

    final model.ReceptionAttributes attr =
        await sa.contactStore.data(con.id, rec.id);

    final eps = attr.endpoints
      ..addAll([
        Randomizer.randomMessageEndpoint(),
        Randomizer.randomMessageEndpoint()
      ]);

    await sa.contactStore.updateData(attr, sa.user);

    final model.ReceptionAttributes attrUpdated =
        await sa.contactStore.data(con.id, rec.id);

    expect(attrUpdated.endpoints.toList(), equals(eps.toList()));
  }

  /**
   * Test server behaviour when trying to retrieve an phone list of a
   * contact.
   *
   * The expected behaviour is that the server should succeed.
   */
  static Future phones(ServiceAgent sa) async {
    _log.info('Setting up reception data');

    final org = await sa.createsOrganization();
    final rec = await sa.createsReception(org);
    final con = await sa.createsContact();

    await sa.addsContactToReception(con, rec);

    final model.ReceptionAttributes attr =
        await sa.contactStore.data(con.id, rec.id);

    final phones = [Randomizer.randomPhone(), Randomizer.randomPhone()];

    attr.phones = phones;

    await sa.contactStore.updateData(attr, sa.user);

    final model.ReceptionAttributes attrUpdated =
        await sa.contactStore.data(con.id, rec.id);

    expect(attrUpdated.phones.toList(), equals(phones.toList()));
  }

  /**
   *
   */
  static Future addToReception(ServiceAgent sa) async {
    final con = await sa.createsContact();

    final org = await sa.createsOrganization();
    final rec = await sa.createsReception(org);

    Iterable<model.ContactReference> rRefs =
        await sa.contactStore.receptionContacts(rec.id);

    expect(rRefs.length, equals(0));

    final attr = Randomizer.randomAttributes()
      ..contactId = con.id
      ..receptionId = rec.id;

    final ref = await sa.contactStore.addData(attr, sa.user);
    expect(ref.contact.id, equals(con.id));
    expect(ref.reception.id, equals(rec.id));
    final fetched = await sa.contactStore.data(con.id, rec.id);

    expect(attr.toJson(), equals(fetched.toJson()));
  }

  /**
   *
   */
  static Future updateInReception(ServiceAgent sa) async {
    final con = await sa.createsContact();

    final org = await sa.createsOrganization();
    final rec = await sa.createsReception(org);

    Iterable<model.ContactReference> cRefs =
        await sa.contactStore.receptionContacts(rec.id);

    expect(cRefs.length, equals(0));

    final attr = Randomizer.randomAttributes()
      ..contactId = con.id
      ..receptionId = rec.id;

    {
      final ref = await sa.contactStore.addData(attr, sa.user);
      expect(ref.contact.id, equals(con.id));
      expect(ref.reception.id, equals(rec.id));
      final fetched = await sa.contactStore.data(con.id, rec.id);

      expect(attr.toJson(), equals(fetched.toJson()));
    }

    final updated = Randomizer.randomAttributes()
      ..contactId = con.id
      ..receptionId = rec.id;

    {
      final ref = await sa.contactStore.updateData(updated, sa.user);
      expect(ref.contact.id, equals(con.id));
      expect(ref.reception.id, equals(rec.id));
      final fetched = await sa.contactStore.data(con.id, rec.id);

      expect(updated.toJson(), equals(fetched.toJson()));
    }
  }

  /**
   *
   */
  static Future deleteFromReception(ServiceAgent sa) async {
    final con1 = await sa.createsContact();
    final con2 = await sa.createsContact();

    final org = await sa.createsOrganization();
    final rec = await sa.createsReception(org);

    await sa.addsContactToReception(con1, rec);
    await sa.addsContactToReception(con2, rec);

    Iterable<model.ContactReference> cRefs =
        await sa.contactStore.receptionContacts(rec.id);

    _log.finest('Fetched: ' + cRefs.map((cref) => cref.toJson()).join(', '));
    expect(cRefs.length, equals(2));

    expect(cRefs.any((ref) => ref.id == con1.id), isTrue);
    expect(cRefs.any((ref) => ref.id == con2.id), isTrue);

    await sa.removesContactFromReception(con1, rec);
    cRefs = await sa.contactStore.receptionContacts(rec.id);
    _log.finest('Fetched: ' + cRefs.map((cref) => cref.toJson()).join(', '));
    expect(cRefs.length, equals(1));

    expect(cRefs.any((ref) => ref.id == con1.id), isFalse);
    expect(cRefs.any((ref) => ref.id == con2.id), isTrue);

    await sa.removesContactFromReception(con2, rec);
    cRefs = await sa.contactStore.receptionContacts(rec.id);
    _log.finest('Fetched: ' + cRefs.map((cref) => cref.toJson()).join(', '));
    expect(cRefs.length, equals(0));

    expect(cRefs.any((ref) => ref.id == con1.id), isFalse);
    expect(cRefs.any((ref) => ref.id == con2.id), isFalse);
  }
}
