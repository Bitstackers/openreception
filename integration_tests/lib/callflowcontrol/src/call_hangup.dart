part of or_test_fw;

/**
 * Tests for the hangup interface on CallFlowControl server.
 */
abstract class Hangup {

  static Logger log = new Logger('$libraryName.CallFlowControl.Hangup');

  /**
   * Test for the presence of hangup events when a call is hung up.
   */
  static Future eventPresence() {
    Receptionist receptionist = ReceptionistPool.instance.aquire();
    Customer     customer     = CustomerPool.instance.aquire();

    String       reception = "12340003";
    return
      Future.wait([receptionist.initialize(),
                   customer.initialize()])
      .then((_) => log.info ('Customer ${customer.name} dials ${reception}'))
      .then((_) => customer.dial (reception))
      .then((_) => log.info ('Receptionist ${receptionist.user.name} waits for call.'))
      .then((_) => receptionist.waitForCall())
       .then((_) => log.info ('Customer ${customer.name} hangs up all current calls.'))
       .then((_) => customer.hangupAll())
       .then((_) => log.info ('Receptionist ${receptionist.user.name} awaits call hangup.'))
       .then((_) => receptionist.waitFor(eventType:"call_hangup"))
      .whenComplete(() {
        ReceptionistPool.instance.release(receptionist);
        CustomerPool.instance.release(customer);
        return Future.wait([receptionist.teardown(),customer.teardown()]);
      });
  }

  /**
   * Tests the hangup interface using a valid call id.
   */
  static Future interfaceCallFound() {
    Receptionist receptionist = ReceptionistPool.instance.aquire();
    Customer     customer     = CustomerPool.instance.aquire();
    Model.Call   inboundCall  = null;

    String       reception = "12340003";

    return Future.wait([receptionist.initialize(),
                            customer.initialize()])
        .then((_) => log.info ('Customer ${customer.name} dials ${reception}'))
        .then((_) => customer.dial (reception))
        .then((_) => receptionist.waitForCall()
          .then((Model.Call call) => inboundCall = call))
        .then((_) => receptionist.pickup(inboundCall))
       .then((_) => log.info ('Receptionist ${receptionist.user.name} awaits incoming call.'))
       .then((_) => receptionist.waitForInboundCall())
       .then((_) => log.info ('Customer ${customer.name} hangs up all current calls.'))
       .then((_) => customer.hangupAll())
       .then((_) => log.info ('Receptionist ${receptionist.user.name} awaits call hangup.'))
       .then((_) => receptionist.waitFor(eventType:"call_hangup"))
       .whenComplete(() {
          ReceptionistPool.instance.release(receptionist);
          CustomerPool.instance.release(customer);
          return Future.wait([receptionist.teardown(),customer.teardown()]);
        });
  }

  /**
   * Tests the hangup interface using an invalid call id.
   */
  static Future interfaceCallNotFound(Service.CallFlowControl callflow) {
    return callflow.hangup(Model.Call.nullCallID);
  }
}
