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

void testResourceContact() {
  group('Resource.Contact', () {
    test('calendar', ResourceContact.calendar);
    test('calendarEvent', ResourceContact.calendarEvent);
    test('endpoints', ResourceContact.endpoints);
    test('list', ResourceContact.list);
    test('phones', ResourceContact.phones);
    test('single', ResourceContact.single);
    test('singleByReception', ResourceContact.singleByReception);
    test('calendarEntryChanges', ResourceReception.calendarEntryChanges);
    test('calendarEntryLatestChange',
        ResourceReception.calendarEntryLatestChange);
    test('receptions', ResourceContact.receptions);
    test('organizations', ResourceContact.organizations);
    test('managementServerList', ResourceContact.managementServerList);
    test('listByReception', ResourceContact.listByReception);

    test('calendarEventChanges', ResourceContact.calendarEventChanges);
    test('calendarEventLatestChange', ResourceContact.calendarEventLatestChange);
    test('colleagues', ResourceContact.colleagues);
    test('organizationContacts', ResourceContact.organizationContacts);





  });
}

abstract class ResourceContact {
  static final Uri _host = Uri.parse('http://localhost:4010');

  static void receptions() => expect(Resource.Contact.receptions(_host, 999),
      equals(Uri.parse('${_host}/contact/999/reception')));

  static void organizations() => expect(Resource.Contact.organizations(_host, 999),
      equals(Uri.parse('${_host}/contact/999/organization')));

  static void managementServerList() => expect(Resource.Contact.managementServerList(_host, 999),
      equals(Uri.parse('${_host}/reception/999/contact')));

  static void single() => expect(Resource.Contact.single(_host, 999),
      equals(Uri.parse('${_host}/contact/999')));

  static void list() => expect(Resource.Contact.list(_host),
      equals(Uri.parse('${_host}/contact')));

  static void singleByReception() => expect(
      Resource.Contact.singleByReception(_host, 999, 456),
      equals(Uri.parse('${_host}/contact/999/reception/456')));

  static void calendar() => expect(
      Resource.Contact.calendar(_host, 999, 888),
      equals(Uri.parse('${_host}/contact/999/reception/888/calendar')));

  static void calendarEvent() => expect(
      Resource.Contact.calendarEvent(_host, 999, 777, 123),
      equals(Uri.parse(
          '${_host}/contact/999/reception/777/calendar/event/123')));

  static void endpoints() => expect(
      Resource.Contact.endpoints(_host, 123, 456), equals(
          Uri.parse('${_host}/contact/123/reception/456/endpoints')));

  static void phones() => expect(
      Resource.Contact.phones(_host, 123, 456),
      equals(Uri.parse('${_host}/contact/123/reception/456/phones')));

  static void calendarEntryChanges() => expect(
      Resource.Contact.calendarEventChanges(_host, 123),
      equals(Uri.parse('${_host}/calendarentry/change/123')));

  static void calendarEntryLatestChange() => expect(
      Resource.Contact.calendarEventLatestChange(_host, 123),
      equals(Uri.parse('${_host}/calendarentry/123/change/latest')));

  static void listByReception()
    => expect(Resource.Contact.listByReception(_host, 99),
        equals(Uri.parse('$_host/contact/list/reception/99')));

  static void calendarEventChanges()
    => expect(Resource.Contact.calendarEventChanges(_host, 99),
      equals(Uri.parse('$_host/calendarentry/99/change')));


  static void calendarEventLatestChange()
  => expect(Resource.Contact.calendarEventLatestChange(_host, 99),
      equals(Uri.parse('$_host/calendarentry/99/change/latest')));

  static void colleagues()
  => expect(Resource.Contact.colleagues(_host, 99),
      equals(Uri.parse('$_host/contact/99/colleagues')));


  static void organizationContacts()
  => expect(Resource.Contact.organizationContacts(_host, 99),
      equals(Uri.parse('$_host/contact/organization/99')));
}
