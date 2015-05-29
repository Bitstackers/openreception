part of openreception.test;

testModelContact() {
  test('Model.Contact serializationDeserialization',
      ModelContact.serializationDeserialization);
}

abstract class ModelContact {
  static void serializationDeserialization() => expect(
      new Model.Contact.fromMap(Test_Data.testContact_4_1).asMap,
      equals(Test_Data.testContact_4_1));
}
