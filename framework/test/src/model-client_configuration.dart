part of openreception.test;


void testModelClientConfiguration() {
  group('Model.Config', () {
    test('serializationDeserialization', ModelClientConfiguration.serializationDeserialization);
    test('serialization', ModelClientConfiguration.serialization);
  });
}

abstract class ModelClientConfiguration {
  static void serializationDeserialization () =>
      expect(new Model.ClientConfiguration.fromMap(Test_Data.configMap).asMap,
        equals(Test_Data.configMap));

  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization () =>
      expect(new Model.ClientConfiguration.fromMap(Test_Data.configMap), isNotNull);
}