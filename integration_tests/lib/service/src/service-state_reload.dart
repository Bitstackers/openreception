part of or_test_fw;

abstract class StateReload {
  static Logger log = new Logger('$libraryName.CallFlowControl.UserState');

  static void _validateCallLists(
      Iterable<Model.Call> list1, Iterable<Model.Call> list2) {
    log.info('List 1:\n  ${list1.map((c) => c.toJson()).join('\n  ')}');
    log.info('List 2:\n  ${list2.map((c) => c.toJson()).join('\n  ')}');

    expect(list1.length, equals(list2.length));

    list2.forEach((Model.Call updatedCall) {
      Model.Call originalCall =
          list1.firstWhere((Model.Call c) => c.ID == updatedCall.ID);

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

  static Future inboundUnansweredCall(
      Receptionist receptionist, Customer caller) async {
    String receptionNumber = '12340001';

    Iterable<Model.Call> orignalCallQueue;

    return Future
        .wait([])
        .then((_) => log.info('Caller dials the reception at $receptionNumber'))
        .then((_) => caller.dial(receptionNumber))
        .then((_) => log.info('Waiting for the call to be queued'))
        .then((_) => receptionist.waitFor(eventType: Event.Key.queueJoin))
        .then((_) => log.info('Fetching call list'))
        .then((_) => receptionist.callFlowControl
                .callList()
                .then((Iterable<Model.Call> calls) {
              expect(calls.length, equals(1));
              expect(calls.first.assignedTo, equals(Model.User.noID));
              orignalCallQueue = calls;
            }))
        .then((_) => log.info('Performing state reload'))
        .then((_) => receptionist.callFlowControl.stateReload())
        .then((_) => log.info('Comparing reloaded list with original list'))
        .then((_) => receptionist.callFlowControl.callList().then(
            (Iterable<Model.Call> calls) =>
                _validateCallLists(orignalCallQueue, calls)))
        .then((_) => log.info('Test Succeeded'));
  }

  static Future inboundAnsweredCall(
      Receptionist receptionist, Customer caller) {
    String receptionNumber = '12340001';

    Iterable<Model.Call> orignalCallQueue;

    return Future
        .wait([])
        .then((_) => log.info('Caller dials the reception at $receptionNumber'))
        .then((_) => caller.dial(receptionNumber))
        .then((_) => log.info('Receptionist hunt down the call'))
        .then((_) => receptionist.huntNextCall())
        .then((_) => log.info('Receptionist got call'))
        .then((_) => receptionist.callFlowControl
                .callList()
                .then((Iterable<Model.Call> calls) {
              expect(calls.length, equals(1));
              expect(calls.first.assignedTo, equals(receptionist.user.id));
              orignalCallQueue = calls;
            }))
        .then((_) => log.info('Performing state reload'))
        .then((_) => receptionist.callFlowControl.stateReload())
        .then((_) => log.info('Comparing reloaded list with original list'))
        .then((_) => receptionist.callFlowControl.callList().then(
            (Iterable<Model.Call> calls) =>
                _validateCallLists(orignalCallQueue, calls)))
        .then((_) => log.info('Test Succeeded'));
  }

  static Future inboundParkedCall(
      Receptionist receptionist, Customer caller) async {
    String receptionNumber = '12340001';

    log.info('Caller dials the reception at $receptionNumber');
    await caller.dial(receptionNumber);
    log.info('Receptionist hunt down the call');
    final Model.Call assignedCall = await receptionist.huntNextCall();
    log.info('Receptionist got call');
    log.info('Receptionist parks call');
    await receptionist.park(assignedCall, waitForEvent: true);
    await receptionist.waitForPhoneHangup();
    log.info('Fetching original call list');
    final Iterable<Model.Call> orignalCallQueue =
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

  static Future inboundUnparkedCall(
      Receptionist receptionist, Customer caller) async {
    String receptionNumber = '12340001';

    log.info('Caller dials the reception at $receptionNumber');
    await caller.dial(receptionNumber);
    log.info('Receptionist hunts down the call');
    Model.Call assignedCall = await receptionist.huntNextCall();

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
    final Iterable<Model.Call> orignalCallQueue =
        await receptionist.callFlowControl.callList();
    expect(orignalCallQueue.length, equals(1));
    expect(orignalCallQueue.first.assignedTo, equals(receptionist.user.id));
    expect(orignalCallQueue.first.state, equals(Model.CallState.Speaking));

    log.info('Performing state reload');
    await receptionist.callFlowControl.stateReload();
    log.info('Comparing reloaded list with original list');
    _validateCallLists(
        orignalCallQueue, await receptionist.callFlowControl.callList());

    log.info('Test Succeeded');
  }

  static Future outboundUnansweredCall(
      Receptionist receptionist, Customer callee) {
    Iterable<Model.Call> orignalCallQueue;
    Model.Call outboundCall;
    final Model.OriginationContext context = new Model.OriginationContext()
      ..contactUuid = 4
      ..dialplan = '12340001'
      ..receptionUuid = 1;

    return Future
        .wait([])
        .then((_) =>
            log.info('Receptionist dials the callee at ${callee.extension}'))
        .then((_) => receptionist
            .originate(callee.extension, context)
            .then((Model.Call call) => outboundCall = call))
        .then((_) => log.info('Fetching original call list'))
        .then((_) => receptionist.callFlowControl
                .callList()
                .then((Iterable<Model.Call> calls) {
              expect(calls.length, equals(1));
              expect(calls.first.assignedTo, equals(receptionist.user.id));
              expect(calls, contains(outboundCall));
              orignalCallQueue = calls;
            }))
        .then((_) => log.info('Performing state reload'))
        .then((_) => receptionist.callFlowControl.stateReload())
        .then((_) => log.info('Comparing reloaded list with original list'))
        .then((_) => receptionist.callFlowControl.callList().then(
            (Iterable<Model.Call> calls) =>
                _validateCallLists(orignalCallQueue, calls)))
        .then((_) => log.info('Test Succeeded'));
  }

  static Future outboundAnsweredCall(
      Receptionist receptionist, Customer callee) {
    Iterable<Model.Call> orignalCallQueue;
    Model.Call outboundCall;
    final Model.OriginationContext context = new Model.OriginationContext()
      ..contactUuid = 4
      ..dialplan = '12340001'
      ..receptionUuid = 1;

    return Future
        .wait([])
        .then((_) =>
            log.info('Receptionist dials the callee at ${callee.extension}'))
        .then((_) => receptionist
            .originate(callee.extension, context)
            .then((Model.Call call) => outboundCall = call))
        .then((_) => callee.waitForInboundCall())
        .then((_) => callee.pickupCall())
        .then((_) => receptionist.waitFor(eventType: Event.Key.callPickup))
        .then((_) => log.info('Fetching original call list'))
        .then((_) => receptionist.callFlowControl
                .callList()
                .then((Iterable<Model.Call> calls) {
              expect(calls.length, equals(1));
              expect(calls.first.assignedTo, equals(receptionist.user.id));
              expect(calls, contains(outboundCall));
              orignalCallQueue = calls;
            }))
        .then((_) => log.info('Performing state reload'))
        .then((_) => receptionist.callFlowControl.stateReload())
        .then((_) => log.info('Comparing reloaded list with original list'))
        .then((_) => receptionist.callFlowControl.callList().then(
            (Iterable<Model.Call> calls) =>
                _validateCallLists(orignalCallQueue, calls)))
        .then((_) => log.info('Test Succeeded'));
  }

  static Future transferredCalls(
      Receptionist receptionist, Customer caller, Customer callee) {
    final String receptionNumber = '12340001';
    final Model.OriginationContext context = new Model.OriginationContext()
      ..contactUuid = 4
      ..dialplan = '12340001'
      ..receptionUuid = 1;

    Iterable<Model.Call> orignalCallQueue;

    Model.Call inboundCall;
    Model.Call outboundCall;

    return Future
        .wait([])
        .then((_) => log.info('Caller dials the reception at $receptionNumber'))
        .then((_) => caller.dial(receptionNumber))
        .then((_) => log.info('Receptionist hunt down the call'))
        .then((_) => receptionist
            .huntNextCall()
            .then((Model.Call call) => inboundCall = call))
        .then((_) => log.info('Receptionist parks call'))
        .then((_) => receptionist.park(inboundCall, waitForEvent: true))
        .then((_) =>
            log.info('Receptionist dials the callee at ${callee.extension}'))
        .then((_) => receptionist
            .originate(callee.extension, context)
            .then((Model.Call call) => outboundCall = call))
        .then((_) => callee.waitForInboundCall())
        .then((_) => callee.pickupCall())
        .then((_) => receptionist.waitFor(
            eventType: Event.Key.callPickup, callID: outboundCall.ID))
        .then((_) => log.info('Fetching original call list'))
        .then((_) => receptionist.callFlowControl
                .callList()
                .then((Iterable<Model.Call> calls) {
              expect(calls.length, equals(2));
              expect(calls.first.assignedTo, equals(receptionist.user.id));
              expect(calls, contains(outboundCall));
              orignalCallQueue = calls;
            }))
        .then((_) => log.info('Performing state reload'))
        .then((_) => receptionist.callFlowControl.stateReload())
        .then((_) => log.info('Comparing reloaded list with original list'))
        .then((_) => receptionist.callFlowControl.callList().then(
            (Iterable<Model.Call> calls) =>
                _validateCallLists(orignalCallQueue, calls)))
        .then((_) => receptionist.transferCall(outboundCall, inboundCall))
        .then((_) => receptionist.waitFor(eventType: Event.Key.callTransfer))
        .then((_) => log.info('Fetching original call list'))
        .then((_) =>
            receptionist.callFlowControl.callList().then((Iterable<Model.Call> calls) {
              expect(calls.length, equals(2));
              expect(calls.first.assignedTo, equals(receptionist.user.id));
              expect(calls, contains(outboundCall));
              orignalCallQueue = calls;
            }))
        .then((_) => log.info('Performing state reload'))
        .then((_) => receptionist.callFlowControl.stateReload())
        .then((_) => log.info('Comparing reloaded list with original list'))
        .then((_) => receptionist.callFlowControl.callList().then((Iterable<Model.Call> calls) => _validateCallLists(orignalCallQueue, calls)))
        .then((_) => log.info('Test Succeeded'));
  }
}
