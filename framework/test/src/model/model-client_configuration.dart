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
  static void serialization() {
    Model.ClientConfiguration builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  static void serializationDeserialization() {
    Model.ClientConfiguration builtObject = buildObject();
    Model.ClientConfiguration deserializedObject =
        new Model.ClientConfiguration.fromMap(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.authServerUri, equals(deserializedObject.authServerUri));
    expect(builtObject.userServerUri, equals(deserializedObject.userServerUri));
    expect(builtObject.callFlowServerUri, equals(deserializedObject.callFlowServerUri));
    expect(builtObject.contactServerUri, equals(deserializedObject.contactServerUri));
    expect(builtObject.dialplanServerUri, equals(deserializedObject.dialplanServerUri));
    expect(builtObject.messageServerUri, equals(deserializedObject.messageServerUri));
    expect(builtObject.notificationServerUri, equals(deserializedObject.notificationServerUri));
    expect(builtObject.notificationSocketUri, equals(deserializedObject.notificationSocketUri));
    expect(builtObject.receptionServerUri, equals(deserializedObject.receptionServerUri));
    expect(builtObject.systemLanguage, equals(deserializedObject.systemLanguage));
  }

  /**
   * Build an object, and check that the expected values are present.
   */
  static Model.ClientConfiguration buildObject () {

    final Uri authServerUri = Uri.parse('http://authserver.example.com');
    final Uri userServerUri = Uri.parse('http://userserver.example.com');
    final Uri callFlowServerUri = Uri.parse('http://callFlow.example.com');
    final Uri contactServerUri = Uri.parse('http://contact.example.com');
    final Uri messageServerUri = Uri.parse('http://message.example.com');
    final Uri dialplanServerUri = Uri.parse('http://dialplan.example.com');
    final Uri notificationServerUri = Uri.parse('http://notification.example.com');
    final Uri notificationSocketUri = Uri.parse('ws://notification.example.com');
    final Uri receptionServerUri = Uri.parse('http://reception.example.com');
    final String systemLanguage = 'en';

    Model.ClientConfiguration config = new Model.ClientConfiguration.empty()
      ..authServerUri = authServerUri
      ..callFlowServerUri = callFlowServerUri
      ..contactServerUri = contactServerUri
      ..dialplanServerUri = dialplanServerUri
      ..messageServerUri = messageServerUri
      ..notificationServerUri = notificationServerUri
      ..notificationSocketUri = notificationSocketUri
      ..receptionServerUri = receptionServerUri
      ..userServerUri = userServerUri
      ..systemLanguage = systemLanguage;

    expect(config.authServerUri, equals(authServerUri));
    expect(config.userServerUri, equals(userServerUri));
    expect(config.callFlowServerUri, equals(callFlowServerUri));
    expect(config.contactServerUri, equals(contactServerUri));
    expect(config.dialplanServerUri, equals(dialplanServerUri));
    expect(config.messageServerUri, equals(messageServerUri));
    expect(config.notificationServerUri, equals(notificationServerUri));
    expect(config.notificationSocketUri, equals(notificationSocketUri));
    expect(config.receptionServerUri, equals(receptionServerUri));
    expect(config.systemLanguage, equals(systemLanguage));

    return config;
  }


}