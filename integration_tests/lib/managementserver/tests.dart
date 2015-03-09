part of or_test_fw;


void runAllTests() {
  const String authToken = 'feedabbadeadbeef0';
  final Uri serverUrl = Config.managementServerURI;

  group('Management.Organization', () {
    setUp(() {
      _organization.client = new Transport.Client();
      _organization.organizationStore = new Service.RESTOrganizationStore(serverUrl, authToken, _organization.client);
    });
    tearDown(() {
      _organization.client.client.close(force: true);
    });

    test('Get invalid organization', _organization.getInvalidOrganization);
    test('Get organization', _organization.getOrganization);
    test('List organizations', _organization.getOrganizationList);
    test('Updage organization', _organization.updateOrganization);
    test('Create organization', _organization.createOrganization);
  });

  group('Management.Reception', () {
    setUp(() {
      _reception.client = new Transport.Client();
      _reception.receptionStore = new Service.RESTReceptionStore(serverUrl, authToken, _reception.client);
    });
    tearDown(() {
      _reception.client.client.close(force: true);
    });

    test('Get Reception', _reception.getReception);
    test('Get Invalid Reception', _reception.getInvalidReception);
    test('Get Reception List', _reception.getReceptionList);
    test('Updage Reception', _reception.updateReception);
    test('Create Reception', _reception.createReception);
  });
}

class _reception {
  static Transport.Client client;
  static Storage.Reception receptionStore;

  static Future getReception() {
    const int receptionId = 1;

    return receptionStore.get(receptionId).then((Model.Reception reception) {
      expect(reception.ID, equals(receptionId));
      expect(reception.fullName, isNotEmpty);
      expect(reception.greeting, isNotEmpty);
    });
  }

  static Future getInvalidReception() {
    const int organizationId = 999999999;
    return receptionStore.get(organizationId).then((Model.Reception reception) {
      fail('This should have returned a NOT FOUND');
    }).catchError((error) {
      expect(error, new isInstanceOf<Storage.NotFound>());
    });
  }

  static Future getReceptionList() {
    return receptionStore.list().then((List<Model.Reception> receptions) {
      expect(receptions, isNotNull);
      receptions.forEach((r) => expect(r.ID, greaterThanOrEqualTo(1)));
    });
  }

  static Future updateReception() {
    const int receptionId = 1;

    return receptionStore.get(receptionId).then((Model.Reception reception) {
      expect(reception, isNotNull);
      String originale_full_name = reception.fullName;
      String new_full_name = 'Test-Update ${originale_full_name}';
      reception.fullName = new_full_name;

      return receptionStore.save(reception).then((Model.Reception updatedReception) {
        expect(updatedReception.fullName, equals(new_full_name));

        //Roll-back
        updatedReception.fullName = originale_full_name;
        return receptionStore.save(updatedReception);
      });
    });
  }

  static Future createReception() {
    const String full_name = '..Test-Create Mandela A/S';
    const String shortGreeting = 'Welcome to this wonderfull land.';
    const String greeting = 'cash';
    const int organization_id = 1;

    Model.Reception reception = new Model.Reception()
      ..organizationId = organization_id
      ..fullName = full_name
      ..shortGreeting = shortGreeting
      ..greeting = greeting
      ..enabled = false;

    return receptionStore.save(reception).then((Model.Reception newReception) {
      expect(newReception.organizationId, equals(organization_id));
      expect(newReception.ID, greaterThanOrEqualTo(1));
      expect(newReception.fullName, equals(full_name));
      expect(newReception.shortGreeting, equals(shortGreeting));
      expect(newReception.greeting, equals(greeting));

      //Clean up.
      return receptionStore.remove(newReception.ID).then((Model.Reception removeReception) {
        expect(removeReception.ID, greaterThanOrEqualTo(1));
        expect(removeReception.fullName, equals(full_name));
        expect(removeReception.shortGreeting, equals(shortGreeting));
        expect(removeReception.greeting, equals(greeting));
      });
    });
  }
}

class _organization {
  static Transport.Client client;
  static Storage.Organization organizationStore;

  static Future getInvalidOrganization() {
    const int organizationId = 99999999;
    return organizationStore.get(organizationId).then((Model.Organization organization) {
      fail('This should have returned a NOT FOUND');
    }).catchError((error) {
      expect(error, new isInstanceOf<Storage.NotFound>());
    });
  }

  static Future getOrganization() {
    const int organizationId = 1;

    return organizationStore.get(organizationId).then((Model.Organization organization) {
      expect(organization, isNotNull);
      expect(organization.id, equals(organizationId));
      expect(organization.fullName, equals('AdaHeads K/S'));
    });
  }

  static Future getOrganizationList() {
    return organizationStore.list().then((List<Model.Organization> organizations) {
      expect(organizations, isNotNull);
      expect(organizations.any((org) => org.id == 1), isTrue);
    });
  }

  static Future updateOrganization() {
    const int organizationId = 1;

    return organizationStore.get(organizationId).then((Model.Organization organization) {
      expect(organization, isNotNull);
      String originale_full_name = organization.fullName;
      String new_full_name = 'Test-Update ${originale_full_name}';
      organization.fullName = new_full_name;

      return organizationStore.save(organization).then((Model.Organization updatedOrganization) {
        expect(updatedOrganization.fullName, equals(new_full_name));

        //Roll-back
        updatedOrganization.fullName = originale_full_name;
        return organizationStore.save(updatedOrganization);
      });
    });
  }

  static Future createOrganization() {
    const String full_name = '..Test-Create Mandela A/S';
    const String flag = 'TEST';
    const String billingType = 'cash';

    Model.Organization organization = new Model.Organization()
      ..fullName = full_name
      ..flag = flag
      ..billingType = billingType;

    return organizationStore.save(organization).then((Model.Organization organization) {
      expect(organization.id, greaterThanOrEqualTo(1));
      expect(organization.fullName, equals(full_name));
      expect(organization.flag, equals(flag));
      expect(organization.billingType, equals(billingType));

      //Clean up.
      return organizationStore.remove(organization);
    });
  }
}

