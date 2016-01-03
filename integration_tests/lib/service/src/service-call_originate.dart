part of or_test_fw;

abstract class Originate {
  ///Internal logger.
  static Logger _log = new Logger('$libraryName.CallFlowControl.Originate');

  //TODO
  //static Future  originationToLookedUNumber()

  static Future originationToHostedNumber(Receptionist receptionist) async {
    final Model.OriginationContext context = new Model.OriginationContext()
      ..contactId = 4
      ..dialplan = '12340004'
      ..receptionId = 4;

    await receptionist.originate('12340005', context);

    final Event.CallOffer event =
        await receptionist.waitFor(eventType: Event.Key.callOffer);

    //TODO: Assert that callerID is the correct one
    expect(event.call.inbound, isTrue);
  }

  /**
   * Tests the system behaviour whenever a channel being established to an
   * agent that has disabled autoanswer and rejects the call.
   * Expected behaviour is that the server should detect the reject and send
   * a [Storage.ClientError].
   */
  static Future originationOnAgentCallRejected(
      Receptionist receptionist, Customer customer) {
    final Model.OriginationContext context = new Model.OriginationContext()
      ..contactId = 4
      ..dialplan = '12340001'
      ..receptionId = 1;

    Completer callRejectExpectation = new Completer();

    return receptionist.autoAnswer(false).then((_) {
      /// Asynchronous origination.
      receptionist
          .originate(customer.extension, context)
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
  static Future originationOnAgentAutoAnswerDisabled(
      Receptionist receptionist, Customer customer) {
    Completer callRejectExpectation = new Completer();
    final Model.OriginationContext context = new Model.OriginationContext()
      ..contactId = 4
      ..dialplan = '12340001'
      ..receptionId = 1;

    return receptionist.autoAnswer(false).then((_) {
      /// Asynchronous origination.
      receptionist
          .originate(customer.extension, context)
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
    final Model.OriginationContext context = new Model.OriginationContext()
      ..contactId = 4
      ..dialplan = '12340001'
      ..receptionId = 1;

    return expect(receptionist.originate('X', context),
        throwsA(new isInstanceOf<Storage.ClientError>()));
  }

  /**
   * Test if the system is able to originate to another peer.
   */
  static Future originationToPeer(
      Receptionist receptionist, Customer customer) {
    final Model.OriginationContext context = new Model.OriginationContext()
          ..contactId = 4
          ..dialplan = '12340001'
          ..receptionId = 1;

    return receptionist
        .originate(customer.extension, context)
        .then((_) => customer.waitForInboundCall());
  }

  /**
   * Test if the system tags the callId to the channel.
   */
  static Future originationWithCallContext(
      Receptionist receptionist, Customer customer) async {
    final String callId = new DateTime.now().millisecondsSinceEpoch.toString();

    await customer.autoAnswer(false);
    Model.Call call = await receptionist.callFlowControl
        .originate(customer.extension, new Model.OriginationContext()
          ..callId = callId
          ..contactId = 4
          ..receptionId = 1
          ..dialplan = '12340001');

    await customer.waitForInboundCall();
    await customer.pickupCall();
    await new Future.delayed(new Duration(seconds: 1));
    Map channel = await receptionist.callFlowControl.channelMap(call.channel);

    expect(channel['variables'][ORPbxKey.contextCallId], equals(callId));
  }

  /**
   * Check that only one call is present in the call list when performing an
   * outbound dial.
   */
  static Future originationToPeerCheckforduplicate(
      Receptionist receptionist, Customer customer) {
    final Model.OriginationContext context = new Model.OriginationContext()
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
