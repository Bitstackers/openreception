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

part of openreception.framework.test;

void testModelMessageFilter() {
  group('Model.MessageFilter', () {
    test('buildObject', ModelMessageFilter.buildObject);
    test('deserialization', ModelMessageFilter.deserialization);
    test('serialization', ModelMessageFilter.serialization);
  });
}

abstract class ModelMessageFilter {
  static void deserialization() {
    Model.MessageFilter obj = buildObject();
    Model.MessageFilter deserializedObj =
        new Model.MessageFilter.fromMap(JSON.decode(JSON.encode(obj)));

    expect(obj.contactId, equals(deserializedObj.contactId));
    expect(obj.limitCount, equals(deserializedObj.limitCount));
    expect(obj.receptionId, equals(deserializedObj.receptionId));
    expect(obj.userId, equals(deserializedObj.userId));
  }

  static void serialization() {
    Model.MessageFilter builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  /**
   * Build an object manually.
   */
  static Model.MessageFilter buildObject() {
    final int cid = 1;
    final int limitCount = 100;
    final int rid = 2;

    final int uid = 99;

    Model.MessageFilter obj = new Model.MessageFilter.empty()
      ..contactId = cid
      ..limitCount = limitCount
      ..receptionId = rid
      ..userId = uid;

    expect(obj.contactId, equals(cid));
    expect(obj.limitCount, equals(limitCount));
    expect(obj.receptionId, equals(rid));
    expect(obj.userId, equals(uid));

    return obj;
  }
}
