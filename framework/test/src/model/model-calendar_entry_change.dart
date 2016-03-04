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
    test('deserialization', ModelCalendarEntryChange.deserialization);
    test('serialization', ModelCalendarEntryChange.serialization);
    test('buildObject', ModelCalendarEntryChange.buildObject);
  });
}

abstract class ModelCalendarEntryChange {
  /**
   *
   */
  static void deserialization() {
    Model.CalendarEntryChange built = buildObject();
    Model.CalendarEntryChange deserialized =
        new Model.CalendarEntryChange.fromMap(JSON.decode(JSON.encode(built)));

    expect(built.toJson(), equals(deserialized.toJson()));

    expect(built.parentRef, equals(deserialized.parentRef));
    expect(
        built.changedAt.difference(deserialized.changedAt).abs().inMilliseconds,
        lessThan(1));
    expect(built.userId, equals(deserialized.userId));
  }

  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization() {
    Model.CalendarEntryChange builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  static Model.CalendarEntryChange buildObject() {
    final DateTime changedAt = new DateTime.now();
    final String parentRef = 'asdm3mmf';
    final int changedBy = 1;

    Model.CalendarEntryChange builtObject = new Model.CalendarEntryChange()
      ..changedAt = changedAt
      ..parentRef = parentRef
      ..userId = changedBy;

    expect(builtObject.parentRef, equals(parentRef));
    expect(builtObject.changedAt, equals(changedAt));
    expect(builtObject.userId, equals(changedBy));

    return builtObject;
  }
}
