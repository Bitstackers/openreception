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
    test('serializationDeserialization',
        ModelReception.serializationDeserialization);
    test('serialization', ModelReception.serialization);
    test('buildObject', ModelReception.buildObject);
  });
}
abstract class ModelReception {
  static void serializationDeserialization () {
      expect(new Model.Reception.fromMap(Test_Data.testReception).asMap,
        equals(Test_Data.testReception));

      expect(new Model.Reception.fromMap(Test_Data.testReception2).asMap,
        equals(Test_Data.testReception2));

   }


  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization () =>
      expect(() => new Model.Reception.fromMap(Test_Data.testReception), returnsNormally);

  static void buildObject () {
    Model.Reception testReception = new Model.Reception.empty()
      ..addresses = []
      ..alternateNames = []
      ..attributes = {}
      ..bankingInformation = []
      ..customerTypes = ['Not defined']
      ..emailAddresses = []
      ..enabled = true
      ..extension = '12340001'
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
    expect(testReception.toJson, returnsNormally);
  }
}

