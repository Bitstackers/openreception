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


void testModelCallerInfo() {
  group('Model.CallerInfo', () {
    test('deserialization', ModelCallerInfo.deserialization);
    test('serialization', ModelCallerInfo.serialization);
    test('buildObject', ModelCallerInfo.buildObject);
  });
}

abstract class ModelCallerInfo {


  static void deserialization() {
    Model.CallerInfo obj = buildObject();
    Model.CallerInfo deserializedObj =
        new Model.CallerInfo.fromMap(JSON.decode(JSON.encode(obj)));

    expect(obj.cellPhone, equals(deserializedObj.cellPhone));
    expect(obj.company, equals(deserializedObj.company));
    expect(obj.localExtension, equals(deserializedObj.localExtension));
    expect(obj.name, equals(deserializedObj.name));

    expect(obj.phone, equals(deserializedObj.phone));

    expect(obj.asMap, equals(deserializedObj.asMap));
  }

  static void serialization() {
    Model.CallerInfo builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  /**
   * Build an object, and check that the expected values are present.
   */
  static Model.CallerInfo buildObject () {

    final String cellPhone = '666';
    final String company = 'Inferno Ltd.';
    final String localExtension = '313';
    final String name = 'The dark lord (mom)';
    final String phone = 'Out of service';

    Model.CallerInfo info = new Model.CallerInfo.empty()
      ..cellPhone = cellPhone
      ..company = company
      ..localExtension = localExtension
      ..name = name
      ..phone = phone;

    expect(info.cellPhone, equals(cellPhone));
    expect(info.company, equals(company));
    expect(info.localExtension, equals(localExtension));
    expect(info.name, equals(name));
    expect(info.phone, equals(phone));
    return info;
  }


}