part of openreception.test;

void testModelClientConnection() {
  group('Model.ClientConnection', () {
    test('buildObject', ModelClientConnection.buildObject);
    test('serialization', ModelClientConnection.serialization);
  });
}

abstract class ModelClientConnection {

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