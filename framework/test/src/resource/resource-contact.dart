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
    test('list', ResourceContact.list);
    test('single', ResourceContact.single);
    test('singleByReception', ResourceContact.singleByReception);
    test('calendarEntryChanges', ResourceReception.calendarEntryChanges);
    test('calendarEntryLatestChange',
        ResourceReception.calendarEntryLatestChange);
    test('receptions', ResourceContact.receptions);
    test('organizations', ResourceContact.organizations);
    test('listByReception', ResourceContact.listByReception);

    test('colleagues', ResourceContact.colleagues);
    test('organizationContacts', ResourceContact.organizationContacts);
  });
}

abstract class ResourceContact {
  static final Uri _host = Uri.parse('http://localhost:4010');

  static void receptions() => expect(Resource.Contact.receptions(_host, 999),
      equals(Uri.parse('${_host}/contact/999/reception')));

  static void organizations() => expect(
      Resource.Contact.organizations(_host, 999),
      equals(Uri.parse('${_host}/contact/999/organization')));

  static void single() => expect(Resource.Contact.single(_host, 999),
      equals(Uri.parse('${_host}/contact/999')));

  static void list() => expect(
      Resource.Contact.list(_host), equals(Uri.parse('${_host}/contact')));

  static void singleByReception() => expect(
      Resource.Contact.singleByReception(_host, 999, 456),
      equals(Uri.parse('${_host}/contact/999/reception/456')));

  static void listByReception() => expect(
      Resource.Contact.listByReception(_host, 99),
      equals(Uri.parse('$_host/contact/list/reception/99')));

  static void colleagues() => expect(Resource.Contact.colleagues(_host, 99),
      equals(Uri.parse('$_host/contact/99/colleagues')));

  static void organizationContacts() => expect(
      Resource.Contact.organizationContacts(_host, 99),
      equals(Uri.parse('$_host/contact/organization/99')));
}
