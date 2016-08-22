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

void _testResourceEndpoint() {
  group('Resource.Endpoint', () {
    test('ofContact', _ResourceEndpoint.ofContact);
    test('single', _ResourceEndpoint.single);
  });
}

abstract class _ResourceEndpoint {
  static final Uri endpointServer = Uri.parse('http://localhost:4010');

  static void ofContact() => expect(
      resource.Endpoint.ofContact(endpointServer, 4, 1),
      equals(Uri.parse('$endpointServer/contact/1/reception/4/endpoint')));

  static void single() => expect(resource.Endpoint.single(endpointServer, 99),
      equals(Uri.parse('$endpointServer/endpoint/99')));
}
