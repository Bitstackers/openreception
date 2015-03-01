part of or_test_fw;

abstract class IncomingCall {

  static String className = 'IncomingCall';

  static DateTime startTime = null;
  static int nextStep = 1;

  static Customer caller = null;
  static Receptionist receptionist = null;
  static Receptionist receptionist2 = null;
  static Customer callee = null;

  static Storage.Reception receptionStore = null;

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
    step('Receptionist\'s client waits for "${EventType.Call_Offer}"');

    return receptionist.waitFor(eventType: EventType.Call_Offer, extension: extension)
      .then((_) {
      Model.CallOffer event = receptionist.eventStack.firstWhere(
            (Model.Event offerEvent) => offerEvent.eventName == EventType.Call_Offer);
        return event.call;
      }) ;
  }

  /**
   * Simulates the receptionist client waiting for the call lock.
   */
  static Future<Model.Call> Receptionist_Awaits_Call_Lock(Model.Call call) {
    step('Receptionist\'s client waits for "${EventType.Call_Lock}"');

    return receptionist.waitFor(eventType: EventType.Call_Lock, callID: call.ID)
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
    step('Call-Flow-Control sends out "${EventType.Call_Unlock}"...');

    return receptionist.waitFor(eventType: EventType.Call_Unlock, callID: call.ID)
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

    return receptionist.waitFor(eventType: EventType.Call_Unlock, callID: call.ID);
  }

  static Future incomingCall_1_a_II() {
    String receptionExtension = '12340003';

    Model.Call trackedCall = null;
    Model.Reception reception = null;

    return setup().then((_) =>
    Caller_Places_Call(receptionExtension).then((_) => Caller_Hears_Dialtone()).then((_) {
      step("FreeSWITCH         ->  FreeSWITCH        [Checks dial-plan.  Result: Queue call.]");
      step("FreeSWITCH         ->> Call-Flow-Control [event: call-offer; destination: Reception]");
      step("FreeSWITCH: pauses dial-plan processing for # seconds");
    }).then((_) => Receptionist_Awaits_Call_Offer(extension: receptionExtension)
        .then((Model.Call nextAvailableCall) => trackedCall = nextAvailableCall)) // Update the local state
    .then((_) {
      step("Call-Flow-Control  ->  Call-Flow-Control [no responses to call-offer]");
      step("Call-Flow-Control  ->> FreeSWITCH        [force-end-pause: <call_ID>]");
      step("FreeSWITCH         ->> Call-Flow-Control [queued-unavailable: <call_ID>]");
      step("FreeSWITCH         ->> Opkalder          »De har ringet til <reception name>. Vent venligst.«");
    }).then((_) => Receptionist_Awaits_Call_Lock(trackedCall)
        .then((Model.Call lockedCall) => trackedCall = lockedCall)) // Update the local state
    .then((_) {
      step("Klient-N           ->> Receptionist-N    [Queue: <reception name> (optaget)]");
      step("FreeSWITCH->Call-Flow-Control: call queued with dial-tone");
      step("FreeSWITCH->Caller: playing music on hold");
    }).then((_) => Receptionist_Awaits_Call_Unlock(trackedCall)
        .then((Model.Call unlockedCall) => trackedCall = unlockedCall)) // Update the local state
    .then((_) {
      step("Client-N->Receptionist-N: Queue: <reception name> (venter)");
      step("Client-N->Receptionist-N: Queue: <reception name> (venter)");
      step("Receptionist-N->Client-N: state-switch-free");
    }).then((_) => receptionStore.get(trackedCall.receptionID)
        .then((Model.Reception r) => reception = r))
      .then((_) => receptionist.pickup(trackedCall)
        .then((Model.Call pickedUpCall) => trackedCall = pickedUpCall)) // Update the local state

    /* Now the call should have the greetingPlayed variable set to true, as we have previously
       * seen a 'call unlock' event.
       */
    .then((_) => expect(trackedCall.greetingPlayed, equals (true)))
    .then((_) => step("Call-Flow-Control->FreeSWITCH: connect call to phone-N"))
    .then((_) => Receptionist_Answers(trackedCall, reception))
    .catchError(_dumpState)
    .whenComplete(teardown));

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

  static void _validateCall(Model.Call call) {
    expect(call.assignedTo, equals (receptionist.userID));

    log.finest('FIXME: make _validateCall more elaborate');
  }
}





/*

      def Receptionist_Places_Call (self, Number):
          self.Step (Message = "Receptionist places call to " + str (Number) + "...")

          self.Log (Message = "Dialling through receptionist agent...")
          self.Receptionist.dial (Number)

      def Caller_Hears_Dialtone (self):
          self.Step (Message = "Caller hears dial-tone...")

          self.Log (Message = "Caller agent waits for dial-tone...")
          self.Caller.sip_phone.Wait_For_Dialtone ()

      def Receptionist_Hears_Dialtone (self):
          self.Step (Message = "Receptionist hears dial-tone...")

          self.Log (Message = "Receptionist agent waits for dial-tone...")
          self.Receptionist.sip_phone.Wait_For_Dialtone ()



      def Request_Information (self, Reception_ID):
          self.Step (Message = "Requesting (updated) information about reception " + str (Reception_ID))

          Data_On_Reception = self.Reception_Database.Single (Reception_ID)

          self.Step (Message = "Received information on reception " + str (Reception_ID))

          return Data_On_Reception

      def Offer_To_Pick_Up_Call (self, Call_Flow_Control, Call_ID):
          self.Step (Message = "Client offers to answer call...")

          try:
              Call_Flow_Control.PickupCall (call_id = Call_ID)
          except:
              self.Log (Message = "Pick-up call returned an error of some kind.")

      def Call_Allocation_Acknowledgement (self, Call_ID, Receptionist_ID):
          self.Step (Message = "Receptionist's client waits for 'call_pickup'...")

          try:
              self.Receptionist.event_stack.WaitFor (event_type = "call_pickup",
                                                     call_id    = Call_ID)
          except TimeOutReached:
              logging.critical (self.Receptionist.event_stack.dump_stack ())
              self.fail ("No 'call_pickup' event arrived from Call-Flow-Control.")

          try:
              Event = self.Receptionist.event_stack.Get_Latest_Event (Event_Type = "call_pickup",
                                                                      Call_ID    = Call_ID)
          except:
              logging.critical (self.Receptionist.event_stack.dump_stack ())
              self.fail ("Could not extract the received 'call_pickup' event from the Call-Flow-Control client.")

          try:
              if not Event['call']['assigned_to'] == Receptionist_ID:
                  logging.critical (self.Receptionist.event_stack.dump_stack ())
                  self.fail ("The arrived 'call_pickup' event was for " + str (Event['call']['assigned_to']) + ", and not for " + str (Receptionist_ID) + " as expected.")
          except:
              logging.critical (self.Receptionist.event_stack.dump_stack ())
              raise

          self.Log (Message = "Call picked up: " + pformat (Event))

          return Event

*/
