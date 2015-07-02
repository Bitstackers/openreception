part of or_test_fw;

/**
 * Tests for the call listing interface.
 */
abstract class CallList {
  static Logger log = new Logger('$libraryName.CallFlowControl.CallList');


  static Future _validateListEmpty(Service.CallFlowControl callFlow) {
      log.info('Checking if the call queue is empty');

      return callFlow.callList().then((Iterable<Model.Call> calls) =>
          expect(calls, isEmpty));
  }

  static Future _validateListLength
    (Service.CallFlowControl callFlow, int length) {

    return  callFlow.callList().then((Iterable<Model.Call> calls) =>
        expect(calls.length, equals(length)));
  }

  static Future _validateListContains
    (Service.CallFlowControl callFlow, Iterable<Model.Call> calls) {

    return  callFlow.callList().then((Iterable<Model.Call> queuedCalls) {

      bool existsInQueue (Model.Call call) =>
          queuedCalls.any ((Model.Call queuedCall) =>
              queuedCall.ID == call.ID);

      bool intersection () => calls.every(existsInQueue);

      expect(intersection(), isTrue);
    });
  }

  static Future _validateQueueNotEmpty(Service.CallFlowControl callFlow) {
    log.info('Checking if the call queue is non-empty');

    return callFlow.callList().then((Iterable<Model.Call> calls) =>
        expect(calls, isNotEmpty));
  }

  static Future callPresence(Receptionist receptionist, Customer customer) {
     String       reception = "12340004";

     return
       Future.wait([])
       .then((_) => log.info ('Customer ${customer.name} dials ${reception}.'))
       .then((_) => customer.dial (reception))
       .then((_) => log.info ('Receptionist ${receptionist.user.name} waits for call.'))
       .then((_) => receptionist.waitForCall()
         .then((Model.Call call) =>
             _validateListContains(receptionist.callFlowControl, [call])))
         .then((_) => log.info ('Call is present in call list, asserting call list.'))
         .then((_) => _validateListLength(receptionist.callFlowControl, 1))
       .then((_) => log.info ('Customer ${customer.name} hangs up all current calls.'))
       .then((_) => customer.hangupAll())
       .then((_) => log.info ('Receptionist ${receptionist.user.name} awaits call hangup.'))
       .then((_) => receptionist.waitFor(eventType:"call_hangup"))
       .then((_) =>  log.info ('Test complete, cleaning up.'));
   }

  static Future queueLeaveEventFromPickup(Receptionist receptionist,
                                          Customer caller) {
    String receptionNumber = '12340003';
    Model.Call inboundCall = null;

    return _validateListEmpty(receptionist.callFlowControl)
      .then((_) => caller.dial(receptionNumber))
      .then((_) => log.info('Wating for the call to be received by the PBX.'))
      .then((_) => receptionist.waitFor(eventType: Event.Key.callOffer)
        .then ((Event.CallOffer event) => inboundCall = event.call))

      .then((_) => log.info('Wating for the call $inboundCall to be queued.'))
      .then((_) => receptionist.waitFor(eventType: Event.Key.queueJoin,
                                        callID: inboundCall.ID))
      .then((_) => log.info('Got ${Event.Key.queueJoin} event, checking queue interface.'))
      .then((_) => _validateListLength(receptionist.callFlowControl, 1))
      .then((_) => _validateListContains(receptionist.callFlowControl, [inboundCall]))
      .then((_) => receptionist.callFlowControl.callList()
        .then((Iterable<Model.Call> calls) =>
            expect (calls.first.state, equals(Model.CallState.Queued))))
      .then((_) => receptionist.pickup(inboundCall, waitForEvent: true))
      .then((_) => receptionist.callFlowControl.callList()
        .then((Iterable<Model.Call> calls) =>
            expect (calls.first.state, isNot(Model.CallState.Queued))))
      .then((_) => log.info('Waiting for ${Event.Key.queueLeave} event.'))
      .then((_) => log.info('Checking if the call is now absent from the call list.'))
      .then((_) => caller.hangupAll())
      .then((_) => log.info('Waiting for ${Event.Key.callHangup} event.'))
      .then((_) => receptionist.waitFor(eventType: Event.Key.callHangup,
                                        callID: inboundCall.ID))
      .then((_) => _validateListEmpty(receptionist.callFlowControl))
      .then((_) => log.info('Test success. Cleaning up.'));
  }

  /**
   * Tests if call an unpark event occur when a call is being hung
   * up while in a queue.
   */
   static Future queueLeaveEventFromHangup(Receptionist receptionist,
                                           Customer caller) {
     String receptionNumber = '12340003';
     Model.Call inboundCall = null;

    return _validateListEmpty(receptionist.callFlowControl)
      .then((_) => caller.dial(receptionNumber))
      .then((_) => log.info('Wating for the call to be received by the PBX.'))
      .then((_) => receptionist.waitFor(eventType: Event.Key.callOffer)
      .then ((Event.CallOffer event) => inboundCall = event.call))
      .then((_) => log.info('Wating for the call $inboundCall to be queued.'))
      .then((_) => receptionist.waitFor(eventType: Event.Key.queueJoin,
                                        callID: inboundCall.ID))
      .then((_) => log.info('Got ${Event.Key.queueJoin} event, checking queue interface.'))
      .then((_) => _validateListLength(receptionist.callFlowControl, 1))
      .then((_) => _validateListContains(receptionist.callFlowControl, [inboundCall]))
      .then((_) => receptionist.callFlowControl.callList()
        .then((Iterable<Model.Call> calls) =>
          expect (calls.first.state, equals(Model.CallState.Queued))))
      .then((_) => log.info('Caller hangs up call $inboundCall'))
      .then((_) => caller.hangupAll())
      .then((_) => log.info('Waiting for ${Event.Key.queueLeave} event.'))
      .then((_) => log.info('Checking if the call is now absent from the call list.'))
      .then((_) => log.info('Waiting for ${Event.Key.callHangup} event.'))
      .then((_) => receptionist.waitFor(eventType: Event.Key.callHangup,
                                        callID: inboundCall.ID))
      .then((_) => _validateListEmpty(receptionist.callFlowControl))
      .then((_) => log.info('Test success. Cleaning up.'));

  }
}
