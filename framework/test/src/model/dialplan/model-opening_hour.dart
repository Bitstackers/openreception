/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

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

/**
 *
 */
void testModelOpeningHour() {
  group('Model.OpeningHour', () {
    test('serializationDeserialization',
        ModelOpeningHour.serializationDeserialization);

    test('serialization', ModelOpeningHour.serialization);

    test('buildObject', ModelOpeningHour.buildObject);
    test('parse (single)', ModelOpeningHour.parseSingle);
    test('parse (single - FormatException)',
        ModelOpeningHour.parseSingleFormatException);
    test('parse (multiple)', ModelOpeningHour.parseMultiple);
    test('printFormat', ModelOpeningHour.printFormat);
  });
}

/**
 *
 */
abstract class ModelOpeningHour {
  /**
   *
   */
  static void serialization() {
    Model.OpeningHour builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  /**
   *
   */
  static void serializationDeserialization() {
    Model.OpeningHour builtObject = buildObject();

    Model.OpeningHour deserializedObject =
        Model.OpeningHour.parse(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.toJson(), equals(deserializedObject.toJson()));

    expect(builtObject.toJson(), equals(deserializedObject.toJson()));
  }

  /**
   *
   */
  static Model.OpeningHour buildObject() {
    final Model.OpeningHour builtObject = new Model.OpeningHour.empty()
      ..fromDay = Model.WeekDay.mon
      ..toDay = Model.WeekDay.thur
      ..fromHour = 9
      ..fromMinute = 30
      ..toHour = 16
      ..toMinute = 30;

    return builtObject;
  }

  /**
   *
   */
  static void parseSingle() {
    Model.OpeningHour builtObject = Model.OpeningHour.parse('mon-fri 8-17');

    expect(builtObject.fromDay, equals(Model.WeekDay.mon));
    expect(builtObject.toDay, equals(Model.WeekDay.fri));
    expect(builtObject.fromHour, equals(8));
    expect(builtObject.toHour, equals(17));

    builtObject = Model.OpeningHour.parse('mon-fri     8-17   ');

    expect(builtObject.fromDay, equals(Model.WeekDay.mon));
    expect(builtObject.toDay, equals(Model.WeekDay.fri));
    expect(builtObject.fromHour, equals(8));
    expect(builtObject.toHour, equals(17));
  }

  /**
   *
   */
  static void parseSingleFormatException() {
    expect(() => Model.Notify.parse('mon-ved 8-17'),
        throwsA(new isInstanceOf<FormatException>()));
  }

  /**
   *
   */
  static void printFormat() {
    expect(Model.OpeningHour.parse('mon-fri 8-17').toJson(),
        equals('mon-fri 8:00-17:00'));
    expect(Model.OpeningHour.parse('mon-fri 8:00-17:00').toJson(),
        equals('mon-fri 8:00-17:00'));

    expect(
        Model.OpeningHour.parse('mon 8-17').toJson(), equals('mon 8:00-17:00'));

    expect(Model.OpeningHour.parse('mon 8:00-17:00').toJson(),
        equals('mon 8:00-17:00'));
  }

  /**
   *
   */
  static void parseMultiple() {
    Iterable<Model.OpeningHour> builtObjects =
        Model.parseMultipleHours('mon-fri 8-17, sat 12-13');

    expect(builtObjects.first.fromDay, equals(Model.WeekDay.mon));
    expect(builtObjects.first.toDay, equals(Model.WeekDay.fri));
    expect(builtObjects.first.fromHour, equals(8));
    expect(builtObjects.first.toHour, equals(17));

    expect(builtObjects.last.fromDay, equals(Model.WeekDay.sat));
    expect(builtObjects.last.toDay, equals(Model.WeekDay.sat));
    expect(builtObjects.last.fromHour, equals(12));
    expect(builtObjects.last.toHour, equals(13));
  }
}
