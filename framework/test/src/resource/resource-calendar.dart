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
    test('changeList', ResourceCalendar.changeList);
    test('changeListAll', ResourceCalendar.changeListAll);
    test('single', ResourceCalendar.single);
    test('listReception', ResourceCalendar.listReception);
    test('listReceptionDeleted', ResourceCalendar.listReceptionDeleted);
    test('listContact', ResourceCalendar.listContact);
    test('listContactDeleted', ResourceCalendar.listContactDeleted);
    test('purge', ResourceCalendar.purge);
  });
}

abstract class ResourceCalendar {
  static final Uri _host = Uri.parse('http://localhost:4010');
  static final owner = new Model.OwningContact(2);

  static void changeListAll() => expect(
      Resource.Calendar.changeList(_host, owner),
      equals(Uri.parse('$_host/calendar/c:2/change')));

  static void changeList() => expect(
      Resource.Calendar.changeList(_host, owner, 2),
      equals(Uri.parse('$_host/calendarentry/2/owner/c:2/change')));

  static void single() => expect(Resource.Calendar.single(_host, 3),
      equals(Uri.parse('${_host}/calendarentry/3')));

  static void listReception() => expect(
      Resource.Calendar
          .list(_host, new Model.OwningReception(2), deleted: false),
      equals(Uri.parse('${_host}/calendar/r:2')));

  static void listReceptionDeleted() => expect(
      Resource.Calendar
          .list(_host, new Model.OwningReception(2), deleted: true),
      equals(Uri.parse('${_host}/calendar/r:2/deleted')));

  static void listContact() => expect(
      Resource.Calendar.list(_host, new Model.OwningContact(4), deleted: false),
      equals(Uri.parse('${_host}/calendar/c:4')));

  static void listContactDeleted() => expect(
      Resource.Calendar.list(_host, new Model.OwningContact(4), deleted: true),
      equals(Uri.parse('${_host}/calendar/c:4/deleted')));

  static void purge() => expect(Resource.Calendar.purge(_host, 3),
      equals(Uri.parse('${_host}/calendarentry/3/purge')));
}
