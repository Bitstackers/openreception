part of openreception.test;

void testModelCalendarEntryChange() {
  group('Model.CalendarEntryChange', () {
    test('serializationDeserialization',
        ModelCalendarEntryChange.serializationDeserialization);
    test('serialization', ModelCalendarEntryChange.serialization);
    test('buildObject', ModelCalendarEntryChange.buildObject);
  });
}

abstract class ModelCalendarEntryChange {
  static void serializationDeserialization() => expect(
      new Model.CalendarEntryChange.fromMap(
          Test_Data.calendarEntryChange).asMap,
      equals(Test_Data.calendarEntryChange));

  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization() => expect(() => JSON.encode(
          new Model.CalendarEntryChange.fromMap(Test_Data.calendarEntryChange)),
      returnsNormally);

  static void buildObject() {
    DateTime changedAt = new DateTime.now();
    int changedBy = 2;
    String changedByName = 'That guy';

    Model.CalendarEntryChange testChange = new Model.CalendarEntryChange()
      ..changedAt = changedAt
      ..userID = changedBy
      ..username = changedByName;

    expect(testChange.userID, equals(changedBy));
    expect(testChange.changedAt, equals(changedAt));
    expect(testChange.username, equals(changedByName));
  }
}
