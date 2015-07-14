part of openreception.test;

void testModelClientConnection() {
  group('Model.ClientConnection', () {
    test('buildObject', ModelClientConnection.buildObject);
    test('serialization', ModelClientConnection.serialization);
    test('deserialization', ModelClientConnection.deserialization);
  });
}

abstract class ModelClientConnection {

  static void deserialization() {
    Model.ClientConnection builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);
    Model.ClientConnection decodedCall =
        new Model.ClientConnection.fromMap (JSON.decode(serializedObject));

    expect(builtObject.connectionCount, equals(decodedCall.connectionCount));
    expect(builtObject.userID, equals(decodedCall.userID));

    expect(builtObject.toJson(), equals(decodedCall.toJson()));

  }

  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization() {
    Model.ClientConnection builtObject = buildObject();

    expect(() => JSON.encode(builtObject), returnsNormally);
  }

  static Model.ClientConnection buildObject () {
    final int userId = 2;
    final int connectionCount = 1;

    Model.ClientConnection builtObject =
      new Model.ClientConnection()..connectionCount = connectionCount
      ..userID = userId;

    expect (builtObject.connectionCount, equals(connectionCount));
    expect (builtObject.userID, equals(userId));

    return builtObject;
  }
}