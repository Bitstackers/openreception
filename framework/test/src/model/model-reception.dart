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

void testModelReception() {
  group('Model.Reception', () {
    test('deserialization',
        ModelReception.deserialization);
    test('serialization', ModelReception.serialization);
    test('buildObject', ModelReception.buildObject);
  });
}
abstract class ModelReception {
  static void deserialization () {
    Model.Reception builtObject = buildObject();
    Model.Reception deserializedObject =
        new Model.Reception.fromMap(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.ID, equals(deserializedObject.ID));


    expect(builtObject.addresses, equals(deserializedObject.addresses));
    expect(builtObject.alternateNames, equals(deserializedObject.alternateNames));
    expect(builtObject.attributes, equals(deserializedObject.attributes));
    expect(builtObject.bankingInformation, equals(deserializedObject.bankingInformation));
    expect(builtObject.customerTypes, equals(deserializedObject.customerTypes));
    expect(builtObject.dialplan, equals(deserializedObject.dialplan));
    expect(builtObject.emailAddresses, equals(deserializedObject.emailAddresses));
    expect(builtObject.enabled, equals(deserializedObject.enabled));
    expect(builtObject.extraData, equals(deserializedObject.extraData));
    expect(builtObject.fullName, equals(deserializedObject.fullName));
    expect(builtObject.greeting, equals(deserializedObject.greeting));
    expect(builtObject.handlingInstructions, equals(deserializedObject.handlingInstructions));
    expect(builtObject.ID, equals(deserializedObject.ID));
    expect(builtObject.lastChecked, equals(deserializedObject.lastChecked));
    expect(builtObject.miniWiki, equals(deserializedObject.miniWiki));
    expect(builtObject.name, equals(deserializedObject.name));
    expect(builtObject.openingHours, equals(deserializedObject.openingHours));
    expect(builtObject.organizationId, equals(deserializedObject.organizationId));
    expect(builtObject.otherData, equals(deserializedObject.otherData));
    expect(builtObject.product, equals(deserializedObject.product));
    expect(builtObject.salesMarketingHandling, equals(deserializedObject.salesMarketingHandling));
    expect(builtObject.shortGreeting, equals(deserializedObject.shortGreeting));
    expect(builtObject.telephoneNumbers, equals(deserializedObject.telephoneNumbers));
    expect(builtObject.vatNumbers, equals(deserializedObject.vatNumbers));
    expect(builtObject.websites, equals(deserializedObject.websites));
   }


  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization () =>
      expect(() => JSON.encode(buildObject ()), returnsNormally);

  /**expect(builtObject.otherData, equals(deserializedObject.otherData));
   * TODO: Add additional expects.
   */
  static Model.Reception buildObject () {
    final List<String> addresses = ['Somewhere else'];
    final String dialplan = '12340001';
    final List<String> alternateNames = ['nice place'];

    Model.Reception buildObject = new Model.Reception.empty()
      ..addresses = addresses
      ..dialplan = dialplan
      ..alternateNames = alternateNames
      ..bankingInformation = []
      ..customerTypes = ['Not defined']
      ..emailAddresses = []
      ..enabled = true
      ..extraData = Uri.parse ('http://localhost/test')
      ..fullName = 'Test test'
      ..greeting = 'Go away'
      ..handlingInstructions = ['Hang up']
      ..ID = 999
      ..lastChecked = new DateTime.now()
      ..openingHours = []
      ..organizationId  = 888
      ..otherData = 'Nope'
      ..product = 'Butter'
      ..salesMarketingHandling = []
      ..shortGreeting = 'Please go'
      ..telephoneNumbers = [new Model.PhoneNumber.empty()
                              ..value = '56 33 21 44']
      ..vatNumbers = []
      ..websites = [];


    expect(buildObject.addresses, equals(addresses));
    expect(buildObject.dialplan, equals(dialplan));
    expect(buildObject.alternateNames, equals(alternateNames));

    return buildObject;
  }
}


