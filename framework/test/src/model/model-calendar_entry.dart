part of openreception.test;

void testModelCalendarEntry() {
  group('Model.CalendarEntry', () {
    test('serializationDeserialization',
        ModelCalendarEntry.serializationDeserialization);
    test('serialization', ModelCalendarEntry.serialization);
    test('contactEntryBuild', ModelCalendarEntry.contactEntryBuild);
  });
}

abstract class ModelCalendarEntry {
  static void serializationDeserialization() => expect(
      new Model.CalendarEntry.fromMap(
          Test_Data.testReceptionCalendarEntry).asMap,
      equals(Test_Data.testReceptionCalendarEntry));

  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization() => expect(() =>
          new Model.CalendarEntry.fromMap(Test_Data.testReceptionCalendarEntry),
      returnsNormally);

  static void contactEntryBuild() {
    final int id = 1;
    final int rid = 2;
    final int cid = 3;
    final String body = 'test test test';
    final DateTime begin = new DateTime.now().add(new Duration(hours: 1));
    final DateTime end = new DateTime.now().add(new Duration(hours: 2));

    Model.CalendarEntry testEntry = new Model.CalendarEntry.contact(cid, rid)
      ..ID = id
      ..content = body
      ..beginsAt = begin
      ..until = end;

    expect(testEntry.ID, equals(id));
    expect(testEntry.contactID, equals(cid));
    expect(testEntry.receptionID, equals(rid));
    expect(testEntry.content, equals(body));
    expect(testEntry.start, equals(begin));
    expect(testEntry.stop, equals(end));
  }
}
