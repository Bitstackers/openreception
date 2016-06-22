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

void testModelCalendarEntry() {
  group('Model.CalendarEntry', () {
    test('deserialization', ModelCalendarEntry.deserialization);
    test('serialization', ModelCalendarEntry.serialization);
    test('buildObject', ModelCalendarEntry.buildObject);
  });
}

abstract class ModelCalendarEntry {
  static void deserialization() {
    Model.CalendarEntry builtObject = buildObject();
    Model.CalendarEntry deserialized =
        new Model.CalendarEntry.fromMap(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.id, equals(deserialized.id));
    expect(builtObject.content, equals(deserialized.content));
    expect(
        builtObject.start.difference(deserialized.start).abs().inMilliseconds,
        lessThan(1));
    expect(builtObject.stop.difference(deserialized.stop).abs().inMilliseconds,
        lessThan(1));
    expect(builtObject.lastAuthorId, equals(deserialized.lastAuthorId));
  }

  /**
   *
   */
  static void serialization() {
    expect(JSON.encode(buildObject()), isNotNull);
    expect(JSON.encode(buildObject()), isNotEmpty);
  }

  /**
   *
   */
  static Model.CalendarEntry buildObject() {
    final int id = 123;
    final String body = 'test test test';
    final DateTime begin = new DateTime.now().add(new Duration(hours: 1));
    final DateTime end = new DateTime.now().add(new Duration(hours: 2));
    final int uid = 42;

    Model.CalendarEntry builtObject = new Model.CalendarEntry.empty()
      ..lastAuthorId = uid
      ..id = id
      ..content = body
      ..start = begin
      ..stop = end;

    expect(builtObject.id, equals(id));
    expect(builtObject.lastAuthorId, equals(uid));
    expect(builtObject.content, equals(body));
    expect(builtObject.start, equals(begin));
    expect(builtObject.stop, equals(end));

    return builtObject;
  }
}
