/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

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

testModelVoicemail() {
  group('Model.Voicemail', () {
    test('deserialization', ModelVoicemail.deserialization);
    test('serialization', ModelVoicemail.serialization);
    test('buildObject', ModelVoicemail.buildObject);
  });
}

/**
*
 */
abstract class ModelVoicemail {
/**
 *
 */
  static void serialization() {
    Model.Voicemail builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

/**
 *
 */
  static void deserialization() {
    Model.Voicemail builtObject = buildObject();

    Model.Voicemail deserializedObject =
        Model.Voicemail.parse(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.toJson(), equals(deserializedObject.toJson()));

    expect(builtObject.vmBox, equals(deserializedObject.vmBox));
    expect(builtObject.recipient, equals(deserializedObject.recipient));
    expect(builtObject.note, equals(deserializedObject.note));
  }

/**
 *
 */
  static Model.Voicemail buildObject() {
    final String vmBox = 'vm-33114422';
    final String recipient = 'someone@email.dot';
    final String note = 'Someones email';

    Model.Voicemail builtObject =
        new Model.Voicemail(vmBox, recipient: recipient, note: note);

    expect(builtObject.vmBox, equals(vmBox));
    expect(builtObject.recipient, equals(recipient));
    expect(builtObject.note, equals(note));

    return builtObject;
  }
}
