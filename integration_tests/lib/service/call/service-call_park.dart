part of openreception_tests.service.call;

abstract class CallPark {
  static Logger log = new Logger('$_namespace.CallFlowControl.Park');

  /**
   * Tests if call unpark events occur when a call is being hung up while
   * in a parking lot.
   */
  static Future unparkEventFromHangup(
      Receptionist receptionist, Customer caller) {
    String receptionNumber = '12340005';

    model.Call targetedCall;

    return Future
        .wait([])
        .then((_) => log.info('Caller dials the reception at $receptionNumber'))
        .then((_) => caller.dial(receptionNumber))
        .then((_) => log.info('Receptionist tries to hunt down the next call'))
        .then((_) => receptionist
            .huntNextCall()
            .then((model.Call call) => targetedCall = call))
        .then((_) => log.info('Receptionist parks call $targetedCall'))
        .then((_) => receptionist
                .park(targetedCall, waitForEvent: true)
                .then((model.Call parkedCall) {
              expect(parkedCall.assignedTo, equals(receptionist.user.id));
              expect(parkedCall.state, equals(model.CallState.Parked));
            }))
        .then((_) => log.info('Caller hangs up all calls'))
        .then((_) => caller.hangupAll())
        .then((_) => log.info('Receptionist waits for the phone to hang up'))
        .then((_) => receptionist.waitForPhoneHangup())
        .then((_) => log.info('Receptionist expects call to unpark'))
        .then((_) => receptionist.waitFor(
            eventType: event.Key.callUnpark,
            callID: targetedCall.ID,
            timeoutSeconds: 1))
        .then((_) => log.info('Receptionist expects call to hang up'))
        .then((_) => receptionist.waitFor(
            eventType: event.Key.callHangup,
            callID: targetedCall.ID,
            timeoutSeconds: 1));
  }

  /**
   * Validates that the /call/park interface indeed returns 404 when the
   * call is no longer present.
   */
  static void parkNonexistingCall(Receptionist receptionist) {
    return expect(receptionist.callFlowControl.park('nothing'),
        throwsA(new isInstanceOf<storage.NotFound>()));
  }

  /**
   * Tests a park pickup loop on a known call.
   */
  static Future explicitParkPickup(Receptionist receptionist, Customer caller) {
    String receptionNumber = '12340005';

    model.Call targetedCall;

    return Future
        .wait([])
        .then((_) => log.info('Caller dials the reception at $receptionNumber'))
        .then((_) => caller.dial(receptionNumber))
        .then((_) => log.info('Receptionist tries to hunt down the next call'))
        .then((_) => receptionist
            .huntNextCall()
            .then((model.Call call) => targetedCall = call))
        .then((_) => receptionist.eventStack.clear())
        .then((_) => log.info('Receptionist parks call $targetedCall'))
        .then((_) => receptionist
                .park(targetedCall, waitForEvent: true)
                .then((model.Call parkedCall) {
              expect(parkedCall.assignedTo, equals(receptionist.user.id));
              expect(parkedCall.state, equals(model.CallState.Parked));
            }))
        .then((_) => receptionist.eventStack.clear())
        .then((_) => log.info('Receptionist pickup call $targetedCall again'))
        .then((_) => receptionist
                .pickup(targetedCall, waitForEvent: true)
                .then((model.Call parkedCall) {
              expect(parkedCall.assignedTo, equals(receptionist.user.id));
              expect(parkedCall.state, equals(model.CallState.Speaking));
            }))
        .then((_) => receptionist.eventStack.clear())
        .then(
            (_) => log.info('Receptionist parks call $targetedCall once again'))
        .then((_) => receptionist
                .park(targetedCall, waitForEvent: true)
                .then((model.Call parkedCall) {
              expect(parkedCall.assignedTo, equals(receptionist.user.id));
              expect(parkedCall.state, equals(model.CallState.Parked));
            }))
        .then((_) => receptionist.eventStack.clear())
        .then(
            (_) => log.info('Receptionist pickup call $targetedCall last time'))
        .then((_) => receptionist
                .pickup(targetedCall, waitForEvent: true)
                .then((model.Call parkedCall) {
              expect(parkedCall.assignedTo, equals(receptionist.user.id));
              expect(parkedCall.state, equals(model.CallState.Speaking));
            }))
        .then((_) => log.info('Caller hangs up all calls'))
        .then((_) => caller.hangupAll())
        .then((_) => log.info('Receptionist waits for the phone to hang up'))
        .then((_) => receptionist.waitForPhoneHangup())
        .then((_) => log.info('Receptionist expects call to unpark'))
        .then((_) => receptionist.waitFor(
            eventType: event.Key.callUnpark,
            callID: targetedCall.ID,
            timeoutSeconds: 1))
        .then((_) => log.info('Receptionist expects call to hang up'))
        .then((_) => receptionist.waitFor(
            eventType: event.Key.callHangup,
            callID: targetedCall.ID,
            timeoutSeconds: 1));
  }

  /**
   * Tests the call list length.
   */
  static Future parkCallListLength(Receptionist receptionist, Customer caller) {
    String receptionNumber = '12340005';

    model.Call targetedCall;

    return Future
        .wait([])
        .then((_) => log.info('Caller dials the reception at $receptionNumber'))
        .then((_) => caller.dial(receptionNumber))
        .then((_) => log.info('Receptionist tries to hunt down the next call'))
        .then((_) => receptionist
            .huntNextCall()
            .then((model.Call call) => targetedCall = call))
        .then((_) => log.info('Receptionist parks call $targetedCall'))
        .then((_) => receptionist
                .park(targetedCall, waitForEvent: true)
                .then((model.Call parkedCall) {
              expect(parkedCall.assignedTo, equals(receptionist.user.id));
              expect(parkedCall.state, equals(model.CallState.Parked));
            }))
        .then((_) => log.info('Checking call list length'))
        .then((_) =>
            CallList._validateListLength(receptionist.callFlowControl, 1))
        .then((_) => log.info('Test succeeded'));
  }
}
