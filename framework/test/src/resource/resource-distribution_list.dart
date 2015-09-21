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

void testResourceDistributionList() {
  group('Resource.DistributionList', () {
    test('single', ResourceDistributionList.single);
    test('ofContact', ResourceDistributionList.ofContact);
  });
}
abstract class ResourceDistributionList {
  static final Uri server = Uri.parse('http://localhost:4010');

  static void single() => expect(Resource.DistributionList.single(server, 42),
      equals(Uri.parse('${server}/dlist/42')));

  static void ofContact() =>
      expect(Resource.DistributionList.ofContact(server, 12, 42),
      equals(Uri.parse('${server}/contact/42/reception/12/dlist')));
}
