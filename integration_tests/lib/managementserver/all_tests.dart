part of or_test_fw;

void runAllTests() {
  final String authToken = Config.serverToken;
  final Uri serverUrl = Config.managementServerUri;

  group('Management.Organization', () {
    setUp(() {
      organization.client = new Transport.Client();
      organization.organizationStore = new Service.RESTOrganizationStore(serverUrl, authToken, organization.client);
    });
    tearDown(() {
      organization.client.client.close(force: true);
    });

    test('Get Non-Existing organization', organization.getNonExistingOrganization);
  });

  group('Management.Reception', () {
    setUp(() {
      _reception.client = new Transport.Client();
      _reception.receptionStore = new Service.RESTReceptionStore(serverUrl, authToken, _reception.client);
    });
    tearDown(() {
      _reception.client.client.close(force: true);
    });

    test('Get Non-Existing Reception', _reception.getNonExistingReception);

  });

  group('Management.Contact', () {
    setUp(() {
      Contact.client = new Transport.Client();
      Contact.contactStore = new Service.RESTContactStore(serverUrl, authToken, _reception.client);
    });
    tearDown(() {
      _reception.client.client.close(force: true);
    });

    test('Get Non-Existing Contact', Contact.getNonExistingContact);
  });
}
