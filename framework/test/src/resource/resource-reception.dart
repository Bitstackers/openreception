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

void _testResourceReception() {
  group('Resource.Reception', () {
    test('single', _ResourceReception.single);
    test('byExtension', _ResourceReception.byExtension);
    test('list', _ResourceReception.list);
  });
}

abstract class _ResourceReception {
  static Uri receptionServer = Uri.parse('http://localhost:4000');

  static void single() => expect(resource.Reception.single(receptionServer, 1),
      equals(Uri.parse('$receptionServer/reception/1')));

  static void byExtension() => expect(
      resource.Reception.byExtension(receptionServer, '12340001'),
      equals(Uri.parse('$receptionServer/reception/extension/12340001')));

  static void list() => expect(resource.Reception.list(receptionServer),
      equals(Uri.parse('$receptionServer/reception')));
}
