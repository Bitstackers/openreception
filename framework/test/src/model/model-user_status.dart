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

testModelUserStatus() {
  group('Model.Status', () {
    test('deserialization', ModelUserStatus.deserialization);
    test('serialization', ModelUserStatus.serialization);
    test('buildObject', ModelUserStatus.buildObject);
//    test('stateChange', ModelUserStatus.stateChange);
  });
}

abstract class ModelUserStatus {
  /**
   * Merely asserts that no exceptions arise.
   */
  static void deserialization() {
    Model.UserStatus built = buildObject();
    String serializedObject = JSON.encode(built);
    Model.UserStatus decoded =
        new Model.UserStatus.fromMap(JSON.decode(serializedObject));

    expect(built.paused, equals(decoded.paused));
    expect(built.userID, equals(decoded.userID));

    expect(built.toJson(), equals(decoded.toJson()));
  }

  static void serialization() {
    Model.UserStatus builtObject = buildObject();
    String serializedString = JSON.encode(builtObject);

    expect(serializedString, isNotEmpty);
    expect(serializedString, isNotNull);
  }

  static Model.UserStatus buildObject() {
    final bool paused = true;
    final int userID = 2;

    Model.UserStatus builtObject = new Model.UserStatus()
      ..paused = paused
      ..userID = userID;

    expect(builtObject.paused, equals(paused));
    expect(builtObject.userID, equals(userID));

    return builtObject;
  }
}
