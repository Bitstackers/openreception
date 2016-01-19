part of or_test_fw;

abstract class UserState {
  static Logger log = new Logger('$libraryName.CallFlowControl.UserState');

  static Future originateForbidden(
      Receptionist receptionist, Customer caller, Customer callee) async {
    String receptionNumber = '12340005';

    final Model.OriginationContext context = new Model.OriginationContext()
      ..contactId = 4
      ..dialplan = '12340001'
      ..receptionId = 1;

    log.info('Caller dials the reception at $receptionNumber');
    await caller.dial(receptionNumber);
    log.info('Receptionist tries to hunt down the next call');
    final Model.Call firstCall = await receptionist.huntNextCall();
    expect(firstCall, isNotNull);
    expect(firstCall.ID, isNot(Model.Call.noID));

    log.info('Receptionist tries to orignate a new call to $callee');
    expect(receptionist.originate(callee.extension, context),
        throwsA(new isInstanceOf<Storage.ClientError>()));
  }

  static Future pickupForbidden(Receptionist receptionist, Customer caller,
      Customer second_caller) async {
    String receptionNumber = '12340005';

    log.info('Caller dials the reception at $receptionNumber');
    await caller.dial(receptionNumber);
    log.info('Receptionist tries to hunt down the next call');
    final Model.Call firstCall = await receptionist.huntNextCall();
    log.info('$receptionist got $firstCall');
    receptionist.eventStack.clear();
    log.info('Second caller dials the reception at $receptionNumber');
    await second_caller.dial(receptionNumber);

    log.info('Receptionist waits second call');
    final Model.Call secondCall = await receptionist.waitForCall();

    log.info('Receptionist tries to pick up second call $secondCall');
    expect(receptionist.pickup(secondCall),
        throwsA(new isInstanceOf<Storage.ClientError>()));
  }
}
