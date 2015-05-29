part of openreception.test;

void testModelMessage() {
  group('Model.Message', () {
    test('serializationDeserialization',
         ModelMessage.serializationDeserialization);
    test('serialization', ModelMessage.serialization);
  });
}

abstract class ModelMessage {
  static void serializationDeserialization() => expect(
      new Model.Message.fromMap(Test_Data.testMessage_1_Map).asMap,
      equals(Test_Data.testMessage_1_Map));

  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization() => expect(
      () => new Model.Message.fromMap(Test_Data.testMessage_1_Map),
      returnsNormally);
}
