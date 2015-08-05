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


void testModelClientConfiguration() {
  group('Model.ClientConfiguration', () {
    test('serializationDeserialization', ModelClientConfiguration.serializationDeserialization);
    test('serialization', ModelClientConfiguration.serialization);
    test('buildObject', ModelClientConfiguration.buildObject);
  });
}

abstract class ModelClientConfiguration {
  static void serializationDeserialization () =>
      expect(new Model.ClientConfiguration.fromMap(Test_Data.configMap).asMap,
        equals(Test_Data.configMap));
  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization () =>
      expect(new Model.ClientConfiguration.fromMap(Test_Data.configMap), isNotNull);

  /**
   * Build an object, and check that the expected values are present.
   */
  static Model.ClientConfiguration buildObject () {

    final Uri authServerUri = Uri.parse('http://authserver.example.com');
    final Uri callFlowServerUri = Uri.parse('http://callFlow.example.com');
    final Uri contactServerUri = Uri.parse('http://contact.example.com');
    final Uri messageServerUri = Uri.parse('http://message.example.com');
    final Uri notificationServerUri = Uri.parse('http://notification.example.com');
    final Uri notificationSocketUri = Uri.parse('ws://notification.example.com');
    final Uri receptionServerUri = Uri.parse('http://reception.example.com');
    final String systemLanguage = 'en';

    Model.ClientConfiguration config = new Model.ClientConfiguration.empty()
      ..authServerUri = authServerUri
      ..callFlowServerUri = callFlowServerUri
      ..contactServerUri = contactServerUri
      ..messageServerUri = messageServerUri
      ..notificationServerUri = notificationServerUri
      ..notificationSocketUri = notificationSocketUri
      ..receptionServerUri = receptionServerUri
      ..systemLanguage = systemLanguage;

    expect(config.authServerUri, equals(authServerUri));
    expect(config.callFlowServerUri, equals(callFlowServerUri));
    expect(config.contactServerUri, equals(contactServerUri));
    expect(config.messageServerUri, equals(messageServerUri));
    expect(config.notificationServerUri, equals(notificationServerUri));
    expect(config.notificationSocketUri, equals(notificationSocketUri));
    expect(config.receptionServerUri, equals(receptionServerUri));
    expect(config.systemLanguage, equals(systemLanguage));

    return config;
  }


}