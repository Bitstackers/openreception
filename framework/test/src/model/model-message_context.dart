part of openreception.test;

void testModelMessageContext() {
  group('Model.MessageContext', () {
    test('buildObject', ModelMessageContext.buildObject);
  });
}

abstract class ModelMessageContext {

  /**
   * Build an object manually.
   */
  static void buildObject() {
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
  }
}
