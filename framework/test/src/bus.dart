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
