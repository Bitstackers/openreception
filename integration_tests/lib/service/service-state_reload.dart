part of openreception_tests.service;

abstract class StateReload {
  static Logger log = new Logger('$_namespace.CallFlowControl.UserState');

  /**
   * Validates that the content of  [list1] and [list2] is the same.
   */
  static void _validateCallLists(
      Iterable<model.Call> list1, Iterable<model.Call> list2) {
    log.info('List 1:\n  ${list1.map((c) => c.toJson()).join('\n  ')}');
    log.info('List 2:\n  ${list2.map((c) => c.toJson()).join('\n  ')}');

    expect(list1.length, equals(list2.length));

    list2.forEach((model.Call updatedCall) {
      model.Call originalCall =
          list1.firstWhere((model.Call c) => c.ID == updatedCall.ID);

      expect(originalCall.toJson(), equals(updatedCall.toJson()));
      expect(
          originalCall.arrived
              .difference(updatedCall.arrived)
              .inMilliseconds
              .abs(),
          lessThan(1000));
      expect(originalCall.assignedTo, equals(updatedCall.assignedTo));
      expect(originalCall.b_Leg, equals(updatedCall.b_Leg));
      expect(originalCall.callerID, equals(updatedCall.callerID));
      expect(originalCall.channel, equals(updatedCall.channel));
      expect(originalCall.contactID, equals(updatedCall.contactID));
      expect(originalCall.destination, equals(updatedCall.destination));
      expect(originalCall.greetingPlayed, equals(updatedCall.greetingPlayed));
      expect(originalCall.ID, equals(updatedCall.ID));
      expect(originalCall.inbound, equals(updatedCall.inbound));
      expect(originalCall.isActive, equals(updatedCall.isActive));
      expect(originalCall.locked, equals(updatedCall.locked));
      expect(originalCall.receptionID, equals(updatedCall.receptionID));
      expect(originalCall.state, equals(updatedCall.state));
    });
  }

  /**
   *
   */
  static Future inboundUnansweredCall(model.OriginationContext context,
      Receptionist receptionist, Customer caller) async {
    log.info('Caller dials the reception at ${context.dialplan}');
    await caller.dial(context.dialplan);

    log.info('Waiting for the call to be queued');
    await receptionist.waitFor(
        eventType: event.Key.queueJoin, timeoutSeconds: 10);
    log.info('Fetching call list');
    final Iterable<model.Call> orignalCallQueue =
        await receptionist.callFlowControl.callList();
    expect(orignalCallQueue.length, equals(1));
    expect(orignalCallQueue.first.assignedTo, equals(model.User.noId));

    log.info('Performing state reload');
    await receptionist.callFlowControl.stateReload();
    log.info('Comparing reloaded list with original list');
    Iterable<model.Call> reloadedList =
        await receptionist.callFlowControl.callList();
    _validateCallLists(orignalCallQueue, reloadedList);
    log.info('Test Succeeded');
  }

  /**
   *
   */
  static Future inboundAnsweredCall(model.OriginationContext context,
      Receptionist receptionist, Customer caller) async {
    log.info('Caller dials the reception at ${context.dialplan}');
    await caller.dial(context.dialplan);
    log.info('Receptionist hunt down the call');
    await receptionist.huntNextCall();
    log.info('Receptionist got call');
    final Iterable<model.Call> orignalCallQueue =
        await receptionist.callFlowControl.callList();
    expect(orignalCallQueue.length, equals(1));
    expect(orignalCallQueue.first.assignedTo, equals(receptionist.user.id));

    log.info('Performing state reload');
    await receptionist.callFlowControl.stateReload();
    log.info('Comparing reloaded list with original list');
    Iterable<model.Call> reloadedList =
        await receptionist.callFlowControl.callList();
    _validateCallLists(orignalCallQueue, reloadedList);
    log.info('Test Succeeded');
  }

  /**
   *
   */
  static Future inboundParkedCall(model.OriginationContext context,
      Receptionist receptionist, Customer caller) async {
    log.info('Caller dials the reception at ${context.dialplan}');
    await caller.dial(context.dialplan);
    log.info('Receptionist hunt down the call');
    final model.Call assignedCall = await receptionist.huntNextCall();
    log.info('Receptionist got call');
    log.info('Receptionist parks call');
    await receptionist.park(assignedCall, waitForEvent: true);
    await receptionist.waitForPhoneHangup();
    log.info('Fetching original call list');
    final Iterable<model.Call> orignalCallQueue =
        await receptionist.callFlowControl.callList();
    expect(orignalCallQueue.length, equals(1));
    expect(orignalCallQueue.first.assignedTo, equals(receptionist.user.id));

    log.info('Performing state reload');
    await receptionist.callFlowControl.stateReload();
    log.info('Comparing reloaded list with original list');
    _validateCallLists(
        orignalCallQueue, await receptionist.callFlowControl.callList());
    log.info('Test Succeeded');
  }

  /**
   *
   */
  static Future inboundUnparkedCall(model.OriginationContext context,
      Receptionist receptionist, Customer caller) async {
    log.info('Caller dials the reception at ${context.dialplan}');
    await caller.dial(context.dialplan);
    log.info('Receptionist hunts down the call');
    model.Call assignedCall = await receptionist.huntNextCall();

    log.info('Receptionist got call $assignedCall');
    log.info('Receptionist parks call');
    await receptionist.park(assignedCall, waitForEvent: true);
    log.info('Receptionist picks up call again');
    receptionist.eventStack.clear();
    try {
      await receptionist.pickup(assignedCall, waitForEvent: true);
    } catch (_) {
      fail('${assignedCall.toJson()}');
    }

    log.info('Fetching original call list');
    final Iterable<model.Call> orignalCallQueue =
        await receptionist.callFlowControl.callList();
    expect(orignalCallQueue.length, equals(1));
    expect(orignalCallQueue.first.assignedTo, equals(receptionist.user.id));
    expect(orignalCallQueue.first.state, equals(model.CallState.speaking));

    log.info('Performing state reload');
    await receptionist.callFlowControl.stateReload();
    log.info('Comparing reloaded list with original list');
    _validateCallLists(
        orignalCallQueue, await receptionist.callFlowControl.callList());

    log.info('Test Succeeded');
  }

  /**
   *
   */
  static Future outboundUnansweredCall(model.OriginationContext context,
      Receptionist receptionist, Customer callee) async {
    log.info('Receptionist dials the callee at ${callee.extension}');
    final model.Call outboundCall =
        await receptionist.originate(callee.extension, context);

    log.info('Fetching original call list');
    Iterable<model.Call> orignalCallQueue =
        await receptionist.callFlowControl.callList();
    expect(orignalCallQueue.length, equals(1));
    expect(orignalCallQueue.first.assignedTo, equals(receptionist.user.id));
    expect(orignalCallQueue, contains(outboundCall));

    log.info('Performing state reload');
    await receptionist.callFlowControl.stateReload();
    log.info('Comparing reloaded list with original list');
    _validateCallLists(
        orignalCallQueue, await receptionist.callFlowControl.callList());

    log.info('Test Succeeded');
  }

  /**
   *
   */
  static Future outboundAnsweredCall(model.OriginationContext context,
      Receptionist receptionist, Customer callee) async {
    log.info('Receptionist dials the callee at ${callee.extension}');
    model.Call outboundCall =
        await receptionist.originate(callee.extension, context);

    await callee.waitForInboundCall();
    await callee.pickupCall();
    await receptionist.waitFor(eventType: event.Key.callPickup);
    log.info('Fetching original call list');
    final Iterable<model.Call> orignalCallQueue =
        await receptionist.callFlowControl.callList();

    expect(orignalCallQueue.length, equals(1));
    expect(orignalCallQueue.first.assignedTo, equals(receptionist.user.id));
    expect(orignalCallQueue, contains(outboundCall));

    log.info('Performing state reload');
    await receptionist.callFlowControl.stateReload();
    log.info('Comparing reloaded list with original list');
    _validateCallLists(
        orignalCallQueue, await receptionist.callFlowControl.callList());

    log.info('Test Succeeded');
  }

  /**
   *
   */
  static Future transferredCalls(model.OriginationContext context,
      Receptionist receptionist, Customer caller, Customer callee) async {
    log.info('Caller dials the reception at ${context.dialplan}');
    await caller.dial(context.dialplan);
    log.info('Receptionist hunt down the call');
    final model.Call inboundCall = await receptionist.huntNextCall();

    log.info('Receptionist parks call');
    await receptionist.park(inboundCall, waitForEvent: true);

    log.info('Receptionist dials the callee at ${callee.extension}');

    model.Call outboundCall =
        await receptionist.originate(callee.extension, context);

    await callee.waitForInboundCall();
    await callee.pickupCall();
    await receptionist.waitFor(
        eventType: event.Key.callPickup, callID: outboundCall.ID);
    log.info('Fetching original call list');
    Iterable<model.Call> orignalCallQueue =
        await receptionist.callFlowControl.callList();

    expect(orignalCallQueue.length, equals(2));
    expect(orignalCallQueue.first.assignedTo, equals(receptionist.user.id));
    expect(orignalCallQueue.last.assignedTo, equals(receptionist.user.id));
    expect(orignalCallQueue, contains(outboundCall));

    log.info('Performing state reload');
    await receptionist.callFlowControl.stateReload();
    log.info('Comparing reloaded list with original list');
    _validateCallLists(
        orignalCallQueue, await receptionist.callFlowControl.callList());

    log.info('Transferring call');
    await receptionist.transferCall(outboundCall, inboundCall);
    await receptionist.waitFor(eventType: event.Key.callTransfer);
    log.info('Fetching original call list');

    await receptionist.callFlowControl
        .callList()
        .then((Iterable<model.Call> calls) {
      expect(calls.length, equals(2));
      expect(calls.first.assignedTo, equals(receptionist.user.id));
      expect(calls, contains(outboundCall));
      orignalCallQueue = calls;
    });

    log.info('Performing state reload');
    await receptionist.callFlowControl.stateReload();
    log.info('Comparing reloaded list with original list');
    _validateCallLists(
        orignalCallQueue, await receptionist.callFlowControl.callList());

    log.info('Test Succeeded');
  }
}
