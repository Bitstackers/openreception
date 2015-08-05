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

void testEventCalendarChange() {
  group('Event.CalendarChangeEvent', () {
    test('buildObject', EventCalendarChange.buildObject);
    test('serialization', EventCalendarChange.serialization);
    test('serializationDeserialization',
        EventCalendarChange.serializationDeserialization);
  });
}

abstract class EventCalendarChange {

  static void buildObject() {
    final int id = 1;
    final int rid = 2;
    final int cid = 3;
    final state = Event.CalendarEntryState.CREATED;

    Event.CalendarChange testEvent =
        new Event.CalendarChange(id, cid, rid, state);

    expect(testEvent.entryID, equals(id));
    expect(testEvent.contactID, equals(cid));
    expect(testEvent.receptionID, equals(rid));
    expect(testEvent.state, equals(state));
  }

  static void serialization() {
    final int id = 1;
    final int rid = 2;
    final int cid = 3;
    final state = Event.CalendarEntryState.CREATED;

    Event.CalendarChange testEvent =
        new Event.CalendarChange(id, cid, rid, state);

    expect(testEvent.toJson, returnsNormally);
  }

  static void serializationDeserialization() {
    final int id = 1;
    final int rid = 2;
    final int cid = 3;
    final state = Event.CalendarEntryState.CREATED;

    Event.CalendarChange testEvent =
        new Event.CalendarChange(id, cid, rid, state);

    Map serialized = testEvent.toJson();

    expect(
        new Event.CalendarChange.fromMap(serialized).asMap, equals(serialized));
  }
}
