part of openreception.test;

testModelBaseContact() {
  group('Model.BaseContact', () {
    test('serializationDeserialization',
        ModelContact.serializationDeserialization);

    test('Model.Contact buildObject', ModelContact.buildObject);
  });
}

abstract class ModelBaseContact {

  static void serializationDeserialization() {
    Model.BaseContact builtObject = _buildObject();
    Model.Contact deserializedObject =
        new Model.Contact.fromMap(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.receptionID, equals(deserializedObject.receptionID));
    expect(builtObject.ID, equals(deserializedObject.ID));

  }

  static Model.BaseContact _buildObject() {
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
