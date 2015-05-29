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
