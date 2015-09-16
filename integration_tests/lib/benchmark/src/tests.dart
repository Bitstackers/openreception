part of or_test_fw;

abstract class Benchmark {
  static final Logger log = new Logger('$libraryName.Benchmark');

  /**
   * Convenience function covering the scenario of a receptionist requesting a
   * call, also covering the possible alternate scenarios that may occur.
   */
  static Future _receptionistRequestsCall(Receptionist r) {
    bool callAvailable(Model.Call call) =>
        call.assignedTo == Model.User.noID && !call.locked;

    return r.callFlowControl.callList().then((Iterable<Model.Call> calls) {
      if (calls.isEmpty) {
        log.info('No more calls. Aborting.');
        return false;
      }

      Model.Call nextCall = calls.firstWhere(callAvailable, orElse: () => null);

      log.info('$r found $nextCall available');

      if (nextCall == null) {
        return new Future.delayed(new Duration(milliseconds: 100),
            () => _receptionistRequestsCall(r));
      } else {
        log.info('$r picks up $nextCall');
        return r
            .pickup(nextCall)
            .then((_) => log.info('$r got $nextCall, hangin it up after 100ms'))
            .then((_) => new Future.delayed(
                new Duration(milliseconds: 100), () => r.hangUp(nextCall)))
            .catchError((error, stackTrace) {
          if (error is Storage.Conflict) {
            log.info('$nextCall is locked, trying again in 100ms.');
            return new Future.delayed(
                   new Duration(milliseconds: 100), () => _receptionistRequestsCall(r));

          } else if (error is Storage.NotFound) {
            log.info('$nextCall is already assigned, trying the next one.');
            return _receptionistRequestsCall(r);

          } else if (error is Storage.Forbidden) {
            log.info('$nextCall is hung up, trying the next one.');
            return _receptionistRequestsCall(r);

          } else {
            log.shout(error, stackTrace);
            return _receptionistRequestsCall(r);
          }
        });
      }
    });
  }

  /**
   * Scenario of a call rush. Every available cutomer will originate an inbound
   * call, and every available receptionist will race the others in trying to
   * aquire it.
   */
  static Future callRush(
      Iterable<Receptionist> receptionists, Iterable<Customer> customers) {
    Receptionist callWaiter = receptionists.first;


    Future waitForListToEmpty() =>
      Future.doWhile((() => new Future.delayed(
        new Duration(milliseconds: 1000), () =>
            callWaiter.callFlowControl
              .callList()
              .then((Iterable<Model.Call> calls) => calls.length != 0))));



    // Each customer spawns a call
    return Future.wait
      (customers.map((Customer customer) => customer.dial('12340003')))
    .then((_) {
      log.info('Waiting for call list to fill');
      return Future.doWhile((() =>
       new Future.delayed(
          new Duration(milliseconds: 100), () => callWaiter.callFlowControl
              .callList()
              .then((Iterable<Model.Call> calls) {
        return calls.length != customers.length;
      }))));
    })
    .then((_) => log.info('Call list filled, starting to handle the calls'))

    .then((_) => Future.wait(receptionists.map((Receptionist r) =>
        _receptionistRequestsCall(r))))
    .then((_) => log.info('Wait for call list to empty'))
    .then((_) => waitForListToEmpty().timeout(new Duration(seconds: 10)))
    .then((_) => log.info('Test done'));
  }
}
