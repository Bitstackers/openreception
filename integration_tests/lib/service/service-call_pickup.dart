part of openreception_tests.service;

abstract class Pickup {
  static Logger log = new Logger('$_namespace.CallFlowControl.Pickup');

  /**
   * Tests the case where a receptionist tries to pick up a locked call.
   */
  static Future pickupLockedCall(Receptionist receptionist, Customer customer) {
    int receptionID = 2;
    String receptionNumber = '1234000$receptionID';

    return Future
        .wait([])
        .then((_) =>
            log.info('Customer ${customer.name} dials ${receptionNumber}'))
        .then((_) => customer.dial(receptionNumber))
        .then((_) =>
            log.info('Receptionist ${receptionist.user.name} waits for call.'))
        .then((_) => receptionist
                .waitFor(eventType: event.Key.callLock)
                .then((event.CallLock lockEvent) {
              model.Call lockedCall = lockEvent.call;
              return expect(receptionist.pickup(lockedCall),
                  throwsA(new isInstanceOf<storage.Conflict>()));
            }));
  }

  /**
   * Tests the case where a receptionist tries to pick up a locked call.
   */
  static Future pickupCallTwice(Receptionist receptionist, Customer customer) {
    int receptionID = 2;
    String receptionNumber = '1234000$receptionID';

    return Future
        .wait([])
        .then((_) =>
            log.info('Customer ${customer.name} dials ${receptionNumber}'))
        .then((_) => customer.dial(receptionNumber))
        .then((_) =>
            log.info('Receptionist ${receptionist.user.name} waits for call.'))
        .then(
            (_) => receptionist.huntNextCall().then((model.Call receivedCall) {
                  log.info(
                      'Receptionist ${receptionist.user.name} got call $receivedCall.');
                  log.info(
                      'Receptionist ${receptionist.user.name} retrieves the call information from the server.');
                  return expect(receptionist.pickup(receivedCall),
                      throwsA(new isInstanceOf<storage.ClientError>()));
                }));
  }

  static Future pickupAllocatedCall(Receptionist receptionist,
      Receptionist receptionist2, Customer customer) {
    int receptionID = 2;
    String receptionNumber = '1234000$receptionID';

    return Future
        .wait([])
        .then((_) =>
            log.info('Customer ${customer.name} dials ${receptionNumber}'))
        .then((_) => customer.dial(receptionNumber))
        .then((_) =>
            log.info('Receptionist ${receptionist.user.name} hunts call.'))
        .then((_) => receptionist.huntNextCall().then((model.Call call) {
              return expect(receptionist2.pickup(call),
                  throwsA(new isInstanceOf<storage.Forbidden>()));
            }))
        .whenComplete(() => log.info('Test done'));
  }

  static Future pickupRace(Receptionist receptionist,
      Receptionist receptionist2, Customer customer) {
    String receptionNumber = '12340004';

    Completer c1 = new Completer();
    Completer c2 = new Completer();

    return Future
        .wait([])
        .then((_) =>
            log.info('Customer ${customer.name} dials ${receptionNumber}'))
        .then((_) => customer.dial(receptionNumber))
        .then((_) =>
            log.info('Receptionist ${receptionist.user.name} hunts call.'))
        .then((_) => receptionist.waitForCall().then((model.Call offeredCall) {
              log.info('Receptionist 1 and 2 both tries to get the call');
              receptionist.pickup(offeredCall).then((model.Call call) {
                log.info('Receptionist 1 got call $call');
                c1.complete();
              }).catchError((error, stackTrace) {
                if (error is storage.Forbidden) {
                  log.info('Receptionist 1 got call Forbidden');
                  c1.complete();
                } else {
                  c1.completeError(error, stackTrace);
                }
              });

              receptionist2.pickup(offeredCall).then((model.Call call) {
                log.info('Receptionist 2 got call $call');
                c2.complete();
              }).catchError((error, stackTrace) {
                if (error is storage.Forbidden) {
                  log.info('Receptionist 2 got call Forbidden');
                  c2.complete();
                } else {
                  c2.completeError(error, stackTrace);
                }
              });

              return Future.wait([c1.future, c2.future]).then((_) =>
                  receptionist.callFlowControl
                      .get(offeredCall.ID)
                      .then((model.Call pickedUpCall) {
                    expect(
                        [receptionist.user.id, receptionist2.user.id]
                            .contains(pickedUpCall.assignedTo),
                        isTrue);
                  }));
            }))
        .whenComplete(() => log.info('Test done'));
  }

  static Future pickupUnspecified(
      Receptionist receptionist, Customer customer) {
    int receptionID = 2;
    String receptionNumber = '1234000$receptionID';

    return Future
        .wait([])
        .then((_) =>
            log.info('Customer ${customer.name} dials ${receptionNumber}'))
        .then((_) => customer.dial(receptionNumber))
        .then((_) =>
            log.info('Receptionist ${receptionist.user.name} waits for call.'))
        .then(
            (_) => receptionist.huntNextCall().then((model.Call receivedCall) {
                  log.info(
                      'Receptionist ${receptionist.user.name} got call $receivedCall.');
                  log.info(
                      'Receptionist ${receptionist.user.name} retrieves the call information from the server.');
                  return receptionist.callFlowControl
                      .get(receivedCall.ID)
                      .then((model.Call remoteCall) {
                    expect(remoteCall.assignedTo, equals(receptionist.user.id));
                    expect(remoteCall.state, equals(model.CallState.Speaking));
                  });
                }));
  }

  static Future pickupSpecified(Receptionist receptionist, Customer customer) {
    int receptionID = 4;
    String receptionNumber = '1234000$receptionID';
    model.Call inboundCall = null;

    return Future
        .wait([])
        .then((_) =>
            log.info('Customer ${customer.name} dials ${receptionNumber}'))
        .then((_) => customer.dial(receptionNumber))
        .then((_) =>
            log.info('Receptionist ${receptionist.user.name} waits for call.'))
        .then((_) => receptionist
            .waitForCall()
            .then((model.Call call) => inboundCall = call))
        .then((_) => receptionist.pickup(inboundCall, waitForEvent: false))
        .then((_) => receptionist
                .waitFor(
                    eventType: event.Key.callPickup, callID: inboundCall.ID)
                .then((event.CallPickup pickupEvent) {
              expect(pickupEvent.call.assignedTo, equals(receptionist.user.id));
              expect(pickupEvent.call.state, equals(model.CallState.Speaking));
            }));
  }

  static void pickupNonExistingCall(Receptionist receptionist) {
    return expect(receptionist.callFlowControl.pickup('nothing'),
        throwsA(new isInstanceOf<storage.NotFound>()));
  }

  static Future pickupEventInboundCall(
      Receptionist receptionist, Customer customer) {
    int receptionID = 2;
    String receptionNumber = '1234000$receptionID';

    return Future
        .wait([])
        .then((_) =>
            log.info('Customer ${customer.name} dials ${receptionNumber}'))
        .then((_) => customer.dial(receptionNumber))
        .then((_) =>
            log.info('Receptionist ${receptionist.user.name} hunts call.'))
        .then((_) => receptionist.huntNextCall().then((model.Call call) =>
            receptionist.waitFor(
                callID: call.ID, eventType: event.Key.callPickup)))
        .whenComplete(() => log.info('Test done'));
  }

  static Future pickupEventOutboundCall(
      Receptionist receptionist, Customer customer) {
    model.Call outboundCall;
    final model.OriginationContext context = new model.OriginationContext()
      ..contactId = 4
      ..dialplan = '12340001'
      ..receptionId = 1;
    return Future
        .wait([])
        .then((_) => log.info('Receptionist dials contact'))
        .then((_) => receptionist
                .originate(customer.extension, context)
                .then((model.Call newCall) {
              outboundCall = newCall;
              log.info('$receptionist got new call $outboundCall');
            }))
        .then((_) => customer.waitForInboundCall())
        .then((_) => log.info('$customer got inbound call'))
        .then((_) => customer.pickupCall())
        .then((_) => receptionist.waitFor(
            eventType: event.Key.callPickup,
            timeoutSeconds: 2,
            callID: outboundCall.ID))
        .whenComplete(() => log.info('Test done'));
  }
}
