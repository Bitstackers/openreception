part of or_test_fw;

Future _sleep(int milliseconds) =>
    new Future.delayed(new Duration(milliseconds: milliseconds));

abstract class Benchmark {
  static final Logger log = new Logger('$libraryName.Benchmark');
  static int handled = 0;

  /**
   * Convenience function covering the scenario of a receptionist requesting a
   * call, also covering the possible alternate scenarios that may occur.
   */
  static Future _receptionistRequestsCall(Receptionist r) async {
    bool callAvailable(Model.Call call) =>
        call.assignedTo == Model.User.noID && !call.locked;

    await Future.doWhile(() async {
      final Iterable<Model.Call> calls = await r.callFlowControl.callList();
      if (calls.isEmpty) {
        log.info('No more calls. Aborting.');
        return false;
      }

      final Model.Call nextCall =
          calls.firstWhere(callAvailable, orElse: () => Model.Call.noCall);

      if (nextCall == Model.Call.noCall) {
        return true;
      }

      try {
        final Model.Call activeCall =
            await r.pickup(nextCall, waitForEvent: true);
        log.info('$r got $activeCall, hangin it up after 100ms');
        await new Future.delayed(new Duration(milliseconds: 100));
        await r.hangUp(activeCall);
        await r.waitForPhoneHangup();
        handled++;
      } on Storage.Conflict {
        log.fine('$nextCall is locked, trying again later.');
      } on Storage.NotFound {
        log.fine('$nextCall is hung up, trying the next one.');
      } on Storage.Forbidden {
        log.fine('$nextCall is already assigned, trying the next one.');
      } on Storage.ServerError {
        await r.waitForPhoneHangup();
      }

      await _sleep(100);
      return true;
    });
  }

  /**
   * Scenario of a call rush. Every available cutomer will originate an inbound
   * call, and every available receptionist will race the others in trying to
   * aquire it.
   */
  static Future callRush(Iterable<Receptionist> receptionists,
      Iterable<Customer> customers) async {
    Receptionist callWaiter = receptionists.first;

    Future waitForListToEmpty() => Future.doWhile((() => new Future.delayed(
        new Duration(milliseconds: 1000),
        () => callWaiter.callFlowControl
            .callList()
            .then((Iterable<Model.Call> calls) => calls.length != 0))));

    // Each customer spawns a call
    int spawned = 0;
    await Future.wait(customers.map((Customer customer) async {
      await customer.dial('12340001');
      spawned++;
      await _sleep(500);
      await customer.dial('12340002');
      spawned++;
      await _sleep(500);
      await customer.dial('12340003');
      spawned++;
      await _sleep(500);
      await customer.dial('12340004');
      spawned++;
    }));

    log.info('Waiting for call list to fill');

    await Future.doWhile(() async {
      final Iterable<Model.Call> calls =
          await callWaiter.callFlowControl.callList();
      return calls.length <= (customers.length);
    });

    handled = 0;
    log.info('Call list filled, starting to handle the calls');
    await Future.wait(
        receptionists.map((Receptionist r) => _receptionistRequestsCall(r)));
    log.info('Wait for call list to empty');
    await waitForListToEmpty().timeout(new Duration(seconds: 10));
    log.info('Receptionists processed $handled calls of $spawned spawned');
    expect(handled, equals(spawned));

    log.info('Test done');
  }
}
