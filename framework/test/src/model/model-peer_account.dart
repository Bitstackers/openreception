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

testModelPeerAccount() {
  group('Model.BaseContact', () {
    test('deserialization', ModelPeerAccount.deserialization);

    test('serialization', ModelPeerAccount.serialization);

    test('buildObject', ModelPeerAccount.buildObject);
  });
}

/**
 *
 */
abstract class ModelPeerAccount {
  /**
   *
   */
  static void serialization() {
    Model.PeerAccount builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  /**
   *
   */
  static void deserialization() {
    Model.PeerAccount built = ModelPeerAccount.buildObject();
    Model.PeerAccount deserialized =
        Model.PeerAccount.decode(JSON.decode(JSON.encode(built)));

    expect(built.username, equals(deserialized.username));
    expect(built.password, equals(deserialized.password));
    expect(built.context, equals(deserialized.context));
  }

  /**
   *
   */
  static Model.PeerAccount buildObject() {
    final String name = 'hal9000';
    final String password = 'I\'m afraid I cannot let you do that';
    final String context = 'Discovery One';

    Model.PeerAccount builtObject =
        new Model.PeerAccount(name, password, context);

    expect(builtObject.username, equals(name));
    expect(builtObject.password, equals(password));
    expect(builtObject.context, equals(context));

    return builtObject;
  }
}
