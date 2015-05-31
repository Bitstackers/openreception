part of openreception.test;

void testEvent() {
  group('Event.parse', () {
    test('messageChangeState', EventTests.messageChangeState);
    test('calendarEntryState', EventTests.calendarEntryState);
  });
}

abstract class EventTests {

  static void messageChangeState() {
    final int mid = 1;
    final state = Event.MessageChangeState.CREATED;

    Event.MessageChange testEvent = new Event.MessageChange(mid, state);

    Event.MessageChange builtEvent = new Event.Event.parse(testEvent.asMap);

    expect(builtEvent.messageID, equals(mid));
    expect(builtEvent.state, equals(state));
  }

  static void calendarEntryState () {
    final int id = 1;
    final int rid = 2;
    final int cid = 3;
    final state = Event.CalendarEntryState.CREATED;

    Event.CalendarChange testEvent =
        new Event.CalendarChange(id, cid, rid, state);

    Event.CalendarChange builtEvent = new Event.Event.parse(testEvent.asMap);

    expect (builtEvent.contactID, equals(cid));
    expect (builtEvent.receptionID, equals(rid));
    expect (builtEvent.entryID, equals(id));
    expect (builtEvent.state, equals(state));
  }
}
