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

void testResourceCalendar() {
  group('Resource.Calendar', () {
    test('singleContact', ResourceCalendar.singleContact);
    test('singleReception', ResourceCalendar.singleReception);

    test('listContact', ResourceCalendar.listContact);
    test('listReception', ResourceCalendar.listReception);
    test('single', ResourceCalendar.single);
    test('changeList', ResourceCalendar.changeList);
    test('latestChange', ResourceCalendar.latestChange);
  });
}

abstract class ResourceCalendar {
  static final Uri _host = Uri.parse('http://localhost:4010');

  static void singleContact () =>
      expect(Resource.Calendar.singleContact(_host, 2, 3, 4),
        equals(Uri.parse('${_host}/contact/4/reception/3/calendar/event/2')));

  static void singleReception () =>
      expect(Resource.Calendar.singleReception(_host, 2, 3),
        equals(Uri.parse('${_host}/reception/3/calendar/event/2')));

  static void listContact () =>
      expect(Resource.Calendar.listContact(_host, 4, 2),
        equals(Uri.parse('${_host}/contact/4/reception/2/calendar')));

  static void listReception () =>
      expect(Resource.Calendar.listReception(_host, 2),
        equals(Uri.parse('${_host}/reception/2/calendar')));

  static void single () =>
      expect(Resource.Calendar.single(_host, 3),
        equals(Uri.parse('${_host}/calendar/entry/3')));

  static void changeList () =>
      expect(Resource.Calendar.changeList(_host, 3),
        equals(Uri.parse('${_host}/calendarentry/3/change')));

  static void latestChange () =>
      expect(Resource.Calendar.latestChange(_host, 3),
          equals(Uri.parse('${_host}/calendarentry/3/change/latest')));
}