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
}