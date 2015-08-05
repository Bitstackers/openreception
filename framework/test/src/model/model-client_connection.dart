/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

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