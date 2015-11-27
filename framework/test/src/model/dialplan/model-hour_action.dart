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
void testModelHourAction() {
  group('Model.HourAction', () {
    test('deserialization', HourAction.deserialization);

    test('serialization', HourAction.serialization);

    test('buildObject', HourAction.buildObject);
    test('parse', HourAction.parse);
  });
}

/**
 *
 */
abstract class HourAction {
  /**
   *
   */
  static void serialization() {
    Model.HourAction builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  /**
   *
   */
  static void deserialization() {
    Model.HourAction builtObject = buildObject();

    Model.HourAction deserializedObject =
        Model.HourAction.parse(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.hours, equals(deserializedObject.hours));
    expect(builtObject.actions, equals(deserializedObject.actions));
    expect(builtObject.toString(), isNotEmpty);
  }

  /**
   *
   */
  static Model.HourAction buildObject() {

    final List<Model.OpeningHour> openHours = [
      new Model.OpeningHour.empty()
        ..fromDay = Model.WeekDay.mon
        ..fromHour = 8
        ..fromMinute = 30
        ..toDay = Model.WeekDay.thur
        ..toHour = 17,
      new Model.OpeningHour.empty()
        ..fromDay = Model.WeekDay.fri
        ..fromHour = 8
        ..fromMinute = 30
        ..toDay = Model.WeekDay.fri
        ..toHour = 16
    ];
    final List<Model.Action> actions = [ModelPlayback.buildObject()];

    Model.HourAction builtObject = new Model.HourAction()
      ..hours = openHours
      ..actions = actions;

    expect(builtObject.hours, equals(openHours));
    expect(builtObject.actions, equals(actions));
    expect(builtObject.toString(), isNotEmpty);

    return builtObject;
  }

  /**
   *
   */
  static void parse() {
  }
}
