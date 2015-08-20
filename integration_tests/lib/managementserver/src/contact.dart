part of or_test_fw;

class Contact {
  static Transport.Client client;
  static Storage.Contact contactStore;

  static Future getNonExistingContact() {
    const int organizationId = 999999999;
    return contactStore.get(organizationId).then((Model.BaseContact contact) {
      fail('This should have returned a NOT FOUND');
    }).catchError((error) {
      expect(error, new isInstanceOf<Storage.NotFound>());
    });
  }
}