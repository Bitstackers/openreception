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
