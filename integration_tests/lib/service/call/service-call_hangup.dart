part of openreception_tests.service.call;

/**
 * Tests for the hangup interface on CallFlowControl server.
 */
abstract class Hangup {
  static Logger log = new Logger('$_namespace.call.hangup');

  /**
   * Test for the presence of hangup events when a call is hung up.
   */
  static Future eventPresence(model.ReceptionDialplan rdp,
      Receptionist receptionist, Customer caller) async {
    log.info('Customer ${caller.name} dials ${rdp.extension}');
    await caller.dial(rdp.extension);

    log.info('Receptionist ${receptionist.user.name} waits for call');
    await receptionist.waitForCallOffer();
    await new Future.delayed(new Duration(seconds: 1));

    log.info('Customer ${caller.name} hangs up all current calls');
    await caller.hangupAll();
    log.info('Receptionist ${receptionist} awaits call hangup');
    await receptionist.waitFor(eventType: event.Key.callHangup);
    log.info('Caller ${caller} awaits phone hangup.');
    await caller.waitForHangup();
  }

  /**
   * Test for the presence of a hangup cause.
   */
  static Future hangupCause(model.ReceptionDialplan rdp,
      Receptionist receptionist, Customer caller) async {
    log.info('Customer ${caller.name} dials ${rdp.extension}');
    await caller.dial(rdp.extension);
    log.info('Receptionist ${receptionist.user.name} waits for call.');
    await receptionist.waitForCallOffer();
    await new Future.delayed(new Duration(seconds: 1));
    log.info('Customer ${caller.name} hangs up all current calls.');
    await caller.hangupAll();
    log.info('Receptionist ${receptionist.user.name} awaits call hangup.');
    event.CallHangup e =
        await receptionist.waitFor(eventType: event.Key.callHangup);

    log.info(e.toJson());
    expect(e.hangupCause, isNotEmpty);

    log.info('Caller ${caller} awaits phone hangup.');
    await caller.waitForHangup();
  }

  /**
   * Tests the hangup interface using a valid call id.
   */
  static Future interfaceCallFound(model.ReceptionDialplan rdp,
      Receptionist receptionist, Customer customer) async {
    log.info('Customer ${customer.name} dials ${rdp.extension}');
    await customer.dial(rdp.extension);
    await receptionist.huntNextCall();
    await receptionist.waitForInboundCall();

    log.info('Customer ${customer.name} hangs up all current calls.');
    await customer.hangupAll();
    log.info('Receptionist ${receptionist.user.name} awaits call hangup.');
    await receptionist.waitFor(eventType: event.Key.callHangup);
  }

  /**
   * Tests the hangup interface using an invalid call id.
   */
  static Future interfaceCallNotFound(ServiceAgent sa) async {
    await expect(sa.callflow.hangup(model.Call.noID),
        throwsA(new isInstanceOf<storage.NotFound>()));
  }
}
