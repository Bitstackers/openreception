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

void testEventCalendarChange() {
  group('Event.CalendarChangeEvent', () {
    test('buildObject', EventCalendarChange.buildObject);
    test('serialization', EventCalendarChange.serialization);
    test('serializationDeserialization',
        EventCalendarChange.serializationDeserialization);
  });
}

abstract class EventCalendarChange {
  static Event.CalendarChange buildObject() {
    final int eid = 1;
    final owner = new Model.OwningContact(3);
    final int uid = 1;

    Event.CalendarChange built =
        new Event.CalendarChange.create(eid, owner, uid);

    expect(built.eid, equals(eid));
    expect(built.owner.toJson(), equals(owner.toJson()));
    expect(built.modifierUid, equals(uid));
    expect(built.state, equals(Event.Change.created));

    Logger.root.shout(built.toJson());

    return built;
  }

  static void serialization() {
    Event.CalendarChange builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  static void serializationDeserialization() {
    Event.CalendarChange built = buildObject();
    Event.CalendarChange deserialized =
        new Event.CalendarChange.fromMap(JSON.decode(JSON.encode(built)));

    expect(built.eid, equals(deserialized.eid));
    expect(built.owner.toJson(), equals(deserialized.owner.toJson()));
    expect(built.modifierUid, equals(deserialized.modifierUid));
    expect(built.state, equals(deserialized.state));
  }
}
