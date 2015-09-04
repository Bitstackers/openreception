part of or_test_fw;

abstract class Originate {
  static Logger log = new Logger('$libraryName.CallFlowControl.Originate');

  //TODO
  //static Future  originationToLookedUNumber()

  static Future originationToHostedNumber(Receptionist receptionist) {
    String receptionNumber = '12340005';
    int contactID = 4;
    int receptionID = 1;

    return receptionist.originate(receptionNumber, contactID, receptionID).then(
        (_) => receptionist
            .waitFor(eventType: Event.Key.callOffer)
            .then((Event.CallOffer event) {
      //TODO: Assert that callerID is the correct one
      expect(event.call.inbound, isTrue);
    }));
  }

  static Future originationOnAgentCallRejected(Receptionist receptionist) {
    String originationNumber = '12340005';
    int contactID = 4;
    int receptionID = 1;

    Completer callRejectExpectation = new Completer();

    return receptionist.autoAnswer(false).then((_) {
      /// Asynchronous origination.
      receptionist
          .originate(originationNumber, contactID, receptionID)
          .then((_) => callRejectExpectation.complete())
          .catchError(callRejectExpectation.completeError);
    })
        .then((_) => receptionist.waitForInboundCall())
        .then((_) => log.info('Receptionist $receptionist rejects the call'))
        .then((_) => receptionist._phone.hangupAll())
        .then((_) => expect(callRejectExpectation.future,
            throwsA(new isInstanceOf<Storage.ClientError>())));
  }

  static Future originationOnAgentAutoAnswer(Receptionist receptionist) {
    String originationNumber = '12340005';
    int contactID = 4;
    int receptionID = 1;

    Completer callRejectExpectation = new Completer();

    return receptionist.autoAnswer(false).then((_) {
      /// Asynchronous origination.
      receptionist
          .originate(originationNumber, contactID, receptionID)
          .then((_) => callRejectExpectation.complete())
          .catchError(callRejectExpectation.completeError);
    })
        .then((_) => receptionist.waitForInboundCall())
        .then((_) => log.info('Receptionist $receptionist ignores the call'))
        .then((_) => expect(callRejectExpectation.future,
            throwsA(new isInstanceOf<Storage.ClientError>())));
  }

  static void originationToForbiddenNumber(Receptionist receptionist) {
    String receptionNumber = 'X';
    int contactID = 4;
    int receptionID = 1;

    return expect(
        receptionist.originate(receptionNumber, contactID, receptionID),
        throwsA(new isInstanceOf<Storage.ClientError>()));
  }

  static Future originationToPeer(Receptionist receptionist, Customer customer) {
    int contactID = 4;
    int receptionID = 1;

    return receptionist
        .originate(customer.extension, contactID, receptionID)
        .then((_) => receptionist.waitForInboundCall());
  }
}
