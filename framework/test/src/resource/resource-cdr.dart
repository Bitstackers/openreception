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

void testResourceCDR() {
  group('Resource.CDR', () {
    test('checkpoint', ResourceCDR.checkpoint);
    test('list', ResourceCDR.list);
    test('baseUri', ResourceCDR.root);
  });
}

abstract class ResourceCDR {
  static final Uri _host = Uri.parse('http://localhost:4090');

  static void checkpoint() => expect(
      Resource.CDR.checkpoint(_host), equals(Uri.parse('${_host}/checkpoint')));

  static void root() =>
      expect(Resource.CDR.root(_host), equals(Uri.parse('${_host}/cdr')));

  /**
   *
   */
  static void list() {
    final String from = new DateTime.now().millisecondsSinceEpoch.toString();
    final String to = new DateTime.now()
        .add(new Duration(hours: 1))
        .millisecondsSinceEpoch
        .toString();

    expect(Resource.CDR.list(_host, from, to),
        equals(Uri.parse('${_host}/cdr?$from&$to')));
  }
}
