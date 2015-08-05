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
  test('async openreception.bus test', () {
    final String testEvent = 'Foo!';
    Bus bus = new Bus<String>();
    Stream<String> stream = bus.stream;
    Timer timer;

    timer = new Timer(new Duration(seconds: 1), () {
      fail('testEvent not fired or caught within 1 second');
    });

    stream.listen(expectAsync((String value) {
      expect(value, equals(testEvent));

      if (timer != null) {
        timer.cancel();
      }
    }));

    bus.fire(testEvent);
  });
}
