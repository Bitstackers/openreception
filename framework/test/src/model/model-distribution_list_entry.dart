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


void testModelDistributionListEntry() {
  group('Model.DistributionListEntry', () {
    test('deserialization', ModelDistributionListEntry.deserialization);
    test('serialization', ModelDistributionListEntry.serialization);
    test('buildObject', ModelDistributionListEntry.buildObject);
  });
}

abstract class ModelDistributionListEntry {


  static void deserialization() {
    Model.DistributionListEntry obj = buildObject();
    Model.DistributionListEntry deserializedObj =
        new Model.DistributionListEntry.fromMap(JSON.decode(JSON.encode(obj)));

    expect(obj.contactID, equals(deserializedObj.contactID));
    expect(obj.contactName, equals(deserializedObj.contactName));
    expect(obj.receptionID, equals(deserializedObj.receptionID));
    expect(obj.receptionName, equals(deserializedObj.receptionName));
    expect(obj.role, equals(deserializedObj.role));
    expect(obj.id, equals(deserializedObj.id));

    expect(obj.asMap, equals(deserializedObj.asMap));
  }

  static void serialization() {
    Model.DistributionListEntry builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  /**
   * Build an object, and check that the expected values are present.
   */
  static Model.DistributionListEntry buildObject () {

    final int id = 777;
    final int cid = 666;
    final String cname = 'The dark lord (mom)';
    final int rid = 999;
    final String rname = 'Inferno Ltd.';
    final String role = Model.Role.RECIPIENT_ROLES.first;

    Model.DistributionListEntry obj = new Model.DistributionListEntry.empty()
      ..role = role
      ..id = id
      ..contactID = cid
      ..contactName = cname
      ..receptionID = rid
      ..receptionName = rname;

    expect(obj.contactID, equals(cid));
    expect(obj.contactName, equals(cname));
    expect(obj.receptionID, equals(rid));
    expect(obj.receptionName, equals(rname));
    expect(obj.role, equals(role));
    expect(obj.id, equals(id));

    return obj;
  }


}