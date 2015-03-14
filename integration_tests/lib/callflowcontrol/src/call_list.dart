part of or_test_fw;

/**
 * Tests for the call listing interface.
 */
abstract class CallList {
  static Logger log = new Logger('CallFlowControl.List');

  static Future callPresence() {
     Receptionist receptionist = ReceptionistPool.instance.aquire();
     Customer     customer     = CustomerPool.instance.aquire();

     String       reception = "12340004";

     Future verifyCallIsInList (Model.Call call) =>
         receptionist.callFlowControl.callList()
           .then((Iterable<Model.Call> calls) =>
               calls.firstWhere((Model.Call listCall) =>
                   listCall.ID == call.ID));

     return
       Future.wait([receptionist.initialize(),
                    customer.initialize()])
       .then((_) => log.info ('Customer ${customer.name} dials ${reception}.'))
       .then((_) => customer.dial (reception))
       .then((_) => log.info ('Receptionist ${receptionist.user.name} waits for call.'))
       .then((_) => receptionist.waitForCall()
         .then(verifyCallIsInList))
       .then((_) => log.info ('Customer ${customer.name} hangs up all current calls.'))
       .then((_) => customer.hangupAll())
       .then((_) => log.info ('Receptionist ${receptionist.user.name} awaits call hangup.'))
       .then((_) => receptionist.waitFor(eventType:"call_hangup"))
       .whenComplete(() {
         log.info ('Test complete, cleaning up.');
         ReceptionistPool.instance.release(receptionist);
         CustomerPool.instance.release(customer);
         return Future.wait([receptionist.teardown(),customer.teardown()]);
       });

   }
}
