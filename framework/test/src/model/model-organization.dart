part of openreception.test;

void testModelOrganization() {
  group('Model.Organization', () {
    test('buildObject', ModelOrganization.buildObject);
    test('serialization', ModelOrganization.serialization);
  });
}
abstract class ModelOrganization{

  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization() {
    Model.Organization builtObject = buildObject();

    expect(() => JSON.encode(builtObject), returnsNormally);
  }

  static Model.Organization buildObject () {
    final String billingType = 'GOOOOLD';
    final String flag = 'Goldmember';
    final int id = 4;
    final fullName = 'Hey Goldmember!';

    Model.Organization testOrganization = new Model.Organization.empty()
      ..billingType = billingType
      ..flag = flag
      ..id = id
      ..fullName = fullName;
    expect(testOrganization.billingType, equals(billingType));
    expect(testOrganization.flag, equals(flag));
    expect(testOrganization.id, equals(id));
    expect(testOrganization.fullName, equals(fullName));

    return testOrganization;
  }
}

