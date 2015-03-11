part of or_test_fw;

abstract class IncomingCall {

  static String className = 'IncomingCall';

  static DateTime startTime = null;
  static int nextStep = 1;

  static Customer caller = null;
  static Receptionist receptionist = null;
  static Receptionist receptionist2 = null;
  static Customer callee = null;

  static Model.Call inboundCall = null;

  static Storage.Reception receptionStore = null;
  static Model.Reception currentReception = null;

  String Reception = null;

  static Logger log = new Logger(IncomingCall.className);

  static Future setup() {
    startTime = new DateTime.now();
    nextStep = 1;

    log.finest('Setting up preconditions...');

    log.finest("Requesting a customer (caller)...");
    caller = CustomerPool.instance.aquire();

    log.finest("Requesting a receptionist...");
    receptionist = ReceptionistPool.instance.aquire();


    log.finest("Requesting a second receptionist...");
    receptionist2 = ReceptionistPool.instance.aquire();

    //log.finest("Requesting a customer (callee)...");
    //callee = CustomerPool.instance.aquire();

    log.finest("Select which reception to test...");

    log.finest("Select a reception database connection...");
    receptionStore = new Service.RESTReceptionStore(Config.receptionStoreURI,
        receptionist.authToken, new Transport.Client());

    return receptionist.registerAccount().then((_) =>
           receptionist2.registerAccount());

  }

  static void teardown() {
    log.finest("Cleaning up after test...");
    caller != null ? CustomerPool.instance.release(caller) : null;
    callee != null ? CustomerPool.instance.release(callee) : null;

    receptionist != null ? ReceptionistPool.instance.release(receptionist) : null;
    receptionist2 != null ? ReceptionistPool.instance.release(receptionist2) : null;

  }

  static void step(String message) => log.finest('Step ${nextStep++}: $message');

  static Future Caller_Places_Call(String reception) {
    step('Caller places call to $reception');

    log.finest("Dialling through caller agent...");
    return caller.dial(reception);
  }

  static Future<Phonio.Call> Caller_Hears_Dialtone() {
    step("Caller hears dial-tone...");
    log.finest("Caller agent waits for dial-tone...");
    return caller.waitForOutboundCall();
  }

  /**
   * Simulates the receptionist client waiting for a call to arrive. If no extension is
   * provided, the first call to arrive is returned in the future.
   *
   */
  static Future<Model.Call> Receptionist_Awaits_Call_Offer({String extension: null}) {
    step('Receptionist\'s client waits for "${Model.EventJSONKey.callOffer}"');

    return receptionist.waitFor(eventType: Model.EventJSONKey.callOffer, extension: extension)
      .then((_) {
      Model.CallOffer event = receptionist.eventStack.firstWhere(
            (Model.Event offerEvent) => offerEvent is Model.CallOffer);
        return event.call;
      }) ;
  }

  /**
   * Simulates the receptionist client waiting for the call lock.
   */
  static Future<Model.Call> Receptionist_Awaits_Call_Lock(Model.Call call) {
    step('Receptionist\'s client waits for "${Model.EventJSONKey.callLock}"');

    return receptionist.waitFor(eventType: Model.EventJSONKey.callLock, callID: call.ID)
      .then((_) {
      Model.CallLock event = receptionist.eventStack.firstWhere(
            (Model.Event lockEvent) => lockEvent is Model.CallLock);

              return event.call;
      }) ;
  }

  /**
   * Simulates the receptionist client waiting for the call to unlock.
   */
  static Future<Model.Call> Receptionist_Awaits_Call_Unlock(Model.Call call) {
    step('Call-Flow-Control sends out "${Model.EventJSONKey.callUnlock}"...');

    return receptionist.waitFor(eventType: Model.EventJSONKey.callUnlock, callID: call.ID)
      .then((_) {
      Model.CallUnlock event = receptionist.eventStack.firstWhere(
            (Model.Event lockEvent) => lockEvent is Model.CallUnlock);

              return event.call;
      }) ;
}

  /**
   * Simulates the receptionist client answering a call. Validates the call received
   */
  static Future<Model.Call> Receptionist_Answers(Model.Call call, Model.Reception reception) {
    step('Receptionist answers');

    _validateReception(reception);
    _validateCall(call);

    if (call.greetingPlayed) {
      log.finest('Receptionist gives short greeting: "${reception.shortGreeting}');
    } else {
      log.finest('Receptionist gives full greeting:"${reception.greeting}');
    }

    return receptionist.waitFor(eventType: Model.EventJSONKey.callUnlock, callID: call.ID);
  }

  static void _dumpState(error, stackTrace) {
    log.severe(error, stackTrace);

    throw new StateError('Test failed');
  }

  static void _validateReception(Model.Reception reception) {
    log.finest('FIXME: make _validateReception more elaborate');

    if (reception.greeting.isEmpty) {
      throw new StateError ('Greeting missing from reception');
    }

    if (reception.shortGreeting.isEmpty) {
      throw new StateError ('Short greeting missing from reception');
    }

  }

  static String callInfo(Model.Call call) =>
      '${call.inbound ? 'inbound': 'outbound'} '
          'call with destination ${call.destination}';

  static void _validateCall(Model.Call call) {
    expect(call.assignedTo, equals (receptionist.user.ID));

    log.severe('FIXME: make _validateCall more elaborate');
  }

  static Wait (int milliseconds) =>
      new Future.delayed(new Duration(milliseconds : milliseconds));

  static Future<Model.Call> Call_Announced() {
    step("Receptionist's client waits for 'call_offer'...");

    Future timeoutHandler() {
      log.severe("Call offer didn't arrive from Call-Flow-Control.");
      receptionist.dumpEventStack();
      return new Future.error(new AssertionError());
    }

    return receptionist.waitFor(
        eventType: Model.EventJSONKey.callOffer).timeout(
            new Duration(seconds: 3),
            onTimeout: timeoutHandler).then((Model.CallOffer event) {
      return event.call;
    });
  }

  static Future<Model.Call> Call_Announced_As_Locked() {
    step("Call-Flow-Control sends out 'call_lock'...");

    return receptionist.waitFor(
        eventType: Model.EventJSONKey.callLock).timeout(
            new Duration(seconds: 3),
            onTimeout: () {
      log.severe("No 'call_lock' event arrived from Call-Flow-Control.");
      receptionist.dumpEventStack();
      throw new AssertionError();
    }).then((Model.CallLock event) {
      return event.call;
    });
  }

  static Future<Model.Call> Call_Announced_As_Unlocked() {
    step("Call-Flow-Control sends out 'call_unlock'...");

    return receptionist.waitFor(
        eventType: Model.EventJSONKey.callUnlock).timeout(
            new Duration(seconds: 3),
            onTimeout: () {
      log.severe("No 'call_unlock' event arrived from Call-Flow-Control.");
      receptionist.dumpEventStack();
      throw new AssertionError();
    }).then((Model.CallLock event) {
      return event.call;
    });
  }

  static Future<Model.Reception> Request_Information(int Reception_ID) {
    step(
        "Requesting (updated) information about reception with ID $Reception_ID.");

    return receptionStore.get(Reception_ID).then((Model.Reception reception) {
      step("Received information on reception with ID $Reception_ID.");
      return reception;
    });
  }

  static Future<Model.Call> Offer_To_Pick_Up_Call(Receptionist receptionist,
      Model.Call call) {
    step("Client offers to answer call...");

    return receptionist.pickup(call);
  }

  static Future Call_Allocation_Acknowledgement() {
    step("Receptionist's client waits for 'call_pickup'...");

    return receptionist.waitFor(
        eventType: Model.EventJSONKey.callPickup).then((Model.CallPickup event) {
      if (event.call.assignedTo == receptionist.user.ID) {
        fail(
            'The arrived pickup event was for ${event.call.assignedTo},'
                ' and not for ${receptionist.user.ID} as expected.');
      }

      log.finest('Receptionist picked up call ${callInfo(event.call)}.');
      return (event.call);
    });
  }


  /**
   * https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Indg%C3%A5ende-opkald#variant-ii1-1
   */
  static Future incomingCall_II_1() {
    const String receptionExtension = '12340003';

    return setup()
      .then((_) => Caller_Places_Call (receptionExtension))
      .then((_) => Caller_Hears_Dialtone ())
      .then((_) => step ("FreeSWITCH         ->  FreeSWITCH        [Checks dial-plan.  Result: Queue call.]"))
      .then((_) => step ("FreeSWITCH         ->> Call-Flow-Control [event: call-offer; destination: Reception]"))
      .then((_) => step ("FreeSWITCH: pauses dial-plan processing for # seconds"))
      .then((_) => Call_Announced ())
      .then((_) => step ("Call-Flow-Control  ->  Call-Flow-Control [wait 0.200 s]"))
      .then((_) => Wait(200))
      .then((_) => step ("FreeSWITCH: pauses dial-plan processing for # seconds"))
      .then((_) => step ("Call-Flow-Control  ->  Call-Flow-Control [no responses to call-offer]"))
      .then((_) => step ("Call-Flow-Control  ->> FreeSWITCH        [force-end-pause: <call_ID>]"))
      .then((_) => step ("FreeSWITCH         ->> Call-Flow-Control [queued-unavailable: <call_ID>]"))
      .then((_) => step ("FreeSWITCH         ->> Opkalder          »De har ringet til <reception name>. Vent venligst.«"))
      .then((_) => Call_Announced_As_Locked ())
      .then((_) => step ("Klient-N           ->> Receptionist-N    [Queue: <reception name> (optaget)]"))
      .then((_) => step ("FreeSWITCH->Call-Flow-Control: call queued with dial-tone"))
      .then((_) => step ("FreeSWITCH->Caller: pause music"))
      .then((_) => Call_Announced_As_Unlocked ())
      .then((_) => step ("Client-N->Receptionist-N: Queue: <reception name> (venter)"))
      .then((_) => step ("Receptionist-N->Client-N: state-switch-free"))
      .then((_) => Request_Information (inboundCall.receptionID))
      .then((_) => Offer_To_Pick_Up_Call (receptionist, inboundCall))
      .then((_) => Call_Allocation_Acknowledgement ())
      .then((_) => step ("Call-Flow-Control->FreeSWITCH: connect call to phone-N"))
      .then((_) => Receptionist_Answers (inboundCall, currentReception))
      .catchError((error, stackTrace) => log.shout (error,stackTrace))
      .whenComplete(teardown);
  }

  /**
   * https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Indg%C3%A5ende-opkald#variant-ii2-1
   */
  static Future incomingCall_II_2() {

    const String receptionExtension = '12340003';

    return setup()
      .then((_) => Caller_Places_Call (receptionExtension))
      .then((_) => Caller_Hears_Dialtone ())
      .then((_) => step ("FreeSWITCH         ->  FreeSWITCH        [Checks dial-plan.  Result: Queue call.]"))
      .then((_) => step ("FreeSWITCH         ->> Call-Flow-Control [event: call-offer; destination: Reception]"))
      .then((_) => step ("FreeSWITCH: pauses dial-plan processing for # seconds"))
      .then((_) => Call_Announced ())
      .then((_) => step ("Call-Flow-Control  ->  Call-Flow-Control [wait 0.200 s]"))
      .then((_) => Wait(200))
      .then((_) => step ("Call-Flow-Control  ->  Call-Flow-Control [no responses to call-offer]"))
      .then((_) => step ("Call-Flow-Control  ->> FreeSWITCH        [force-end-pause: <call_ID>]"))
      .then((_) => step ("FreeSWITCH         ->> Call-Flow-Control [queued-unavailable: <call_ID>]"))
      .then((_) => step ("FreeSWITCH         ->> Opkalder          »De har ringet til <reception name>. Vent venligst.«"))
      .then((_) => Call_Announced_As_Locked ())
      .then((_) => step ("Klient-N           ->> Receptionist-N    [Queue: <reception naReception_ID = Reception_ID)me> (optaget)]"))
      .then((_) => step ("FreeSWITCH->Call-Flow-Control: call queued with dial-tone"))
      .then((_) => step ("FreeSWITCH->Caller: pause music"))
      .then((_) => Call_Announced_As_Unlocked ())
      .then((_) => step ("Client-N->Receptionist-N: Queue: <reception name> (venter)"))
      .then((_) => step ("Receptionist-N->Client-N: take call"))
      .then((_) => Request_Information (inboundCall.receptionID))
      .then((_) => Offer_To_Pick_Up_Call (receptionist, inboundCall))
      .then((_) => Call_Allocation_Acknowledgement ())
      .then((_) => step ("Call-Flow-Control->FreeSWITCH: connect call to phone-N"))
      .then((_) => Receptionist_Answers (inboundCall, currentReception))
      .catchError((error, stackTrace) => log.shout (error,stackTrace))
      .whenComplete(teardown);
  }

  /**
   * https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Indg%C3%A5ende-opkald#variant-i1ai-1
   */
  static Future incomingCall_I_1_a_i() {

    const String receptionExtension = '12340003';

    return setup()
      .then((_) => Caller_Places_Call (receptionExtension))
      .then((_) => Caller_Hears_Dialtone ())
      .then((_) => step ("FreeSWITCH: checks dial-plan => to queue"))
      .then((_) => step ("FreeSWITCH->Call-Flow-Control: call queued with dial-tone"))
      .then((_) => step ("FreeSWITCH: pauses dial-plan processing for # seconds"))
      .then((_) => Call_Announced ())
      .then((_) => step ("Client-N->Receptionist-N: shows call (with dial-tone)"))
      .then((_) => Request_Information (inboundCall.receptionID))
      .then((_) => Offer_To_Pick_Up_Call (receptionist, inboundCall))
      .then((_) => Call_Allocation_Acknowledgement ())
      .then((_) => step ("Client-N->Receptionist-N: Information on <reception name> (with full greeting)."))
      .then((_) => step ("Call-Flow-Control->FreeSWITCH: connect call to phone-N"))
      .then((_) => Receptionist_Answers (inboundCall, currentReception))
      .catchError((error, stackTrace) => log.shout (error,stackTrace))
      .whenComplete(teardown);
  }

  /**
   * https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Indg%C3%A5ende-opkald#variant-i1aii-1
   */
  static Future incomingCall_I_1_a_ii() {

    const String receptionExtension = '12340003';

    return setup()
      .then((_) => Caller_Places_Call (receptionExtension))
      .then((_) => Caller_Hears_Dialtone ())
      .then((_) => step ("FreeSWITCH: checks dial-plan => to queue"))
      .then((_) => step ("FreeSWITCH->Call-Flow-Control: call queued with dial-tone"))
      .then((_) => step ("FreeSWITCH: pauses dial-plan processing for # seconds"))
      .then((_) => Call_Announced ())
      .then((_) => step ("Client-N->Receptionist-N: shows call (with dial-tone)"))
      .then((_) => Request_Information (inboundCall.receptionID))
      .then((_) => step ("Receptionist 2 offers to pick up call."))
      .then((_) => Offer_To_Pick_Up_Call (receptionist2, inboundCall))
      .then((_) => step ("Receptionist 1 wait 210 ms to assure that client-N will miss the 200 ms time-window for responding."))
      .then((_) => Wait(200))
      .then((_) => Offer_To_Pick_Up_Call (receptionist, inboundCall))
      .then((_) => Call_Allocation_Acknowledgement ())
      .then((_) => step ("Client-N->Receptionist-N: Un-queue: <reception name>."))
      .catchError((error, stackTrace) => log.shout (error,stackTrace))
      .whenComplete(teardown);

  }


  /**
   * https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Indg%C3%A5ende-opkald#variant-i1bi-1
   */
  static Future incomingCall_I_1_b_i() {

    const String receptionExtension = '12340003';

    return setup()
      .then((_) => Caller_Places_Call (receptionExtension))
      .then((_) => Caller_Hears_Dialtone ())
      .then((_) => step ("FreeSWITCH: checks dial-plan => to queue"))
      .then((_) => step ("FreeSWITCH->Call-Flow-Control: call queued with dial-tone"))
      .then((_) => step ("FreeSWITCH: pauses dial-plan processing for # seconds"))
      .then((_) => Call_Announced ())
      .then((_) => step ("Client-N->Receptionist-N: shows call (with dial-tone)"))
      .then((_) => step ("Receptionist-N->Client-N: state-switch-free"))
      .then((_) => Request_Information (inboundCall.receptionID))
      .then((_) => Offer_To_Pick_Up_Call (receptionist, inboundCall))
      .then((_) => Call_Allocation_Acknowledgement ())
      .then((_) => step ("Client-N->Receptionist-N: Information on <reception name> (with full greeting)."))
      .then((_) => step ("Call-Flow-Control->FreeSWITCH: connect call to phone-N"))
      .then((_) => Receptionist_Answers (inboundCall, currentReception))
      .catchError((error, stackTrace) => log.shout (error,stackTrace))
      .whenComplete(teardown);
  }

  /**
   * https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Indg%C3%A5ende-opkald#variant-i1bii-1
   */
  static Future incomingCall_I_1_b_ii() {

    const String receptionExtension = '12340003';

    return setup().then((_) => Caller_Places_Call (receptionExtension)
      .then((_) => Caller_Hears_Dialtone ())
      .then((_) => step ("FreeSWITCH: checks dial-plan => to queue"))
      .then((_) => step ("FreeSWITCH->Call-Flow-Control: call queued with dial-tone"))
      .then((_) => step ("FreeSWITCH: pauses dial-plan processing for # seconds"))
      .then((_) => Call_Announced ())
      .then((_) => step ("Client-N->Receptionist-N: shows call (with dial-tone)"))
      .then((_) => step ("Receptionist-N: Busy doing other things (allowing FreeSWITCH to time out)."))
      .then((_) => Wait(8000))
      .then((_) => step ("FreeSWITCH: pause timed out"))
      .then((_) => step ("FreeSWITCH         ->> Call-Flow-Control: queued-unavailable: <call ID>"))
      .then((_) => step ("FreeSWITCH         ->> Opkalder          »De har ringet til <reception name>. Vent venligst.«"))
      .then((_) => Call_Announced_As_Locked ())
      .then((_) => step ("Klient-N           ->  Receptionist-N: Queue: <reception name> (optaget)"))
      .then((_) => step ("FreeSWITCH->Call-Flow-Control: call queued with dial-tone"))
      .then((_) => step ("FreeSWITCH->Caller: pause music"))
      .then((_) => Call_Announced_As_Unlocked ())
      .then((_) => step ("Client-N->Receptionist-N: Queue: <reception name> (venter)"))
      .then((_) => step ("Receptionist-N->Client-N: state-switch-free"))
      .then((_) => Request_Information (inboundCall.receptionID))
      .then((_) => Offer_To_Pick_Up_Call (receptionist, inboundCall))
      .then((_) => Call_Allocation_Acknowledgement ())
      .then((_) => step ("Call-Flow-Control->FreeSWITCH: connect call to phone-N"))
      .then((_) => Receptionist_Answers (inboundCall, currentReception))
      .catchError((error, stackTrace) => log.shout (error,stackTrace))
      .whenComplete(teardown));
  }

  /**
   * https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Indg%C3%A5ende-opkald#variant-i2a-1
   */
  static Future incomingCall_I_2_a() {

    const String receptionExtension = '12340003';

    return setup()
      .then((_) => Caller_Places_Call (receptionExtension))
      .then((_) => Caller_Hears_Dialtone ())
      .then((_) => step ("FreeSWITCH: checks dial-plan => to queue"))
      .then((_) => step ("FreeSWITCH->Call-Flow-Control: call queued with dial-tone"))
      .then((_) => step ("FreeSWITCH: pauses dial-plan processing for # seconds"))
      .then((_) => Call_Announced ())
      .then((_) => step ("Client-N->Receptionist-N: shows call (with dial-tone)"))
      .then((_) => step ("Receptionist-N->Client-N: take call"))
      .then((_) => Request_Information (inboundCall.receptionID))
      .then((_) => Offer_To_Pick_Up_Call (receptionist, inboundCall))
      .then((_) => Call_Allocation_Acknowledgement ())
      .then((_) => step ("Client-N->Receptionist-N: Information on <reception name> (with full greeting)."))
      .then((_) => step ("Call-Flow-Control->FreeSWITCH: connect call to phone-N"))
      .then((_) => Receptionist_Answers (inboundCall, currentReception))
      .catchError((error, stackTrace) => log.shout (error,stackTrace))
      .whenComplete(teardown);
  }
  /**
   * https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Indg%C3%A5ende-opkald#variant-i2b-1
   */
  static Future incomingCall_I_2_b() {

    const String receptionExtension = '12340003';

    return setup()
      .then((_) => Caller_Places_Call (receptionExtension))
      .then((_) => Caller_Hears_Dialtone ())
      .then((_) => step ("FreeSWITCH: checks dial-plan => to queue"))
      .then((_) => step ("FreeSWITCH->Call-Flow-Control: call queued with dial-tone"))
      .then((_) => step ("FreeSWITCH: pauses dial-plan processing for # seconds"))
      .then((_) => Call_Announced ())
      .then((_) => step ("Client-N->Receptionist-N: shows call (with dial-tone)"))
      .then((_) => step ("Receptionist-N: Busy doing other things (allowing FreeSWITCH to time out)."))
      .then((_) => Wait(8000))
      .then((_) => step ("FreeSWITCH: pause timed out"))
      .then((_) => step ("FreeSWITCH         ->> Call-Flow-Control: queued-unavailable: <call ID>"))
      .then((_) => step ("FreeSWITCH         ->> Opkalder          »De har ringet til <reception name>. Vent venligst.«"))
      .then((_) => Call_Announced_As_Locked ())
      .then((_) => step ("Klient-N           ->  Receptionist-N: Queue: <reception name> (optaget)"))
      .then((_) => step ("FreeSWITCH->Call-Flow-Control: call queued with dial-tone"))
      .then((_) => step ("FreeSWITCH->Caller: pause music"))
      .then((_) => Call_Announced_As_Unlocked ())
      .then((_) => step ("Client-N->Receptionist-N: Queue: <reception name> (venter)"))
      .then((_) => step ("Receptionist-N->Client-N: take call"))
      .then((_) => Request_Information (inboundCall.receptionID))
      .then((_) => Offer_To_Pick_Up_Call (receptionist, inboundCall))
      .then((_) => Call_Allocation_Acknowledgement ())
      .then((_) => step ("Call-Flow-Control->FreeSWITCH: connect call to phone-N"))
      .then((_) => Receptionist_Answers (inboundCall, currentReception))
      .catchError((error, stackTrace) => log.shout (error,stackTrace))
      .whenComplete(teardown);
  }
}