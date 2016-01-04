part of or_test_fw;

abstract class Transfer {
  static Logger log = new Logger('$libraryName.CallFlowControl.Transfer');

  static Future transferParkedInboundCall(
      Receptionist receptionist,
      Customer caller,
      Customer callee,
      Model.OriginationContext context) async {
    log.info('Disable autoanswer for ${callee.name}');
    await callee.autoAnswer(false);
    log.info('Customer ${caller} dials ${context.dialplan}');
    await caller.dial(context.dialplan);
    log.info('Receptionist $receptionist waits for call.');
    final Model.Call inboundCall = await receptionist.huntNextCall();
    log.info('$receptionist got call $inboundCall');
    await receptionist.waitForInboundCall();
    receptionist.eventStack.clear();
    log.info('$receptionist parks call $inboundCall.');
    await receptionist.park(inboundCall, waitForEvent: true);

    log.info('$receptionist awaits phone disconnect.');
    await receptionist.waitForPhoneHangup();

    receptionist.eventStack.clear();
    final Model.Call outboundCall =
        await receptionist.originate(callee.extension, context);
    log.info('Outbound call: $outboundCall');

    await callee.waitForInboundCall();
    await callee.pickupCall();
    log.info('$receptionist picked up outbound call: $outboundCall');
    expect(outboundCall.receptionID, equals(context.receptionId));
    expect(outboundCall.assignedTo, equals(receptionist.user.ID));

    log.info('$receptionist transfers call $outboundCall to $inboundCall.');
    await receptionist.transferCall(inboundCall, outboundCall);
    log.info('$receptionist transferred call $outboundCall to $inboundCall.');
    await receptionist.waitFor(eventType: Event.Key.callTransfer);
    log.info('Waiting for ${receptionist} phone to hang up');
    await receptionist.waitForPhoneHangup();

    log.info('Expecting both caller and callee to have an active call');
    expect(caller.currentCall, isNotNull);
    expect(callee.currentCall, isNotNull);
    log.info('Caller ${caller} hangs up');
    await caller.hangupAll();
    log.info('Waiting around for 100ms to avoid race conditions');
    await new Future.delayed(new Duration(milliseconds: 100));
    log.info('Caller ${caller} waits for hang up');
    await caller.waitForHangup();
    log.info('Callee ${callee} waits for hang up');
    await callee.waitForHangup();
    log.info('Test complete.');
  }

  static Future transferParkedOutboundCall(
      Receptionist receptionist,
      Customer caller,
      Customer callee,
      Model.OriginationContext context) async {
    log.info('Disable autoanswer for ${callee.name}');
    await callee.autoAnswer(false);

    log.info('Customer ${caller.name} dials ${context.dialplan}');
    await caller.dial(context.dialplan);
    log.info('${receptionist} waits for call.');

    final Model.Call inboundCall = await receptionist.huntNextCall();
    await receptionist.waitForInboundCall();
    await receptionist.waitFor(eventType: Event.Key.callPickup);
    receptionist.eventStack.clear();
    log.info('${receptionist} parks call $inboundCall.');
    await receptionist.park(inboundCall, waitForEvent: true);
    await receptionist.waitForPhoneHangup();
    receptionist.eventStack.clear();
    final Model.Call outboundCall =
        await receptionist.originate(callee.extension, context);
    log.info('Outbound call: $outboundCall');
    expect(outboundCall.receptionID, equals(context.receptionId));
    expect(outboundCall.assignedTo, equals(receptionist.user.ID));
    await callee.waitForInboundCall();
    await callee.pickupCall();
    await receptionist.waitFor(eventType: Event.Key.callPickup);
    log.info('${receptionist} picked up outbound call: $outboundCall');

    log.info('$receptionist parks call $outboundCall.');
    await receptionist.park(outboundCall, waitForEvent: true);
    await receptionist.waitForPhoneHangup();
    receptionist.eventStack.clear();
    log.info('$receptionist pickup the inbound call $inboundCall again');
    await receptionist.pickup(inboundCall).then((Model.Call receivedCall) {
      expect(inboundCall.ID, equals(receivedCall.ID));
      log.info('Receptionist ${receptionist} got call $receivedCall');
      return;
    });
    receptionist.waitForInboundCall();
    receptionist.waitFor(eventType: Event.Key.callPickup);
    receptionist.eventStack.clear();
    log.info('$receptionist transfers call $inboundCall to $outboundCall.');
    receptionist.transferCall(outboundCall, inboundCall);

    log.info('$receptionist transferred call $inboundCall to $outboundCall.');

    await receptionist.waitFor(eventType: Event.Key.callTransfer);

    log.info('Waiting for $receptionist phone to hang up');
    await receptionist.waitForPhoneHangup();

    log.info('Caller ${caller} hangs up');
    caller.hangupAll();

    log.info('Waiting around for 100ms to avoid race conditions');
    await new Future.delayed(new Duration(milliseconds: 100));

    log.info('Caller ${caller} waits for hang up');
    await caller.waitForHangup();

    log.info('Callee ${callee} waits for hang up');
    await callee.waitForHangup();
    log.info('Test complete.');
  }

  /**
   * Asserts that the call list is of correct length both before and after a
   * transfer.
   */
  static Future inboundCallListLength(
      Receptionist receptionist,
      Customer caller,
      Customer callee,
      Model.OriginationContext context) async {
    log.info('Disable autoanswer for ${callee}');
    await callee.autoAnswer(false);

    log.info('${caller} (caller) dials ${context.dialplan}');
    await caller.dial(context.dialplan);

    log.info('${receptionist} tries to pick up next call');
    final Model.Call inboundCall = await receptionist.huntNextCall();
    log.info('${receptionist} got call $inboundCall');

    receptionist.eventStack.clear();
    log.info('${receptionist} parks call $inboundCall.');
    await receptionist.park(inboundCall, waitForEvent: true);
    await receptionist.waitForPhoneHangup();
    receptionist.eventStack.clear();
    log.info('Checking call list length');

    expect((await receptionist.callFlowControl.callList()).length, equals(1));

    final Model.Call outboundCall =
        await receptionist.originate(callee.extension, context);
    await callee.waitForInboundCall();
    log.info('Checking call list length');
    expect((await receptionist.callFlowControl.callList()).length, equals(2));

    await callee.pickupCall();
    log.info('Checking call list length');
    expect((await receptionist.callFlowControl.callList()).length, equals(2));

    await receptionist
        .waitFor(eventType: Event.Key.callPickup)
        .then((Event.CallPickup event) {
      log.info('${receptionist} picked up outbound call: $outboundCall');
      expect(outboundCall.assignedTo, equals(receptionist.user.ID));
    });
    log.info('${receptionist} parks call $outboundCall.');
    await receptionist.park(outboundCall, waitForEvent: true);
    await receptionist.waitForPhoneHangup();

    log.info('Checking call list length');
    expect((await receptionist.callFlowControl.callList()).length, equals(2));
    receptionist.eventStack.clear();

    log.info('${receptionist} pickup the inbound call $inboundCall again');
    await receptionist.pickup(inboundCall).then((Model.Call receivedCall) {
      expect(inboundCall.ID, equals(receivedCall.ID));
      log.info('${receptionist} got call $receivedCall');
    });
    await receptionist.waitForInboundCall();
    await receptionist.waitFor(eventType: Event.Key.callPickup);
    receptionist.eventStack.clear();
    log.info('${receptionist} transfers call $inboundCall to $outboundCall.');
    await receptionist.transferCall(outboundCall, inboundCall);
    log.info('$receptionist transferred call $inboundCall to $outboundCall.');
    await receptionist.waitFor(eventType: Event.Key.callTransfer);
    log.info('Waiting for ${receptionist} phone to hang up');
    await receptionist.waitForPhoneHangup();
    log.info('Checking call list length');
    expect((await receptionist.callFlowControl.callList()).length, equals(2));
    log.info('Caller ${caller} hangs up');
    await caller.hangupAll();
    log.info('Waiting around for 100ms to avoid race conditions');
    await new Future.delayed(new Duration(milliseconds: 100));
    log.info('Caller ${caller} waits for hang up');
    await caller.waitForHangup();
    log.info('Callee ${callee} waits for hang up');
    await callee.waitForHangup();
    log.info('Checking call list length');
    expect((await receptionist.callFlowControl.callList()).length, equals(0));
    log.info('Test complete.');
  }
}
