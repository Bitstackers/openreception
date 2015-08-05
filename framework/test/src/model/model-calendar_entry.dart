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
