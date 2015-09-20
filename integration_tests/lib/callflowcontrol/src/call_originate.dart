part of or_test_fw;

abstract class Originate {

  ///Internal logger.
  static Logger _log = new Logger('$libraryName.CallFlowControl.Originate');

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

  /**
   * Tests the system behaviour whenever a channel being established to an
   * agent that has disabled autoanswer and rejects the call.
   * Expected behaviour is that the server should detect the reject and send
   * a [Storage.ClientError].
   */
  static Future originationOnAgentCallRejected(Receptionist receptionist, Customer customer) {
    int contactID = 4;
    int receptionID = 1;

    Completer callRejectExpectation = new Completer();

    return receptionist.autoAnswer(false).then((_) {
      /// Asynchronous origination.
      receptionist
          .originate(customer.extension, contactID, receptionID)
          .then(callRejectExpectation.complete)
          .catchError(callRejectExpectation.completeError);
    })
        .then((_) => receptionist.waitForInboundCall())
        .then((_) => _log.info('Receptionist $receptionist rejects the call'))
        .then((_) => receptionist._phone.hangupAll())
        .then((_) => expect(callRejectExpectation.future,
            throwsA(new isInstanceOf<Storage.ClientError>())));
  }

  /**
   * Tests the system behaviour whenever a channel being established to an
   * agent that has disabled autoanswer and never accepts the call.
   * Expected behaviour is that the server should detect the reject and send
   * a [Storage.ClientError].
   */
  static Future originationOnAgentAutoAnswerDisabled
   (Receptionist receptionist, Customer customer) {
    int contactID = 4;
    int receptionID = 1;

    Completer callRejectExpectation = new Completer();

    return receptionist.autoAnswer(false).then((_) {
      /// Asynchronous origination.
      receptionist
          .originate(customer.extension, contactID, receptionID)
          .then((_) => callRejectExpectation.complete())
          .catchError(callRejectExpectation.completeError);
    })
        .then((_) => receptionist.waitForInboundCall())
        .then((_) => _log.info('Receptionist $receptionist ignores the call'))
        .then((_) => expect(callRejectExpectation.future,
            throwsA(new isInstanceOf<Storage.ClientError>())));
  }

  /**
   * Origination to a number that is known (by the call-flow-control server) to
   * be forbidden.
   */
  static void originationToForbiddenNumber(Receptionist receptionist) {
    String receptionNumber = 'X';
    int contactID = 4;
    int receptionID = 1;

    return expect(
        receptionist.originate(receptionNumber, contactID, receptionID),
        throwsA(new isInstanceOf<Storage.ClientError>()));
  }

  /**
   * Test if the system is able to originate to another peer.
   */
  static Future originationToPeer(Receptionist receptionist, Customer customer) {
    int contactID = 4;
    int receptionID = 1;

    return receptionist
        .originate(customer.extension, contactID, receptionID)
        .then((_) => customer.waitForInboundCall());
  }

  /**
   * Check that only one call is present in the call list when performing an
   * outbound dial.
   */
  static Future originationToPeerCheckforduplicate(Receptionist receptionist, Customer customer) {
    int contactID = 4;
    int receptionID = 1;

    return receptionist
        .originate(customer.extension, contactID, receptionID)
        .then((_) => customer.waitForInboundCall())
        .then((_) => CallList._validateListLength(receptionist.callFlowControl, 1));
  }
}
