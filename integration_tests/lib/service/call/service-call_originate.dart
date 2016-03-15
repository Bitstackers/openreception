part of openreception_tests.service.call;

abstract class Originate {
  ///Internal logger.
  static Logger _log = new Logger('$_namespace.CallFlowControl.Originate');

  //TODO
  //static Future  originationToLookedUNumber()

  static Future originationToHostedNumber(Receptionist receptionist) async {
    final model.OriginationContext context = new model.OriginationContext()
      ..contactId = 4
      ..dialplan = '12340004'
      ..receptionId = 4;

    await receptionist.originate('12340005', context);

    final event.CallOffer e =
        await receptionist.waitFor(eventType: event.Key.callOffer);

    expect(e.call.inbound, isTrue);
    expect(e.call.callerID, equals(receptionist.user.name));
  }

  /**
   * Tests the system behaviour whenever a channel being established to an
   * agent that has disabled autoanswer and rejects the call.
   * Expected behaviour is that the server should detect the reject and send
   * a [storage.ClientError].
   */
  static Future originationOnAgentCallRejected(
      Receptionist receptionist, Customer customer) async {
    final model.OriginationContext context = new model.OriginationContext()
      ..contactId = 4
      ..dialplan = '12340001'
      ..receptionId = 1;

    await receptionist.autoAnswer(false);

    /// Asynchronous origination.
    final Future origination =
        receptionist.originate(customer.extension, context);

    await receptionist.waitForInboundCall();
    _log.info('Receptionist $receptionist rejects the call');
    await receptionist.phoneHangupAll();
    await expect(origination, throwsA(new isInstanceOf<storage.ClientError>()));
  }

  /**
   * Tests the system behaviour whenever a channel being established to an
   * agent that has disabled autoanswer and never accepts the call.
   * Expected behaviour is that the server should detect the reject and send
   * a [storage.ClientError].
   */
  static Future originationOnAgentAutoAnswerDisabled(
      Receptionist receptionist, Customer customer) async {
    final model.OriginationContext context = new model.OriginationContext()
      ..contactId = 4
      ..dialplan = '12340001'
      ..receptionId = 1;

    await receptionist.autoAnswer(false);

    /// Asynchronous origination.
    Future origination = receptionist
        .originate(customer.extension, context)
        .timeout(new Duration(seconds: 30));
    await receptionist.waitForInboundCall();
    _log.info('Receptionist $receptionist ignores the incoming channel');
    await expect(origination, throwsA(new isInstanceOf<storage.ClientError>()));
  }

  /**
   * Origination to a number that is known (by the call-flow-control server) to
   * be forbidden.
   */
  static void originationToForbiddenNumber(Receptionist receptionist) {
    final model.OriginationContext context = new model.OriginationContext()
      ..contactId = 4
      ..dialplan = '12340001'
      ..receptionId = 1;

    return expect(receptionist.originate('X', context),
        throwsA(new isInstanceOf<storage.ClientError>()));
  }

  /**
   * Test if the system is able to originate to another peer.
   */
  static Future originationToPeer(
      Receptionist receptionist, Customer customer) async {
    final model.OriginationContext context = new model.OriginationContext()
      ..contactId = 4
      ..dialplan = '12340001'
      ..receptionId = 1;

    await receptionist.originate(customer.extension, context);
    phonio.Call call = await customer.waitForInboundCall();
    expect(call.callerID, equals(customer.phone.defaultAccount.username));
  }

  /**
   * Test if the system tags the callId to the channel.
   */
  static Future originationWithCallContext(
      Receptionist receptionist, Customer customer) async {
    final String callId = new DateTime.now().millisecondsSinceEpoch.toString();

    await customer.autoAnswer(false);
    model.Call call = await receptionist.callFlowControl.originate(
        customer.extension,
        new model.OriginationContext()
          ..callId = callId
          ..contactId = 4
          ..receptionId = 1
          ..dialplan = '12340001');

    await customer.waitForInboundCall();
    await customer.pickupCall();
    await new Future.delayed(new Duration(seconds: 1));
    Map channel = await receptionist.callFlowControl.channelMap(call.channel);

    expect(channel['variables'][pbxKey.ORPbxKey.contextCallId], equals(callId));
  }

  /**
   * Check that only one call is present in the call list when performing an
   * outbound dial.
   */
  static Future originationToPeerCheckforduplicate(
      Receptionist receptionist, Customer customer) {
    final model.OriginationContext context = new model.OriginationContext()
      ..contactId = 4
      ..dialplan = '12340001'
      ..receptionId = 1;
    return receptionist
        .originate(customer.extension, context)
        .then((_) => customer.waitForInboundCall())
        .then((_) =>
            CallList._validateListLength(receptionist.callFlowControl, 1));
  }
}
