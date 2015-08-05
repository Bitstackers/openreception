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

void testModelMessageRecipientList() {
  group('Model.MessageRecipientList', () {
    test('buildObject', ModelMessageRecipientList.buildObject);

    test('serialize', ModelMessageRecipientList.serialize);
    test('deserialize', ModelMessageRecipientList.deserialize);
  });
}

abstract class ModelMessageRecipientList {
  static void serialize() {
    final String serializedObject = JSON.encode(buildObject());

    expect(serializedObject, isNotEmpty);
    expect(serializedObject, isNotNull);
  }

  static void deserialize() {
    final Model.MessageRecipientList builtObject = buildObject();
    final String serializedObject = JSON.encode(builtObject);
    final Model.MessageRecipientList deserializedObject =
        new Model.MessageRecipientList.fromMap(JSON.decode(serializedObject));

    expect(builtObject.recipients, equals(deserializedObject.recipients));
    expect(builtObject.asMap, equals(deserializedObject.asMap));
  }

  static Model.MessageRecipientList buildObject() {
    final Model.MessageRecipient recipient1_2 = new Model.MessageRecipient()
      ..role = Model.Role.TO
      ..contactID = 1
      ..contactName = '1'
      ..receptionID = 2
      ..receptionName = '2';

    final Model.MessageRecipient recipient2_2 = new Model.MessageRecipient()
      ..role = Model.Role.TO
      ..contactID = 2
      ..contactName = '2'
      ..receptionID = 2
      ..receptionName = '2';

    final Model.MessageRecipient recipient2_3 = new Model.MessageRecipient()
      ..role = Model.Role.CC
      ..contactID = 2
      ..contactName = '2'
      ..receptionID = 3
      ..receptionName = '3';

    final Model.MessageRecipient recipient2_4 = new Model.MessageRecipient()
      ..role = Model.Role.BCC
      ..contactID = 2
      ..contactName = '2'
      ..receptionID = 4
      ..receptionName = '4';

    final Model.MessageRecipient recipient2_5 = new Model.MessageRecipient()
      ..role = Model.Role.BCC
      ..contactID = 2
      ..contactName = '2'
      ..receptionID = 5
      ..receptionName = '5';

    final Model.MessageRecipient recipient2_6 = new Model.MessageRecipient()
      ..role = Model.Role.BCC
      ..contactID = 2
      ..contactName = '2'
      ..receptionID = 6
      ..receptionName = '6';

    Model.MessageRecipientList dlist = new Model.MessageRecipientList.empty();

    expect(dlist.isEmpty, isTrue);

    dlist.add(recipient1_2);
    dlist.add(recipient2_2);
    expect(dlist.isEmpty, isFalse);

    expect(dlist.recipients[Model.Role.TO].length, equals(2));

    dlist.add(recipient2_3);
    dlist.add(recipient2_4);
    dlist.add(recipient2_5);

    expect(dlist.recipients[Model.Role.CC].length, equals(1));
    expect(dlist.recipients[Model.Role.BCC].length, equals(2));

    // Change the role of a contact and add it again.
    recipient2_5.role = Model.Role.CC;
    dlist.add(recipient2_5);

    expect(dlist.recipients[Model.Role.CC].length, equals(2));
    expect(dlist.recipients[Model.Role.BCC].length, equals(1));

    // Change the role of a contact and add it again.
    recipient2_5.role = Model.Role.TO;
    dlist.add(recipient2_5);

    expect(dlist.recipients[Model.Role.CC].length, equals(1));
    expect(dlist.recipients[Model.Role.TO].length, equals(3));

    // Change the role of a contact and add it again.
    recipient2_4.role = Model.Role.TO;
    dlist.add(recipient2_4);

    expect(dlist.recipients[Model.Role.BCC].length, equals(0));
    expect(dlist.recipients[Model.Role.TO].length, equals(4));

    dlist.add(recipient2_6);

    expect(dlist.recipients[Model.Role.BCC].length, equals(1));

    return dlist;
  }
}
