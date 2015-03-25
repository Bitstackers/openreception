part of or_test_fw;

abstract class Pickup {
  static Logger log = new Logger('$libraryName.CallFlowControl.Pickup');


  static Future pickupUnspecified(Receptionist receptionist, Customer customer) {
    int receptionID = 3;
    String receptionNumber = '1234000$receptionID';
    Model.Call inboundCall = null;

    return Future.wait([])
    .then((_) => log.info ('Customer ${customer.name} dials ${receptionNumber}'))
    .then((_) => customer.dial (receptionNumber))
    .then((_) => log.info ('Receptionist ${receptionist.user.name} waits for call.'))
    .then((_) => receptionist.waitForCall()
      .then((Model.Call call) => inboundCall = call))
    .then((_) => receptionist.pickupNext (waitForEvent: false))
    .then((_) => receptionist.waitFor(eventType: Model.EventJSONKey.callPickup,
                                      callID: inboundCall.ID)
      .then((Model.CallPickup pickupEvent) {
        expect (pickupEvent.call.assignedTo, equals(receptionist.user.ID));
        expect (pickupEvent.call.state, equals(Model.CallState.Speaking));
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
    .then((_) => receptionist.waitFor(eventType: Model.EventJSONKey.callPickup,
                                      callID: inboundCall.ID)
      .then((Model.CallPickup pickupEvent) {
        expect (pickupEvent.call.assignedTo, equals(receptionist.user.ID));
        expect (pickupEvent.call.state, equals(Model.CallState.Speaking));
    }));
  }

  static void pickupNonExistingCall(Receptionist receptionist) {
    return expect(receptionist.callFlowControl.pickupNext(),
        throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  static void pickupNonExistingSpecificCall(Receptionist receptionist) {
    return expect(receptionist.callFlowControl.pickup('nothing'),
        throwsA(new isInstanceOf<Storage.NotFound>()));
  }
}