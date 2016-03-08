part of openreception_tests.service;

/**
 * Tests for the call listing interface.
 */
abstract class CallList {
  static Logger log = new Logger('$_namespace.CallFlowControl.CallList');

  static Future _validateListEmpty(service.CallFlowControl callFlow) {
    log.info('Checking if the call queue is empty');

    return callFlow
        .callList()
        .then((Iterable<model.Call> calls) => expect(calls, isEmpty));
  }

  static Future _validateListLength(
      service.CallFlowControl callFlow, int length) {
    return callFlow.callList().then(
        (Iterable<model.Call> calls) => expect(calls.length, equals(length)));
  }

  static Future _validateListContains(
      service.CallFlowControl callFlow, Iterable<model.Call> calls) {
    return callFlow.callList().then((Iterable<model.Call> queuedCalls) {
      bool existsInQueue(model.Call call) =>
          queuedCalls.any((model.Call queuedCall) => queuedCall.ID == call.ID);

      bool intersection() => calls.every(existsInQueue);

      expect(intersection(), isTrue);
    });
  }

  static Future callPresence(Receptionist receptionist, Customer customer) {
    String reception = "12340004";

    return Future
        .wait([])
        .then((_) => log.info('Customer ${customer.name} dials ${reception}.'))
        .then((_) => customer.dial(reception))
        .then((_) =>
            log.info('Receptionist ${receptionist.user.name} waits for call.'))
        .then((_) => receptionist.waitForCall().then((model.Call call) =>
            _validateListContains(receptionist.callFlowControl, [call])))
        .then((_) =>
            log.info('Call is present in call list, asserting call list.'))
        .then((_) => _validateListLength(receptionist.callFlowControl, 1))
        .then((_) =>
            log.info('Customer ${customer.name} hangs up all current calls.'))
        .then((_) => customer.hangupAll())
        .then((_) => log
            .info('Receptionist ${receptionist.user.name} awaits call hangup.'))
        .then((_) => receptionist.waitFor(eventType: "call_hangup"))
        .then((_) => log.info('Test complete, cleaning up.'));
  }

  static Future callDataOK(Receptionist receptionist, Customer customer) {
    String reception = "12340004";

    return Future
        .wait([])
        .then((_) => log.info('Customer ${customer.name} dials ${reception}.'))
        .then((_) => customer.dial(reception))
        .then((_) =>
            log.info('Receptionist ${receptionist.user.name} waits for call.'))
        .then((_) => receptionist.waitForCall().then((model.Call call) {
              expect(call.receptionID, equals(4));
              //expect (call.destination, equals(reception));
              expect(call.assignedTo, equals(model.User.noId));
              expect(call.b_Leg, isNull);
              expect(call.channel, isNotNull);
              expect(call.channel, isNotEmpty);
              expect(call.contactID, equals(model.BaseContact.noId));
              expect(call.greetingPlayed, equals(false));
              expect(call.ID, isNotNull);
              expect(call.ID, isNotEmpty);
              expect(call.inbound, equals(true));
              expect(call.locked, equals(false));
              expect(
                  call.arrived
                      .difference(new DateTime.now())
                      .inMilliseconds
                      .abs(),
                  lessThan(1000));
            }))
        .then((_) =>
            log.info('Call is present in call list, asserting call list.'))
        .then((_) => _validateListLength(receptionist.callFlowControl, 1))
        .then((_) =>
            log.info('Customer ${customer.name} hangs up all current calls.'))
        .then((_) => customer.hangupAll())
        .then((_) => log
            .info('Receptionist ${receptionist.user.name} awaits call hangup.'))
        .then((_) => receptionist.waitFor(eventType: "call_hangup"))
        .then((_) => log.info('Test complete, cleaning up.'));
  }

  static Future queueLeaveEventFromPickup(
      Receptionist receptionist, Customer caller) {
    String receptionNumber = '12340003';
    model.Call inboundCall = null;

    return _validateListEmpty(receptionist.callFlowControl)
        .then((_) => caller.dial(receptionNumber))
        .then((_) => log.info('Wating for the call to be received by the PBX.'))
        .then((_) => receptionist
            .waitFor(eventType: event.Key.callOffer)
            .then((event.CallOffer event) => inboundCall = event.call))
        .then((_) => log.info('Wating for the call $inboundCall to be queued.'))
        .then((_) => receptionist.waitFor(
            eventType: event.Key.queueJoin, callID: inboundCall.ID))
        .then((_) => log.info(
            'Got ${event.Key.queueJoin} event, checking queue interface.'))
        .then((_) => _validateListLength(receptionist.callFlowControl, 1))
        .then((_) =>
            _validateListContains(receptionist.callFlowControl, [inboundCall]))
        .then((_) => receptionist.callFlowControl.callList().then((Iterable<model.Call> calls) =>
            expect(calls.first.state, equals(model.CallState.Queued))))
        .then((_) => receptionist.pickup(inboundCall, waitForEvent: true))
        .then((_) => receptionist.callFlowControl
            .callList()
            .then((Iterable<model.Call> calls) => expect(calls.first.state, isNot(model.CallState.Queued))))
        .then((_) => log.info('Waiting for ${event.Key.queueLeave} event.'))
        .then((_) => log.info('Checking if the call is now absent from the call list.'))
        .then((_) => caller.hangupAll())
        .then((_) => log.info('Waiting for ${event.Key.callHangup} event.'))
        .then((_) => receptionist.waitFor(eventType: event.Key.callHangup, callID: inboundCall.ID))
        .then((_) => _validateListEmpty(receptionist.callFlowControl))
        .then((_) => log.info('Test success. Cleaning up.'));
  }

  /**
   * Tests if call an unpark event occur when a call is being hung
   * up while in a queue.
   */
  static Future queueLeaveEventFromHangup(
      Receptionist receptionist, Customer caller) {
    String receptionNumber = '12340003';
    model.Call inboundCall = null;

    return _validateListEmpty(receptionist.callFlowControl)
        .then((_) => caller.dial(receptionNumber))
        .then((_) => log.info('Wating for the call to be received by the PBX.'))
        .then((_) => receptionist
            .waitFor(eventType: event.Key.callOffer)
            .then((event.CallOffer event) => inboundCall = event.call))
        .then((_) => log.info('Wating for the call $inboundCall to be queued.'))
        .then((_) => receptionist.waitFor(
            eventType: event.Key.queueJoin, callID: inboundCall.ID))
        .then((_) => log.info(
            'Got ${event.Key.queueJoin} event, checking queue interface.'))
        .then((_) => _validateListLength(receptionist.callFlowControl, 1))
        .then((_) =>
            _validateListContains(receptionist.callFlowControl, [inboundCall]))
        .then((_) => receptionist.callFlowControl.callList().then(
            (Iterable<model.Call> calls) =>
                expect(calls.first.state, equals(model.CallState.Queued))))
        .then((_) => log.info('Caller hangs up call $inboundCall'))
        .then((_) => caller.hangupAll())
        .then((_) => log.info('Waiting for ${event.Key.queueLeave} event.'))
        .then((_) =>
            log.info('Checking if the call is now absent from the call list.'))
        .then((_) => log.info('Waiting for ${event.Key.callHangup} event.'))
        .then((_) => receptionist.waitFor(eventType: event.Key.callHangup, callID: inboundCall.ID))
        .then((_) => _validateListEmpty(receptionist.callFlowControl))
        .then((_) => log.info('Test success. Cleaning up.'));
  }
}
