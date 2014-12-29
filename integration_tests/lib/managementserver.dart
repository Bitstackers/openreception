library mangement.server.test.dart;

import 'dart:async';

import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/storage.dart' as Storage;
import 'package:openreception_framework/service-io.dart' as Transport;
import 'package:unittest/unittest.dart';

void runAllTests() {
  group('Management.Organization', () {
    test('Get organization', _organization.getOrganization);
    test('List organizations', _organization.getOrganizationList);
    test('Updage organizations', _organization.updateOrganization);
    test('Create organizations', _organization.createOrganization);
  });
}

class _organization {
  static const String authToken = 'feedabbadeadbeef0';
  static final Uri serverUrl = Uri.parse('http://localhost:4100');

  static Storage.Organization organizationStore = new Service.RESTOrganizationStore(serverUrl, authToken, new Transport.Client());

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

