part of openreception_tests.service.call;

/**
 * Tests for the call listing interface.
 */
abstract class CallList {
  static Logger log = new Logger('$_namespace.CallFlowControl.CallList');

  /**
   * Validates the current call list from [callFlow] is empty.
   */
  static Future _validateListEmpty(service.CallFlowControl callFlow) async {
    log.info('Checking if the call queue is empty');

    final Iterable<model.Call> calls = await callFlow.callList();
    expect(calls, isEmpty);
  }

  /**
   *
   */
  static Future _validateListContains(
      service.CallFlowControl callFlow, Iterable<model.Call> calls) async {
    Iterable<model.Call> queuedCalls = await callFlow.callList();
    bool existsInQueue(model.Call call) =>
        queuedCalls.any((model.Call queuedCall) => queuedCall.ID == call.ID);

    bool intersection() => calls.every(existsInQueue);

    expect(intersection(), isTrue);
  }

  /**
   *
   */
  static Future callPresence(model.ReceptionDialplan rdp,
      Receptionist receptionist, Customer customer) async {
    log.info('Customer ${customer.name} dials ${rdp.extension}.');
    await customer.dial(rdp.extension);

    log.info('Receptionist ${receptionist.user.name} waits for call.');
    final model.Call call = await receptionist.waitForCallOffer();
    await _validateListContains(receptionist.callFlowControl, [call]);

    log.info('Call is present in call list, asserting call list.');
    {
      Iterable<model.Call> calls =
          await receptionist.callFlowControl.callList();
      expect(calls.length, equals(1));
    }

    log.info('Customer ${customer.name} hangs up all crrent calls.');
    await customer.hangupAll();
    log.info('Receptionist ${receptionist.user.name} awaits call hangup.');
    await receptionist.waitFor(eventType: "call_hangup");
    log.info('Test complete');
  }

  static Future callDataOK(model.Reception rec, model.ReceptionDialplan rdp,
      Receptionist receptionist, Customer customer) async {
    log.info('Customer ${customer.name} dials ${rdp.extension}.');
    await customer.dial(rdp.extension);

    log.info('Receptionist ${receptionist.user.name} waits for call.');
    final model.Call call = await receptionist.waitForCallOffer();
    expect(call.receptionID, equals(rec.id));
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
    expect(call.arrived.difference(new DateTime.now()).inMilliseconds.abs(),
        lessThan(1000));

    log.info('Call is present in call list, asserting call list.');
    {
      Iterable<model.Call> calls =
          await receptionist.callFlowControl.callList();
      expect(calls.length, equals(1));
    }

    log.info('Customer ${customer.name} hangs up all current calls.');
    await customer.hangupAll();
    log.info('Receptionist ${receptionist.user.name} awaits call hangup.');
    await receptionist.waitFor(eventType: "call_hangup");
    log.info('Test complete.');
  }

  static Future queueLeaveEventFromPickup(model.ReceptionDialplan rdp,
      Receptionist receptionist, Customer caller) async {
    log.fine('Expecting call list to be empty');
    {
      Iterable<model.Call> calls =
          await receptionist.callFlowControl.callList();
      expect(calls, isEmpty);
    }

    await caller.dial(rdp.extension);
    log.info('Wating for the call to be received by the PBX.');
    final model.Call inboundCall = await receptionist.waitForCallOffer();

    log.info('Wating for the call $inboundCall to be queued.');
    await receptionist.waitFor(
        eventType: event.Key.queueJoin, callID: inboundCall.ID);
    log.info('Got ${event.Key.queueJoin} event, checking queue interface.');

    {
      Iterable<model.Call> calls =
          await receptionist.callFlowControl.callList();
      expect(calls.length, equals(1));
    }

    await _validateListContains(receptionist.callFlowControl, [inboundCall]);
    {
      Iterable<model.Call> calls =
          await receptionist.callFlowControl.callList();
      expect(calls.first.state, equals(model.CallState.Queued));
    }
    await receptionist.pickup(inboundCall, waitForEvent: true);
    {
      Iterable<model.Call> calls =
          await receptionist.callFlowControl.callList();
      expect(calls.first.state, isNot(model.CallState.Queued));
    }

    log.info('Waiting for ${event.Key.queueLeave} event.');
    await receptionist.waitFor(eventType: event.Key.queueLeave);
    log.info('Checking if the call is now absent from the call list.');
    await caller.hangupAll();
    log.info('Waiting for ${event.Key.callHangup} event.');
    await receptionist.waitFor(
        eventType: event.Key.callHangup, callID: inboundCall.ID);
    await _validateListEmpty(receptionist.callFlowControl);
    log.info('Test success.');
  }

  /**
   * Tests if call an unpark event occur when a call is being hung
   * up while in a queue.
   */
  static Future queueLeaveEventFromHangup(model.ReceptionDialplan rdp,
      Receptionist receptionist, Customer caller) async {
    await _validateListEmpty(receptionist.callFlowControl);

    await caller.dial(rdp.extension);
    log.info('Wating for the call to be received by the PBX.');
    final model.Call inboundCall = await receptionist.waitForCallOffer();
    log.info('Wating for the call $inboundCall to be queued.');
    await receptionist.waitFor(
        eventType: event.Key.queueJoin, callID: inboundCall.ID);
    log.info('Got ${event.Key.queueJoin} event, checking queue interface.');
    {
      Iterable<model.Call> calls =
          await receptionist.callFlowControl.callList();
      expect(calls.length, equals(1));
    }

    await _validateListContains(receptionist.callFlowControl, [inboundCall]);

    {
      final Iterable<model.Call> calls =
          await receptionist.callFlowControl.callList();
      expect(calls.first.state, equals(model.CallState.Queued));
    }

    log.info('Caller hangs up call $inboundCall');
    await caller.hangupAll();
    log.info('Waiting for ${event.Key.queueLeave} event.');

    log.info('Checking if the call is now absent from the call list.');
    log.info('Waiting for ${event.Key.callHangup} event.');
    await receptionist.waitFor(
        eventType: event.Key.callHangup, callID: inboundCall.ID);
    await _validateListEmpty(receptionist.callFlowControl);
    log.info('Test success. Cleaning up.');
  }
}
