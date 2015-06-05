part of openreception.test;

testModelContact() {
  group('Model.Contact', () {
    test('deserialization', ModelContact.deserialization);

    test('serializationDeserialization',
        ModelContact.serializationDeserialization);

    test('Model.Contact buildObject', ModelContact.buildObject);
  });
}

abstract class ModelContact {
  static void deserialization() => expect(
      new Model.Contact.fromMap(Test_Data.testContact_4_1).asMap,
      equals(Test_Data.testContact_4_1));

  static void serializationDeserialization() {
    Model.Contact builtObject = buildObject();
    Model.Contact deserializedObject =
        new Model.Contact.fromMap(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.receptionID, equals(deserializedObject.receptionID));
    expect(builtObject.ID, equals(deserializedObject.ID));
    expect(builtObject.wantsMessage, equals(deserializedObject.wantsMessage));
    expect(builtObject.enabled, equals(deserializedObject.enabled));
    expect(builtObject.fullName, equals(deserializedObject.fullName));
    expect(builtObject.contactType, equals(deserializedObject.contactType));

    {
      Iterable<Map> lhsPn =
          builtObject.phones.map((Model.PhoneNumber pn) => pn.asMap);
      Iterable<Map> rhsPn =
          deserializedObject.phones.map((Model.PhoneNumber pn) => pn.asMap);

      expect(lhsPn, equals(rhsPn));
    }

    {
      Iterable<Map> lhsEp =
          builtObject.endpoints.map((Model.MessageEndpoint ep) => ep.asMap);
      Iterable<Map> rhsEp = deserializedObject.endpoints
          .map((Model.MessageEndpoint ep) => ep.asMap);

      expect(lhsEp, equals(rhsEp));
    }

    expect(builtObject.distributionList,
        equals(deserializedObject.distributionList));
    expect(
        builtObject.backupContacts, equals(deserializedObject.backupContacts));
    expect(builtObject.departments, equals(deserializedObject.departments));
    expect(
        builtObject.emailaddresses, equals(deserializedObject.emailaddresses));
    expect(builtObject.handling, equals(deserializedObject.handling));
    expect(builtObject.infos, equals(deserializedObject.infos));
    expect(builtObject.titles, equals(deserializedObject.titles));
    expect(builtObject.relations, equals(deserializedObject.relations));
    expect(builtObject.responsibilities,
        equals(deserializedObject.responsibilities));
    expect(builtObject.tags, equals(deserializedObject.tags));
    expect(builtObject.workhours, equals(deserializedObject.workhours));
    expect(builtObject.messagePrerequisites,
        equals(deserializedObject.messagePrerequisites));
  }

  static Model.Contact buildObject() {
    final int receptionID = 2;
    final int contactID = 2;
    final bool wantsMessages = false;
    final bool enabled = true;
    final String fullName = 'Biff, the goldfish';
    final String contactType = 'Goldfish';
    final List<Model.PhoneNumber> pn = [
      new Model.PhoneNumber.empty()
        ..billing_type = 'waterline'
        ..confidential = true
        ..description = 'Fluid connection'
        ..tags = ['Gulping sound', 'Silence']
        ..type = 'Very mobile'
        ..value = '-0045 32112345'
    ];

    final List<Model.MessageEndpoint> ep = [
      new Model.MessageEndpoint.empty()
        ..address = 'biff@underwater.fishnet'
        ..confidential = true
        ..description = 'Travels by sea current'
        ..enabled = true
        ..type = 'fishmail'
    ];
    final Model.MessageRecipientList dl = new Model.MessageRecipientList.empty()
      ..add(new Model.MessageRecipient()
        ..role = Model.Role.TO
        ..contactID = contactID
        ..contactName = fullName
        ..receptionID = receptionID
        ..receptionName = 'Fishy business');

    final List backupContacts = ['Buford'];
    final List departments = ['Fish school', 'Clowning'];
    final List emailaddresses = ['scaly@nibble.bits'];
    final List handling = ['Avoid fishing rods, please'];
    final List infos = ['He\'s a fish, what more do you need to know?'];
    final List titles = ['GOLD-fish'];
    final List relations = ['Yo\' mamma'];
    final List responsibilities = ['Swimming around', 'Nibbling'];
    final List tags = ['Fish', 'Gold', 'Athlete'];
    final List workhours = ['Quite frankly; never'];
    final List messagePrerequisites = ['[fishcode]'];

    Model.Contact builtObject = new Model.Contact.none()
      ..receptionID = receptionID
      ..ID = contactID
      ..wantsMessage = wantsMessages
      ..enabled = enabled
      ..fullName = fullName
      ..contactType = contactType
      ..phones.addAll(pn)
      ..endpoints.addAll(ep)
      ..distributionList = dl
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

    expect(builtObject.receptionID, equals(receptionID));
    expect(builtObject.ID, equals(contactID));
    expect(builtObject.wantsMessage, equals(wantsMessages));
    expect(builtObject.enabled, equals(enabled));
    expect(builtObject.fullName, equals(fullName));
    expect(builtObject.contactType, equals(contactType));
    expect(builtObject.phones, equals(pn));
    expect(builtObject.endpoints, equals(ep));
    expect(builtObject.distributionList, equals(dl));
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
