part of or_test_fw;

abstract class UserState {

  static Logger log = new Logger('$libraryName.CallFlowControl.UserState');

  static Future originateForbidden(Receptionist receptionist,
                                Customer caller,
                                Customer callee) {
    String receptionNumber = '12340005';

    Model.Call firstCall;
    final Model.OriginationContext context = new Model.OriginationContext()
      ..contactId = 4
      ..dialplan = '12340001'
      ..receptionId = 1;

    return Future.wait([])
      .then((_) => log.info ('Caller dials the reception at $receptionNumber'))
      .then((_) => caller.dial(receptionNumber))
      .then((_) => log.info ('Receptionist tries to hunt down the next call'))
      .then((_) => receptionist.huntNextCall()
          .then((Model.Call call) {
            firstCall = call;
            expect(firstCall, isNotNull);
            expect(firstCall.ID, isNot(Model.Call.noID));
          }))
      .then((_) => log.info ('Receptionist tries to orignate a new call to $callee'))
      .then((_) =>
        expect (receptionist.originate(callee.extension,context),
          throwsA(new isInstanceOf<Storage.ClientError>())));
  }

  static Future pickupForbidden(Receptionist receptionist,
                                Customer caller,
                                Customer second_caller) {
    String receptionNumber = '12340005';

    Model.Call firstCall;
    Model.Call secondCall;

    return Future.wait([])
      .then((_) => log.info ('Caller dials the reception at $receptionNumber'))
      .then((_) => caller.dial(receptionNumber))
      .then((_) => log.info ('Receptionist tries to hunt down the next call'))
      .then((_) => receptionist.huntNextCall()
        .then((Model.Call call) => firstCall = call))
      .then((_) => receptionist.eventStack.clear())
      .then((_) => log.info ('Second caller dials the reception at $receptionNumber'))
      .then((_) => second_caller.dial(receptionNumber))
      .then((_) => log.info ('Receptionist waits second call'))
      .then((_) => receptionist.waitForCall()
        .then((Model.Call call) => secondCall = call))
      .then((_) => log.info ('Receptionist tries to pick up second call $secondCall'))
      .then((_) =>
        expect (receptionist.pickup(secondCall),
          throwsA(new isInstanceOf<Storage.ClientError>())));
  }
}