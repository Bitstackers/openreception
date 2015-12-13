part of or_test_fw;

/**
 * Tests for the hangup interface on CallFlowControl server.
 */
abstract class Hangup {

  static Logger log = new Logger('$libraryName.CallFlowControl.Hangup');

  /**
   * Test for the presence of hangup events when a call is hung up.
   */
  static Future eventPresence(Receptionist receptionist,
                              Customer     caller) {

    String       reception = "12340003";
    return
      Future.wait([])
      .then((_) => log.info ('Customer ${caller.name} dials ${reception}'))
      .then((_) => caller.dial (reception))
      .then((_) => log.info ('Receptionist ${receptionist.user.name} waits for call.'))
      .then((_) => receptionist.waitForCall())
      .then((_) => new Future.delayed(new Duration(seconds: 1)))
      .then((_) => log.info ('Customer ${caller.name} hangs up all current calls.'))
      .then((_) => caller.hangupAll())
      .then((_) => log.info ('Receptionist ${receptionist.user.name} awaits call hangup.'))
      .then((_) => receptionist.waitFor(eventType:"call_hangup"))
      .then((_) => log.info ('Caller ${caller} awaits phone hangup.'))
      .then((_) => caller.waitForHangup());
  }

  /**
   * Test for the presence of a hangup cause.
   */
  static Future hangupCause(Receptionist receptionist,
                              Customer     caller) async {

    String       reception = "12340003";

    log.info ('Customer ${caller.name} dials ${reception}');
    await caller.dial (reception);
    log.info ('Receptionist ${receptionist.user.name} waits for call.');
    await receptionist.waitForCall();
    await new Future.delayed(new Duration(seconds: 1));
    log.info ('Customer ${caller.name} hangs up all current calls.');
    await caller.hangupAll();
    log.info ('Receptionist ${receptionist.user.name} awaits call hangup.');
    Event.CallHangup event =
        await receptionist.waitFor(eventType:Event.Key.callHangup);

    log.info(event.toJson());
    expect(event.hangupCause, isNotEmpty);

    log.info ('Caller ${caller} awaits phone hangup.');
    await caller.waitForHangup();
  }

  /**
   * Tests the hangup interface using a valid call id.
   */
  static Future interfaceCallFound(Receptionist receptionist,
                                   Customer     customer) {
    String       reception = "12340004";

    return Future.wait([])
      .then((_) => log.info ('Customer ${customer.name} dials ${reception}'))
      .then((_) => customer.dial (reception))
      .then((_) => receptionist.huntNextCall( ))
      .then((_) => new Future.delayed(new Duration(seconds: 2)))
      .then((_) => receptionist.waitForInboundCall())
      .then((_) => log.info ('Customer ${customer.name} hangs up all current calls.'))
      .then((_) => customer.hangupAll())
      .then((_) => log.info ('Receptionist ${receptionist.user.name} awaits call hangup.'))
      .then((_) => receptionist.waitFor(eventType:"call_hangup"));
  }

  /**
   * Tests the hangup interface using an invalid call id.
   */
  static Future interfaceCallNotFound(Service.CallFlowControl callflow) {
    return callflow.hangup(Model.Call.noID);
  }
}
