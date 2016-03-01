part of or_test_fw;

abstract class UserState {
  static Logger log = new Logger('$libraryName.CallFlowControl.UserState');

  /**
  * Tests if the receptionist receives an error when trying originate
  * a new call while in call.
   */
  static Future originateForbidden(
      Receptionist receptionist, Customer caller, Customer callee) async {
    String receptionNumber = '12340005';

    final Model.OriginationContext context = new Model.OriginationContext()
      ..contactUuid = 4
      ..dialplan = '12340001'
      ..receptionUuid = 1;

    log.info('Caller dials the reception at $receptionNumber');
    await caller.dial(receptionNumber);
    log.info('Receptionist tries to hunt down the next call');
    final Model.Call firstCall = await receptionist.huntNextCall();
    expect(firstCall, isNotNull);
    expect(firstCall.ID, isNot(Model.Call.noID));

    log.info('Receptionist tries to orignate a new call to $callee');
    expect(receptionist.originate(callee.extension, context),
        throwsA(new isInstanceOf<Storage.ClientError>()));
    await receptionist.hangUp(firstCall);
    await receptionist.waitForPhoneHangup();

    log.info('$receptionist tries to orignate a new call to $callee again');
    final Model.Call outboundCall =
        await receptionist.originate(callee.extension, context);
    await receptionist.hangUp(outboundCall);
    await receptionist.waitForPhoneHangup();
  }

  /**
   * Tests if the receptionist receives an error when trying to pick
   * up a second call while in call.
   */
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

    await receptionist.hangUp(firstCall);
    await receptionist.waitForPhoneHangup();
    await receptionist.pickup(secondCall, waitForEvent: true);
    await receptionist.hangUp(secondCall);
    await receptionist.waitForPhoneHangup();
  }
}
