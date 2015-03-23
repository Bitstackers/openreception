part of or_test_fw;

abstract class Transfer {
    static Logger log = new Logger('$libraryName.CallFlowControl.Transfer');

    static Future transferParkedInboundCall() {
      Receptionist receptionist = ReceptionistPool.instance.aquire();
      Customer     caller       = CustomerPool.instance.aquire();
      Customer     callee       = CustomerPool.instance.aquire();

      Model.Call inboundCall;
      Model.Call outboundCall;

      String reception   = "12340003";
      int    receptionID = 1;
      int    contactID   = 2;
      return
        Future.wait([receptionist.initialize(),
                     caller.initialize(),
                     callee.initialize()])
        .then((_) => log.info ('Disable autoanswer for ${callee.name}'))
        .then((_) => callee.autoAnswer(false))
        .then((_) => receptionist.autoAnswer(true))
        .then((_) => log.info ('Customer ${caller.name} dials ${reception}'))
        .then((_) => caller.dial (reception))

        .then((_) => log.info ('Receptionist ${receptionist.user.name} waits for call.'))
        .then((_) => receptionist.waitForCall()
         .then((Model.Call call) => inboundCall = call))
        .then((_) => log.info ('Receptionist ${receptionist} tries to pick up call $inboundCall'))
        .then((_) => receptionist.pickup(inboundCall)
          .then((Model.Call receivedCall) {
             expect (inboundCall.ID, equals(receivedCall.ID));
             log.info ('Receptionist ${receptionist} got call $receivedCall');
          }))
        .then((_) => receptionist.waitForInboundCall())
        .then((_) => receptionist.waitFor(eventType: Model.EventJSONKey.callPickup))
        .then((_) => receptionist.eventStack.clear())
        .then((_) => log.info ('Receptionist ${receptionist.user.name} parks call $inboundCall.'))
        .then((_) => receptionist.park (inboundCall))
        .then((_) => receptionist.waitFor(eventType: Model.EventJSONKey.callPark, callID: inboundCall.ID))
        .then((_) => receptionist.waitForPhoneHangup())
        .then((_) => receptionist.originate(callee.extension, contactID, receptionID)
          .then((Model.Call call) {
            log.info('Outbound call: $call');
          }))
        .then((_) => callee.waitForInboundCall())
        .then((_) => callee.pickupCall())
        .then((_) => receptionist.waitFor(eventType: Model.EventJSONKey.callPickup)
            .then((Model.CallPickup event) {
              outboundCall = event.call;
              log.info('Receptionist ${receptionist} picked up outbound call: $outboundCall');
              expect(outboundCall.receptionID, equals(receptionID));
              expect(outboundCall.assignedTo, equals(receptionist.user.ID));
            }))
        .then((_) => log.info ('Receptionist ${receptionist.user.name} transfers call $outboundCall to $inboundCall.'))
        .then((_) => receptionist.transferCall(inboundCall, outboundCall))
        .then((_) => log.info ('Receptionist ${receptionist.user.name} transferred call $outboundCall to $inboundCall.'))
        .then((_) => receptionist.waitFor(eventType : Model.EventJSONKey.callTransfer))
        .then((_) => log.info ('Waiting for receptionist ${receptionist.user.name}\'s phone to hang up'))
        .then((_) => receptionist.waitForPhoneHangup())
        .then((_) => log.info ('Caller ${caller} hangs up'))
        .then((_) => caller.hangupAll())
        .then((_) => log.info ('Caller ${caller} waits for hang up'))
        .then((_) => caller.waitForHangup())
        .then((_) => log.info ('Callee ${callee} waits for hang up'))
        .then((_) => callee.waitForHangup())
        .then((_) => log.info ('Test complete. Cleaning up'))
        .catchError(log.shout)
        .whenComplete(() {
          ReceptionistPool.instance.release(receptionist);
          CustomerPool.instance.release(caller);
          CustomerPool.instance.release(callee);
          return Future.wait(
              [receptionist.teardown(),
               caller.teardown(),
               callee.teardown()]);
        });
    }

    static Future transferParkedOutboundCall() {

      Receptionist receptionist = ReceptionistPool.instance.aquire();
      Customer     caller       = CustomerPool.instance.aquire();
      Customer     callee       = CustomerPool.instance.aquire();

      Model.Call inboundCall;
      Model.Call outboundCall;

      String reception   = "12340003";
      int    receptionID = 1;
      int    contactID   = 2;

      return
        Future.wait([receptionist.initialize(),
                     caller.initialize(),
                     callee.initialize()])
        .then((_) => log.info ('Disable autoanswer for ${callee.name}'))
        .then((_) => callee.autoAnswer(false))
        .then((_) => receptionist.autoAnswer(true))
        .then((_) => log.info ('Customer ${caller.name} dials ${reception}'))
        .then((_) => caller.dial (reception))

        .then((_) => log.info ('Receptionist ${receptionist.user.name} waits for call.'))
        .then((_) => receptionist.waitForCall()
         .then((Model.Call call) => inboundCall = call))
        .then((_) => log.info ('Receptionist ${receptionist} tries to pick up call $inboundCall'))
        .then((_) => receptionist.pickup(inboundCall)
          .then((Model.Call receivedCall) {
             expect (inboundCall.ID, equals(receivedCall.ID));
             log.info ('Receptionist ${receptionist} got call $receivedCall');
          }))
        .then((_) => receptionist.waitForInboundCall())
        .then((_) => receptionist.waitFor(eventType: Model.EventJSONKey.callPickup))
        .then((_) => receptionist.eventStack.clear())
        .then((_) => log.info ('Receptionist ${receptionist.user.name} parks call $inboundCall.'))
        .then((_) => receptionist.park (inboundCall))
        .then((_) => receptionist.waitFor(eventType: Model.EventJSONKey.callPark, callID: inboundCall.ID))
        .then((_) => receptionist.waitForPhoneHangup())
        .then((_) => receptionist.eventStack.clear())
        .then((_) => receptionist.originate(callee.extension, contactID, receptionID)
          .then((Model.Call call) {
            log.info('Outbound call: $call');
          }))
        .then((_) => callee.waitForInboundCall())
        .then((_) => callee.pickupCall())
        .then((_) => receptionist.waitFor(eventType: Model.EventJSONKey.callPickup)
            .then((Model.CallPickup event) {
              outboundCall = event.call;
              log.info('Receptionist ${receptionist} picked up outbound call: $outboundCall');
              expect(outboundCall.receptionID, equals(receptionID));
              expect(outboundCall.assignedTo, equals(receptionist.user.ID));
            }))
        .then((_) => log.info ('Receptionist ${receptionist.user.name} parks call $outboundCall.'))
        .then((_) => receptionist.park (outboundCall))
        .then((_) => receptionist.waitFor(eventType: Model.EventJSONKey.callPark, callID: outboundCall.ID))
        .then((_) => receptionist.waitForPhoneHangup())
        .then((_) => receptionist.eventStack.clear())
        .then((_) => log.info ('Receptionist ${receptionist.user.name} pickup the inbound call $inboundCall again'))
        .then((_) => receptionist.pickup(inboundCall)
          .then((Model.Call receivedCall) {
             expect (inboundCall.ID, equals(receivedCall.ID));
             log.info ('Receptionist ${receptionist} got call $receivedCall');
             return;
          }))
        .then((_) => receptionist.waitForInboundCall())
        .then((_) => receptionist.waitFor(eventType: Model.EventJSONKey.callPickup))
        .then((_) => receptionist.eventStack.clear())
        .then((_) => log.info ('Receptionist ${receptionist.user.name} transfers call $inboundCall to $outboundCall.'))
        .then((_) => receptionist.transferCall(outboundCall, inboundCall))
        .then((_) => log.info ('Receptionist ${receptionist.user.name} transferred call $inboundCall to $outboundCall.'))
        .then((_) => receptionist.waitFor(eventType : Model.EventJSONKey.callTransfer))
        .then((_) => log.info ('Waiting for receptionist ${receptionist.user.name}\'s phone to hang up'))
        .then((_) => receptionist.waitForPhoneHangup())
        .then((_) => log.info ('Caller ${caller} hangs up'))
        .then((_) => caller.hangupAll())
        .then((_) => log.info ('Caller ${caller} waits for hang up'))
        .then((_) => caller.waitForHangup())
        .then((_) => log.info ('Callee ${callee} waits for hang up'))
        .then((_) => callee.waitForHangup())
        .then((_) => log.info ('Test complete. Cleaning up'))
        .catchError(log.shout)
        .whenComplete(() {
          ReceptionistPool.instance.release(receptionist);
          CustomerPool.instance.release(caller);
          CustomerPool.instance.release(callee);
          return Future.wait(
              [receptionist.teardown(),
               caller.teardown(),
               callee.teardown()]);
        });
    }

}


