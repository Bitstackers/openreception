part of or_test_fw;

abstract class Originate {
  static Logger log = new Logger('$libraryName.CallFlowControl.Originate');

  //TODO
  //static Future  originationToLookedUNumber()

  static Future originationToHostedNumber(Receptionist receptionist) {

    String receptionNumber = '12340005';
    int contactID = 4;
    int receptionID = 1;

    return receptionist.originate(receptionNumber, contactID, receptionID)
        .then((_) => receptionist.waitFor(eventType: Model.EventJSONKey.callOffer)
          .then((Model.CallOffer event) {
            //TODO: Assert that callerID is the correct one
            expect (event.call.inbound, isTrue);
    }));
  }
  static void originationToForbiddenNumber(Receptionist receptionist) {

    String receptionNumber = 'X';
    int contactID = 4;
    int receptionID = 1;

    return expect(receptionist.originate(receptionNumber, contactID, receptionID),
          throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  static Future originationToPeer(Receptionist receptionist, String peerUri) {
    int contactID = 4;
    int receptionID = 1;

    return receptionist.originate(peerUri, contactID, receptionID)
        .then((_) => receptionist.waitForInboundCall());
  }
}