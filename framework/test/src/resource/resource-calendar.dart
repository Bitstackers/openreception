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

void _testResourceCalendar() {
  group('Resource.Calendar', () {
    test('changeList', _ResourceCalendar.changeList);
    test('changeListAll', _ResourceCalendar.changeListAll);
    test('single', _ResourceCalendar.single);
    test('listReception', _ResourceCalendar.listReception);
    test('listContact', _ResourceCalendar.listContact);
  });
}

abstract class _ResourceCalendar {
  static final Uri _host = Uri.parse('http://localhost:4010');
  static final _owner = new model.OwningContact(2);

  static void changeListAll() => expect(
      resource.Calendar.changeList(_host, _owner),
      equals(Uri.parse('$_host/calendar/c:2/change')));

  static void changeList() => expect(
      resource.Calendar.changeList(_host, _owner, 2),
      equals(Uri.parse('$_host/calendar/c:2/2/change')));

  static void single() => expect(resource.Calendar.single(_host, 3, _owner),
      equals(Uri.parse('$_host/calendar/c:2/3')));

  static void listReception() => expect(
      resource.Calendar.ownerBase(_host, new model.OwningReception(2)),
      equals(Uri.parse('$_host/calendar/r:2')));

  static void listContact() => expect(
      resource.Calendar.ownerBase(_host, new model.OwningContact(4)),
      equals(Uri.parse('$_host/calendar/c:4')));
}
