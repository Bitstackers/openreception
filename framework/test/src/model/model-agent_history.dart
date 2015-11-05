/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

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

testModelAgentHistory() {
  group('Model.AgentHistory', () {
    test('serializationDeserialization',
        ModelAgentHistory.serializationDeserialization);

    test('serialization', ModelAgentHistory.serialization);

    test('buildObject', ModelAgentHistory.buildObject);
  });
}

abstract class ModelAgentHistory {

  static void serialization() {
    Model.AgentHistory builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  static void serializationDeserialization() {
    Model.AgentHistory builtObject = buildObject();
    Model.AgentHistory deserializedObject =
        new Model.AgentHistory.fromMap(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.uid, equals(deserializedObject.uid));
    expect(builtObject.recent, equals(deserializedObject.recent));
    expect(builtObject.total, equals(deserializedObject.total));


  }

  static Model.AgentHistory buildObject() {
    final int uid = 2;
    final int recent = 5;
    final int total = 8;

    Model.AgentHistory builtObject = new Model.AgentHistory(uid, recent, total);

    expect(builtObject.uid, equals(uid));
    expect(builtObject.recent, equals(recent));
    expect(builtObject.total, equals(total));

    return builtObject;
  }
}
