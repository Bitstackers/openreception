part of openreception.test;

testModelBaseContact() {
  group('Model.BaseContact', () {
    test('serializationDeserialization',
        ModelBaseContact.serializationDeserialization);

    test('buildObject', ModelBaseContact.buildObject);
  });
}

abstract class ModelBaseContact {

  static void serializationDeserialization() {
    Model.BaseContact builtObject = buildObject();
    Model.BaseContact deserializedObject =
        new Model.BaseContact.fromMap(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.id, equals(deserializedObject.id));
    expect(builtObject.enabled, equals(deserializedObject.enabled));
    expect(builtObject.fullName, equals(deserializedObject.fullName));
    expect(builtObject.contactType, equals(deserializedObject.contactType));


  }

  static Model.BaseContact buildObject() {
    final int contactID = 2;
    final bool enabled = true;
    final String fullName = 'Biff, the goldfish';
    final String contactType = Model.ContactType.human;

    Model.BaseContact builtObject = new Model.BaseContact.empty()
      ..id = contactID
      ..enabled = enabled
      ..fullName = fullName
      ..contactType = contactType;

    expect(builtObject.id, equals(contactID));
    expect(builtObject.enabled, equals(enabled));
    expect(builtObject.fullName, equals(fullName));
    expect(builtObject.contactType, equals(contactType));

    return builtObject;
  }
}
