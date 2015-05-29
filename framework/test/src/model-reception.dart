part of openreception.test;

void testModelReception() {
  group('Model.Reception', () {
    test('serializationDeserialization',
        ModelReception.serializationDeserialization);
    test('serialization', ModelReception.serialization);
    test('buildObject', ModelReception.buildObject);
  });
}
abstract class ModelReception {
  static void serializationDeserialization () {
      expect(new Model.Reception.fromMap(Test_Data.testReception).asMap,
        equals(Test_Data.testReception));

      expect(new Model.Reception.fromMap(Test_Data.testReception2).asMap,
        equals(Test_Data.testReception2));

   }


  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization () =>
      expect(() => new Model.Reception.fromMap(Test_Data.testReception), returnsNormally);

  static void buildObject () {
    Model.Reception testReception = new Model.Reception()
      ..addresses = []
      ..alternateNames = []
      ..attributes = {}
      ..bankingInformation = []
      ..customerTypes = ['Not defined']
      ..emailAddresses = []
      ..enabled = true
      ..extension = '12340001'
      ..extraData = Uri.parse ('http://localhost/test')
      ..fullName = 'Test test'
      ..greeting = 'Go away'
      ..handlingInstructions = ['Hang up']
      ..ID = 999
      ..lastChecked = new DateTime.now()
      ..openingHours = []
      ..organizationId  = 888
      ..otherData = 'Nope'
      ..product = 'Butter'
      ..salesMarketingHandling = []
      ..shortGreeting = 'Please go'
      ..telephoneNumbers = [new Model.PhoneNumber.empty()
                              ..value = '56 33 21 44']
      ..vatNumbers = []
      ..websites = [];
    expect(testReception.toJson, returnsNormally);
  }
}

