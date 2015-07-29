part of openreception.test;

void testModelMessageContext() {
  group('Model.MessageContext', () {
    test('buildObject', ModelMessageContext.buildObject);
    test('serialization', ModelMessageContext.serialization);
  });
}

abstract class ModelMessageContext {

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
