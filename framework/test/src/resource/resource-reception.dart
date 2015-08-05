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

void testResourceReception() {
  group('Resource.Reception', () {
    test('singleMessage', ResourceReception.single);
    test('list', ResourceReception.list);
    test('subset', ResourceReception.subset);
    test('calendar', ResourceReception.calendar);
    test('calendarEvent', ResourceReception.calendarEvent);
    test('calendarEntryChanges', ResourceReception.calendarEntryChanges);
    test('calendarEntryLatestChange',
        ResourceReception.calendarEntryLatestChange);
  });
}

abstract class ResourceReception {
  static Uri receptionServer = Uri.parse('http://localhost:4000');

  static void single() => expect(Resource.Reception.single(receptionServer, 1),
      equals(Uri.parse('${receptionServer}/reception/1')));

  static void list() => expect(Resource.Reception.list(receptionServer),
      equals(Uri.parse('${receptionServer}/reception')));

  static void subset() => expect(
      Resource.Reception.subset(receptionServer, 10, 20),
      equals(Uri.parse('${receptionServer}/reception/10/limit/20')));

  static void calendar() => expect(
      Resource.Reception.calendar(receptionServer, 1),
      equals(Uri.parse('${receptionServer}/reception/1/calendar')));

  static void calendarEvent() => expect(
      Resource.Reception.calendarEvent(receptionServer, 1, 2),
      equals(Uri.parse('${receptionServer}/reception/1/calendar/event/2')));

  static void calendarEntryChanges() => expect(
      Resource.Reception.calendarEventChanges(receptionServer, 123),
      equals(Uri.parse('${receptionServer}/calendarentry/123/change')));

  static void calendarEntryLatestChange() => expect(
      Resource.Reception.calendarEventLatestChange(receptionServer, 123),
      equals(Uri.parse('${receptionServer}/calendarentry/123/change/latest')));
}
