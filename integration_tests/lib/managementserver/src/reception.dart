part of or_test_fw;

class _reception {
  static Transport.Client client;
  static Storage.Reception receptionStore;

  static Future getNonExistingReception() {
    const int organizationId = 999999999;
    return receptionStore.get(organizationId).then((Model.Reception reception) {
      fail('This should have returned a NOT FOUND');
    }).catchError((error) {
      expect(error, new isInstanceOf<Storage.NotFound>());
    });
  }
}