part of openreception.test;

void testModelOrganization() {
  group('Model.Organization', () {
    test('buildObject', ModelOrganization.buildObject);
    test('serialization', ModelOrganization.serialization);
    test('deserialization', ModelOrganization.deserialization);
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

  /**
   * Merely asserts that no exceptions arise.
   */
  static void deserialization() {
    Model.Organization builtObject = buildObject();

    String serializedObject = JSON.encode(builtObject);
    Model.Organization decodedObject =
        new Model.Organization.fromMap(JSON.decode(serializedObject));

    expect(builtObject.billingType, equals(decodedObject.billingType));
    expect(builtObject.flag, equals(decodedObject.flag));
    expect(builtObject.id, equals(decodedObject.id));
    expect(builtObject.fullName, equals(decodedObject.fullName));

    expect(builtObject.toJson(), equals(decodedObject.toJson()));
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

