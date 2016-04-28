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

void testResourceReception() {
  group('Resource.Reception', () {
    test('single', ResourceReception.single);
    test('byExtension', ResourceReception.byExtension);
    test('list', ResourceReception.list);
  });
}

abstract class ResourceReception {
  static Uri receptionServer = Uri.parse('http://localhost:4000');

  static void single() => expect(Resource.Reception.single(receptionServer, 1),
      equals(Uri.parse('${receptionServer}/reception/1')));

  static void byExtension() => expect(
      Resource.Reception.byExtension(receptionServer, '12340001'),
      equals(Uri.parse('${receptionServer}/reception/extension/12340001')));

  static void list() => expect(Resource.Reception.list(receptionServer),
      equals(Uri.parse('${receptionServer}/reception')));
}
