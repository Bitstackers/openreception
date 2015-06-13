part of or_test_fw;

class organization {
  static Transport.Client client;
  static Storage.Organization organizationStore;

  static Future getNonExistingOrganization() {
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
      expect(organization.fullName, equals('BitStackers Ltd.'));
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

      return organizationStore.update(organization).then((Model.Organization updatedOrganization) {
        expect(updatedOrganization.fullName, equals(new_full_name));

        //Roll-back
        updatedOrganization.fullName = originale_full_name;
        return organizationStore.update(updatedOrganization);
      });
    });
  }

  static Future createOrganization() {
    const String full_name = '..Test-Create Mandela A/S';
    const String flag = 'TEST';
    const String billingType = 'cash';

    Model.Organization organization = new Model.Organization.empty()
      ..fullName = full_name
      ..flag = flag
      ..billingType = billingType;

    return organizationStore.create(organization).then((Model.Organization organization) {
      expect(organization.id, greaterThanOrEqualTo(1));
      expect(organization.fullName, equals(full_name));
      expect(organization.flag, equals(flag));
      expect(organization.billingType, equals(billingType));

      //Clean up.
      return organizationStore.remove(organization.id);
    });
  }
}