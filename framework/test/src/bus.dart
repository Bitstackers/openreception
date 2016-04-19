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

void testBus() {
  test('async openreception.bus test', () async {
    final String testEvent = 'Foo!';
    Bus bus = new Bus<String>();
    Stream stream = bus.stream;
    Future expectTestEvent =
        stream.firstWhere((String value) => value == testEvent);

    try {
      bus.fire(testEvent);
      await expectTestEvent.timeout(new Duration(seconds: 1));
    } on TimeoutException {
      fail('Did not receive event within 1 second');
    }
  });
}
