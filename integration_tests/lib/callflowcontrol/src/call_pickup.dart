part of or_test_fw;

abstract class Pickup {
  static Logger log = new Logger('$libraryName.CallFlowControl.Pickup');

  /**
   * Tests the case where a receptionist tries to pick up a locked call.
   */
  static Future pickupLockedCall(Receptionist receptionist, Customer customer) {
    int receptionID = 2;
    String receptionNumber = '1234000$receptionID';

    return Future.wait([])
    .then((_) => log.info ('Customer ${customer.name} dials ${receptionNumber}'))
    .then((_) => customer.dial (receptionNumber))
    .then((_) => log.info ('Receptionist ${receptionist.user.name} waits for call.'))
    .then((_) => receptionist.waitFor(eventType: Event.Key.callLock)
      .then((Event.CallLock lockEvent) {
        Model.Call lockedCall = lockEvent.call;
        return expect (receptionist.pickup(lockedCall), throwsA(new isInstanceOf<Storage.Conflict>()));
    }));
  }

  /**
   * Tests the case where a receptionist tries to pick up a locked call.
   */
  static Future pickupCallTwice(Receptionist receptionist, Customer customer) {
    int receptionID = 2;
    String receptionNumber = '1234000$receptionID';

    return Future.wait([])
    .then((_) => log.info ('Customer ${customer.name} dials ${receptionNumber}'))
    .then((_) => customer.dial (receptionNumber))
    .then((_) => log.info ('Receptionist ${receptionist.user.name} waits for call.'))
    .then((_) => receptionist.huntNextCall()
      .then((Model.Call receivedCall) {
        log.info ('Receptionist ${receptionist.user.name} got call $receivedCall.');
        log.info ('Receptionist ${receptionist.user.name} retrieves the call information from the server.');
        return expect (receptionist.pickup(receivedCall), throwsA(new isInstanceOf<Storage.ClientError>()));
    }));
  }

  static Future pickupAllocatedCall(Receptionist receptionist, Receptionist receptionist2, Customer customer) {
    int receptionID = 2;
    String receptionNumber = '1234000$receptionID';

    return Future.wait([])
    .then((_) => log.info ('Customer ${customer.name} dials ${receptionNumber}'))
    .then((_) => customer.dial (receptionNumber))
    .then((_) => log.info ('Receptionist ${receptionist.user.name} hunts call.'))
    .then((_) => receptionist.huntNextCall().then((Model.Call call) {
      return expect (receptionist2.pickup(call), throwsA(new isInstanceOf<Storage.Forbidden>()));
    }))
    .whenComplete(() => log.info('Test done'));
  }

  static Future pickupRace(Receptionist receptionist, Receptionist receptionist2, Customer customer) {
    int receptionID = 4;
    String receptionNumber = '12340004';

    Completer c1 = new Completer();
    Completer c2 = new Completer();

    return Future.wait([])
    .then((_) => log.info ('Customer ${customer.name} dials ${receptionNumber}'))
    .then((_) => customer.dial (receptionNumber))
    .then((_) => log.info ('Receptionist ${receptionist.user.name} hunts call.'))
    .then((_) => receptionist.waitForCall()
      .then((Model.Call offeredCall) {
        log.info ('Receptionist 1 and 2 both tries to get the call');
        receptionist.pickup(offeredCall)
        .then((Model.Call call) {
          log.info('Receptionist 1 got call $call');
          c1.complete();
        })
        .catchError((error, stackTrace) {
          if (error is Storage.Forbidden) {
            log.info('Receptionist 1 got call Forbidden');
            c1.complete();
          } else {
            c1.completeError(error, stackTrace);
          }
        });

      receptionist2.pickup(offeredCall)
        .then((Model.Call call) {
          log.info('Receptionist 2 got call $call');
          c2.complete();
        })
        .catchError((error, stackTrace) {
          if (error is Storage.Forbidden) {
            log.info('Receptionist 2 got call Forbidden');
            c2.complete();
          } else {
            c2.completeError(error, stackTrace);
          }
        });

      return Future.wait([c1.future, c2.future])
        .then((_) => receptionist.callFlowControl.get(offeredCall.ID)
          .then((Model.Call pickedUpCall) {
            expect([receptionist.user.ID, receptionist2.user.ID ]
                   .contains(pickedUpCall.assignedTo), isTrue);
          }));
      }))
    .whenComplete(() => log.info('Test done'));
  }

  static Future pickupUnspecified(Receptionist receptionist, Customer customer) {
    int receptionID = 2;
    String receptionNumber = '1234000$receptionID';

    return Future.wait([])
    .then((_) => log.info ('Customer ${customer.name} dials ${receptionNumber}'))
    .then((_) => customer.dial (receptionNumber))
    .then((_) => log.info ('Receptionist ${receptionist.user.name} waits for call.'))
    .then((_) => receptionist.huntNextCall()
      .then((Model.Call receivedCall) {
        log.info ('Receptionist ${receptionist.user.name} got call $receivedCall.');
        log.info ('Receptionist ${receptionist.user.name} retrieves the call information from the server.');
        return receptionist.callFlowControl.get (receivedCall.ID)
          .then((Model.Call remoteCall) {
          expect (remoteCall.assignedTo, equals(receptionist.user.ID));
          expect (remoteCall.state, equals(Model.CallState.Speaking));
        });
    }));
  }

  static Future pickupSpecified(Receptionist receptionist, Customer customer) {
    int receptionID = 4;
    String receptionNumber = '1234000$receptionID';
    Model.Call inboundCall = null;

    return Future.wait([])
    .then((_) => log.info ('Customer ${customer.name} dials ${receptionNumber}'))
    .then((_) => customer.dial (receptionNumber))
    .then((_) => log.info ('Receptionist ${receptionist.user.name} waits for call.'))
    .then((_) => receptionist.waitForCall()
      .then((Model.Call call) => inboundCall = call))
    .then((_) => receptionist.pickup (inboundCall, waitForEvent: false))
    .then((_) => receptionist.waitFor(eventType: Event.Key.callPickup,
                                      callID: inboundCall.ID)
      .then((Event.CallPickup pickupEvent) {
        expect (pickupEvent.call.assignedTo, equals(receptionist.user.ID));
        expect (pickupEvent.call.state, equals(Model.CallState.Speaking));
    }));
  }

  static void pickupNonExistingCall(Receptionist receptionist) {
    return expect(receptionist.callFlowControl.pickup('nothing'),
        throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  static Future pickupEventInboundCall(Receptionist receptionist, Customer customer) {
    int receptionID = 2;
    String receptionNumber = '1234000$receptionID';

    return Future.wait([])
    .then((_) => log.info ('Customer ${customer.name} dials ${receptionNumber}'))
    .then((_) => customer.dial (receptionNumber))
    .then((_) => log.info ('Receptionist ${receptionist.user.name} hunts call.'))
    .then((_) => receptionist.huntNextCall().then((Model.Call call) =>
      receptionist.waitFor(callID: call.ID, eventType: Event.Key.callPickup)))
    .whenComplete(() => log.info('Test done'));
  }

  static Future pickupEventOutboundCall(Receptionist receptionist, Customer customer) {
    Model.Call outboundCall;
    return Future.wait([])
    .then((_) => log.info ('Receptionist dials contact'))
    .then((_) => receptionist.originate(customer.extension, 1, 2)
      .then((Model.Call newCall) {
        outboundCall = newCall;
        log.info('$receptionist got new call $outboundCall');
      }))
    .then((_) => customer.waitForInboundCall())
    .then((_) => log.info('$customer got inbound call'))
    .then((_) => customer.pickupCall())
    .then((_) => receptionist.waitFor(eventType: Event.Key.callPickup, timeoutSeconds: 2, callID: outboundCall.ID))
    .whenComplete(() => log.info('Test done'));
  }
}