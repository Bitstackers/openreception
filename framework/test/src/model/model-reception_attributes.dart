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

testModelReceptionAttributes() {
  group('Model.ReceptionAttributes', () {
    test('deserialization', ModelReceptionAttributes.deserialization);

    test('serialization', ModelReceptionAttributes.serialization);

    test('buildObject', ModelReceptionAttributes.buildObject);
  });
}

abstract class ModelReceptionAttributes {
  static void serialization() {
    Model.ReceptionAttributes builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  static void deserialization() {
    Model.ReceptionAttributes builtObject = buildObject();
    Model.ReceptionAttributes deserializedObject =
        new Model.ReceptionAttributes.fromMap(
            JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.receptionId, equals(deserializedObject.receptionId));
    expect(builtObject.contactId, equals(deserializedObject.contactId));

    {
      Iterable<Map> lhsPn =
          builtObject.phones.map((Model.PhoneNumber pn) => pn.toJson());
      Iterable<Map> rhsPn =
          deserializedObject.phones.map((Model.PhoneNumber pn) => pn.toJson());

      expect(lhsPn, equals(rhsPn));
    }

    expect(
        builtObject.backupContacts, equals(deserializedObject.backupContacts));
    expect(builtObject.departments, equals(deserializedObject.departments));
    expect(
        builtObject.emailaddresses, equals(deserializedObject.emailaddresses));
    expect(builtObject.handling, equals(deserializedObject.handling));
    expect(builtObject.infos, equals(deserializedObject.infos));
    expect(builtObject.statusEmail, equals(deserializedObject.statusEmail));
    expect(builtObject.titles, equals(deserializedObject.titles));
    expect(builtObject.relations, equals(deserializedObject.relations));
    expect(builtObject.responsibilities,
        equals(deserializedObject.responsibilities));
    expect(builtObject.tags, equals(deserializedObject.tags));
    expect(builtObject.workhours, equals(deserializedObject.workhours));
    expect(builtObject.messagePrerequisites,
        equals(deserializedObject.messagePrerequisites));
  }

  static Model.ReceptionAttributes buildObject() {
    final int receptionId = 2;
    final int contactId = 3;
    final bool statusEmail = false;
    final String contactType = 'Goldfish';
    final List<Model.PhoneNumber> pn = [
      new Model.PhoneNumber.empty()
        ..confidential = true
        ..description = 'Fluid connection'
        ..tags = ['Gulping sound', 'Silence']
        ..endpoint = '-0045 32112345'
    ];

    final List<String> backupContacts = ['Buford'];
    final List<String> departments = ['Fish school', 'Clowning'];
    final List<String> emailaddresses = ['scaly@nibble.bits'];
    final List<String> handling = ['Avoid fishing rods, please'];
    final List<String> infos = ['He\'s a fish, what more do you need to know?'];
    final List<String> titles = ['GOLD-fish'];
    final List<String> relations = ['Yo\' mamma'];
    final List<String> responsibilities = ['Swimming around', 'Nibbling'];
    final List<String> tags = ['Fish', 'Gold', 'Athlete'];
    final List<String> workhours = ['Quite frankly; never'];
    final List<String> messagePrerequisites = ['[fishcode]'];

    Model.ReceptionAttributes builtObject =
        new Model.ReceptionAttributes.empty()
          ..receptionId = receptionId
          ..contactId = contactId
          ..statusEmail = statusEmail
          ..phones.addAll(pn)
          ..backupContacts = backupContacts
          ..departments = departments
          ..emailaddresses = emailaddresses
          ..handling = handling
          ..infos = infos
          ..titles = titles
          ..relations.addAll(relations)
          ..responsibilities = responsibilities
          ..tags = tags
          ..workhours = workhours
          ..messagePrerequisites = messagePrerequisites;

    expect(builtObject.receptionId, equals(receptionId));
    expect(builtObject.contactId, equals(contactId));
    expect(builtObject.statusEmail, equals(statusEmail));
    expect(builtObject.phones, equals(pn));
    expect(builtObject.backupContacts, equals(backupContacts));
    expect(builtObject.departments, equals(departments));
    expect(builtObject.emailaddresses, equals(emailaddresses));
    expect(builtObject.handling, equals(handling));
    expect(builtObject.infos, equals(infos));
    expect(builtObject.titles, equals(titles));
    expect(builtObject.relations, equals(relations));
    expect(builtObject.responsibilities, equals(responsibilities));
    expect(builtObject.tags, equals(tags));
    expect(builtObject.workhours, equals(workhours));
    expect(builtObject.messagePrerequisites, equals(messagePrerequisites));

    return builtObject;
  }
}
