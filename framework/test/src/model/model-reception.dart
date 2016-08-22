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

void _testModelReception() {
  group('Model.Reception', () {
    test('deserialization', _ModelReception.deserialization);
    test('serialization', _ModelReception.serialization);
    test('buildObject', _ModelReception.buildObject);
  });
}

abstract class _ModelReception {
  static void deserialization() {
    model.Reception builtObject = buildObject();
    model.Reception deserializedObject =
        new model.Reception.fromMap(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.addresses, equals(deserializedObject.addresses));
    expect(
        builtObject.alternateNames, equals(deserializedObject.alternateNames));
    expect(builtObject.attributes, equals(deserializedObject.attributes));
    expect(builtObject.bankingInformation,
        equals(deserializedObject.bankingInformation));
    expect(builtObject.customerTypes, equals(deserializedObject.customerTypes));
    expect(builtObject.dialplan, equals(deserializedObject.dialplan));
    expect(
        builtObject.emailAddresses, equals(deserializedObject.emailAddresses));
    expect(builtObject.enabled, equals(deserializedObject.enabled));

    expect(builtObject.name, equals(deserializedObject.name));
    expect(builtObject.greeting, equals(deserializedObject.greeting));
    expect(builtObject.handlingInstructions,
        equals(deserializedObject.handlingInstructions));
    expect(builtObject.id, equals(deserializedObject.id));

    expect(builtObject.miniWiki, equals(deserializedObject.miniWiki));
    expect(builtObject.name, equals(deserializedObject.name));
    expect(builtObject.openingHours, equals(deserializedObject.openingHours));
    expect(builtObject.oid, equals(deserializedObject.oid));
    expect(builtObject.otherData, equals(deserializedObject.otherData));
    expect(builtObject.product, equals(deserializedObject.product));
    expect(builtObject.salesMarketingHandling,
        equals(deserializedObject.salesMarketingHandling));
    expect(builtObject.shortGreeting, equals(deserializedObject.shortGreeting));
    expect(builtObject.phoneNumbers, equals(deserializedObject.phoneNumbers));
    expect(builtObject.vatNumbers, equals(deserializedObject.vatNumbers));
    expect(builtObject.websites, equals(deserializedObject.websites));
  }

  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization() =>
      expect(() => JSON.encode(buildObject()), returnsNormally);

  /**
   *
   */
  static model.Reception buildObject() {
    final List<String> addresses = ['Somewhere else'];
    final String dialplan = '12340001';
    final List<String> alternateNames = ['nice place'];
    final List<String> bankingInformation = ['The vault'];
    final List<String> customerTypes = ['Not defined'];
    final List<String> emailAddresses = ['me@evil.corp', 'him@good.corp'];
    final bool enabled = true;

    final String name = 'Test test';
    final String greeting = 'Go away';
    final List<String> handlingInstructions = ['Hang up'];
    final int id = 999;

    final List<String> openingHours = ['mon-fri 8-17'];
    final int organizationId = 123;
    final String otherData = 'Ask Data';
    final String product = 'Butter';
    final List<String> salesMarketingHandling = ['Ask them to GTFO'];
    final String shortGreeting = 'Please go';
    final List<model.PhoneNumber> telephoneNumbers = [
      new model.PhoneNumber.empty()..destination = '56 33 21 44',
      new model.PhoneNumber.empty()
        ..destination = '56 33 21 43'
        ..confidential = true
        ..note = 'Home phone'
    ];
    final List<String> vatNumbers = ['123455'];
    final List<String> websites = ['www.over-the-rainbow'];

    model.Reception buildObject = new model.Reception.empty()
      ..addresses = addresses
      ..dialplan = dialplan
      ..alternateNames = alternateNames
      ..bankingInformation = bankingInformation
      ..customerTypes = customerTypes
      ..emailAddresses = emailAddresses
      ..enabled = enabled
      ..name = name
      ..greeting = greeting
      ..handlingInstructions = handlingInstructions
      ..id = id
      ..openingHours = openingHours
      ..oid = organizationId
      ..otherData = otherData
      ..product = product
      ..salesMarketingHandling = salesMarketingHandling
      ..shortGreeting = shortGreeting
      ..phoneNumbers = telephoneNumbers
      ..vatNumbers = vatNumbers
      ..websites = websites;

    expect(buildObject.addresses, equals(addresses));
    expect(buildObject.dialplan, equals(dialplan));
    expect(buildObject.enabled, equals(enabled));

    expect(buildObject.emailAddresses, equals(emailAddresses));
    expect(buildObject.alternateNames, equals(alternateNames));
    expect(buildObject.bankingInformation, equals(bankingInformation));
    expect(buildObject.customerTypes, equals(customerTypes));

    expect(buildObject.name, equals(name));
    expect(buildObject.greeting, equals(greeting));
    expect(buildObject.handlingInstructions, equals(handlingInstructions));
    expect(buildObject.id, equals(id));

    expect(buildObject.openingHours, equals(openingHours));
    expect(buildObject.oid, equals(organizationId));
    expect(buildObject.otherData, equals(otherData));
    expect(buildObject.product, equals(product));
    expect(buildObject.salesMarketingHandling, equals(salesMarketingHandling));
    expect(buildObject.shortGreeting, equals(shortGreeting));
    expect(buildObject.phoneNumbers, equals(telephoneNumbers));
    expect(buildObject.vatNumbers, equals(vatNumbers));
    expect(buildObject.websites, equals(websites));

    return buildObject;
  }
}
