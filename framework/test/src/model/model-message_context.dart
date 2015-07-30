part of openreception.test;

void testModelMessageContext() {
  group('Model.MessageContext', () {
    test('buildObject', ModelMessageContext.buildObject);
    test('deserialization', ModelMessageContext.deserialization);
    test('serialization', ModelMessageContext.serialization);
  });
}

abstract class ModelMessageContext {

  static void deserialization() {
    Model.MessageContext obj = buildObject();
    Model.MessageContext deserializedObj =
        new Model.MessageContext.fromMap(JSON.decode(JSON.encode(obj)));

    expect(obj.contactID, equals(deserializedObj.contactID));
    expect(obj.contactName, equals(deserializedObj.contactName));

    expect(obj.receptionID, equals(deserializedObj.receptionID));
    expect(obj.receptionName, equals(deserializedObj.receptionName));

    expect(obj.asMap, equals(deserializedObj.asMap));
  }

  static void serialization() {
    Model.MessageContext builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  /**
   * Build an object manually.
   */
  static Model.MessageContext buildObject() {
    final int contactId = 1;
    final String contactName = 'John Arbuckle';
    final int receptionId = 2;
    final String receptionName = 'Lasagna-makers inc.';

    Model.MessageContext obj = new Model.MessageContext()
      ..contactID = contactId
      ..contactName = contactName
      ..receptionID = receptionId
      ..receptionName = receptionName;

    expect(obj.contactID, equals(contactId));
    expect(obj.contactName, equals(contactName));

    expect(obj.receptionID, equals(receptionId));
    expect(obj.receptionName, equals(receptionName));

    return obj;
  }
}
