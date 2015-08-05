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
