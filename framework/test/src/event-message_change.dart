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

void testEventMessageChange() {
  group('Event.MessageChange', () {
    test('buildObject', EventMessageChange.buildObject);
    test('serialization', EventMessageChange.serialization);
    test('serializationDeserialization',
        EventMessageChange.serializationDeserialization);
  });
}

abstract class EventMessageChange {

  static void buildObject() {
    final int mid = 1;
    final state = Event.MessageChangeState.CREATED;

    Event.MessageChange testEvent = new Event.MessageChange(mid, state);

    expect(testEvent.messageID, equals(mid));
    expect(testEvent.state, equals(state));
  }

  static void serialization() {
    final int mid = 1;
    final state = Event.MessageChangeState.CREATED;

    Event.MessageChange testEvent = new Event.MessageChange(mid, state);

    expect(testEvent.toJson, returnsNormally);
  }

  static void serializationDeserialization() {
    final int mid = 1;
    final state = Event.MessageChangeState.CREATED;

    Event.MessageChange testEvent = new Event.MessageChange(mid, state);

    expect(testEvent.messageID, equals(mid));
    expect(testEvent.state, equals(state));

    Map serialized = testEvent.toJson();

    expect(
        new Event.MessageChange.fromMap(serialized).asMap, equals(serialized));
  }
}
