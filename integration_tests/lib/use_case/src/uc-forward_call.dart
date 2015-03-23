part of or_test_fw;

abstract class ForwardCall {

  static String className = 'ForwardCall';

  static DateTime startTime = null;
  static int nextStep = 1;

  static Logger log = new Logger(ForwardCall.className);

  static Customer caller = null;
  static Receptionist receptionist = null;
  static Receptionist receptionist2 = null;
  static Customer callee = null;
  static Storage.Reception receptionStore = null;
  static int contactID = 2;
  static int receptionID = 1;
  static Model.Call inboundCall;
  static Model.Call outboundCall;

  static Future<Model.Call> Preconditions(String receptionNumber) {

    nextStep = 0;
    return Caller_Places_Call(receptionNumber).then((_) {

      nextStep = 0;
      return Call_Announced().then((Model.Call call) {
        nextStep = 0;
        return Offer_To_Pick_Up_Call(
            receptionist,
            call).then((Model.Call call) {
          log.finest("Preconditions set up.");
          inboundCall = call;
          return call;
        });
      });
    });
  }

  static void teardown() => log.finest("Cleaning up after test...");

  static void postconditions() {
    //TODO: Perform assertions.

    teardown();
  }

  static void step(String message) =>
      log.finest('Step ${nextStep++}: $message');

  static Future<Model.Call> requestCall() =>
      new Future.error(new UnimplementedError());

  static Future setup() {
    startTime = new DateTime.now();
    nextStep = 1;

    log.finest("Forward call test case: Setting up preconditions...");

    log.finest("Put caller agent on manual answer...");

    return caller.autoAnswer(false).then((_) {
      caller.answerLatency = new Duration(seconds: -1);
    }).then((_) {
      log.finest("Put receptionist agent on auto-answer...");
      return receptionist.autoAnswer(true);
    }).then((_) {
      receptionist.answerLatency = new Duration(seconds: 0);
    }).then((_) {
      log.finest("Put callee agent on manual answer...");
      return callee.autoAnswer(false);
    }).then((_) {
      callee.answerLatency = new Duration(seconds: -1);
    }).then((_) {
      log.finest("Select a reception database connection...");
      receptionStore = new Service.RESTReceptionStore(
          Config.receptionStoreUri,
          receptionist.authToken,
          new Transport.Client());

      log.finest('Done setting up...');
    });
  }

  static Future<Phonio.Call> Caller_Places_Call(String extension) {
    return caller.dial(extension).then((Phonio.Call call) {
      log.finest("Caller has placed call to extension $extension.");
      return call;
    });
  }

  static Future Caller_Hears_Dialtone() {
    log.finest("Caller agent waits for dial-tone...");
    return caller.Wait_For_Dialtone().then((_) {
      log.finest("Caller agent hears dial-tone now.");
    });
  }

  static void Receptionist_Places_Call(String extension) {
    log.finest("Receptionist places call to $extension.");

    receptionist.originate(
        extension,
        contactID,
        receptionID).then((Model.Call call) {
      log.finest("Call-Flow-Control has accepted request to place call.");

      call;
    }).catchError((error, stackTrace) {
      log.severe("Receptionist failed to originate call to $extension.");
      log.severe(error, stackTrace);
    });
  }

  static Future Receptionist_Hears_Dialtone() {
    step("Receptionist hears dial-tone...");
    log.severe(
        "(we assume, as we can't test it directly with our current setup)");
    return new Future(() => null);
  }

  static String callInfo(Model.Call call) =>
      '${call.inbound ? 'inbound': 'outbound'} '
          'call with destination ${call.destination}';

  static Future Receptionist_Hangs_Up(Model.Call call) {
    step('Receptionist requests to hang up ${callInfo(call)}.');

    return receptionist.hangUp(call).then((_) {
      log.finest('Succeeded hanging up ${callInfo(call)}.');
    });
  }

  static Future Receptionist_Hangs_Up_Outbound_Call() =>
      Receptionist_Hangs_Up(outboundCall);

  static Future Receptionist_Waits_For_Hang_Up() {
    step("Receptionist waits for hangs up...");
    return receptionist.waitFor(eventType: Model.EventJSONKey.callHangup);
  }

  static Future<Model.Call> Receptionist_Receives_Call() {
    step("Receptionist receives call...");
    return receptionist.waitForInboundCall().then((_) {
      log.finest("Receptionist SIP phone got an incoming call.");
    });
  }

  static void Receptionist_Answers(Model.Call call, Model.Reception reception) {
    step("Receptionist answers...");
    if (call.greetingPlayed) {
      log.finest('Receptionist gives greeting ${reception.shortGreeting}');
    } else {
      log.finest('Receptionist gives greeting ${reception.greeting}');
    }
  }


  static Future Receptionist_Forwards_Call(Model.Call inboundCall,
      Model.Call outboundCall) {
    step("Receptionist forwards call...");
    log.finest("Waiting for 'call_pickup' event...");

    return receptionist.waitFor(
        eventType: Model.EventJSONKey.callPickup).then((Model.CallPickup event) {
      log.finest("Grabbing the 'call_pickup' event...");
      log.finest(event.call.toJson());
      if (event.call.destination != outboundCall.destination) {
        log.severe(
            'Expected ${event.call.destination} == ${outboundCall.destination}');
        throw new AssertionError();
      }

      log.finest(
          "Transfer the incoming call to the A leg of the outgoing call...");
    }).then(
        (_) => receptionist.transferCall(inboundCall, outboundCall)).then((_) {
      log.finest("Waiting for the 'call_transfer' event...");

      return receptionist.waitFor(
          eventType: Model.EventJSONKey.callTransfer).then((_) {
        log.finest("Receptionist has forwarded call.");
      });
    });
  }

  static Future Callee_Receives_Call() {
    step("Callee receives call...");
    log.finest("Callee agent waits for incoming call...");
    return callee.waitForInboundCall().then((_) {
      log.finest("Callee agent got an incoming call.");
    });
  }

  static Future Callee_Accepts_Call() {
    step("Callee accepts call...");
    log.finest("Callee agent accepts incoming call...");
    return callee.pickupCall().then((_) {
      log.finest("Callee agent has picked up the incoming call.");
    });
  }

  static Future Callee_Receives_Hang_Up() {
    step("Callee receives hangup on active call...");
    log.finest("Callee agent waits for hangup on active call...");

    return callee.waitForHangup().then((_) {
      log.finest("Callee agent got a hangup on the active call.");
    });
  }

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

  static Future<Model.Call> Call_Announced_As_Locked(Call_ID) {
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

  static Future<Model.Call> Call_Announced_As_Unlocked(Call_ID) {
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

  static Future Call_Allocation_Acknowledgement(Call_ID, Receptionist_ID) {
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
   *  https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Sende-opkald-videre#variant-1ai-1
   */
  static Future forward_call_1_a_I() {
    return setup()
        .then((_) => Preconditions('12340003'))
        .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: ring-til-primaert-nummer]"))
        .then((_) => Receptionist_Places_Call (callee.extension))
        .then((_) => step ("Call-Flow-Control  ->> FreeSWITCH        [ring-op: telefon-N, nummer]"))
        .then((_) => Callee_Receives_Call ())
        .then((_) => step ("FreeSWITCH         ->> FreeSWITCH        [forbind opkald og telefon-N]"))
        .then((_) => Receptionist_Hears_Dialtone ())
        .then((_) => step ("Callee phone rings."))
        .then((_) => Callee_Accepts_Call ())
        .then((_) => step ("=== loop ==="))
        .then((_) => step ("Receptionist-N     ->> Telefon-N         [snak]"))
        .then((_) => step ("Telefon-N          ->> FreeSWITCH        [SIP: lyd]"))
        .then((_) => step ("FreeSWITCH         ->> Medarbejder       [SIP: lyd]"))
        .then((_) => step ("Medarbejder        ->> FreeSWITCH        [SIP: lyd]"))
        .then((_) => step ("FreeSWITCH         ->> Telefon-N         [SIP: lyd]"))
        .then((_) => step ("Telefon-N          ->> Receptionist-N    [snak]"))
        .then((_) => step ("=== end loop ==="))
        .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: stil-igennem]"))
        .then((_) => Receptionist_Forwards_Call (inboundCall, outboundCall ))
        .then((_) => step ("Klient-N           ->> Klient-N          [ny tilstand: ledig]"))
        .then((_) => step ("Call-Flow-Control  ->> FreeSWITCH        [connect: incoming, outgoing]"))
        .then((_) => Receptionist_Waits_For_Hang_Up ())
        .then((_) => step ("FreeSWITCH         ->> Call-Flow-Control [free: telefon-N]"))
        .then((_) => step ("FreeSWITCH         ->> FreeSWITCH        [connect: incoming, outgoing]"))
        .catchError((error, stackTrace) => log.shout (error,stackTrace))
        .whenComplete(teardown);
  }


  /**
   *  https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Sende-opkald-videre#variant-1aii-1
   */

  static Future forward_call_1_a_II() {
    return setup()
        .then((_) => Preconditions('12340003'))
        .then((_) => step("Receptionist-N ->> Klient-N [genvej: ring-til-primaert-nummer]"))
        .then((_) => Receptionist_Places_Call(callee.extension))
        .then((_) => step("Call-Flow-Control ->> FreeSWITCH [ring-op: telefon-N, nummer]"))
        .then((_) => Callee_Receives_Call())
        .then((_) => step("FreeSWITCH ->> FreeSWITCH [forbind opkald og telefon-N]"))
        .then((_) => Receptionist_Hears_Dialtone())
        .then((_) => step("Callee phone rings."))
        .then((_) => Callee_Accepts_Call())
        .then((_) => step("=== loop ==="))
        .then((_) => step("Receptionist-N ->> Telefon-N [snak]"))
        .then((_) => step("Telefon-N ->> FreeSWITCH [SIP: lyd]"))
        .then((_) => step("FreeSWITCH ->> Medarbejder [SIP: lyd]"))
        .then((_) => step("Medarbejder ->> FreeSWITCH [SIP: lyd]"))
        .then((_) => step("FreeSWITCH ->> Telefon-N [SIP: lyd]"))
        .then((_) => step("Telefon-N ->> Receptionist-N [snak]"))
        .then((_) => step("=== end loop ==="))
        .then((_) => step("Receptionist-N ->> Klient-N [genvej: afslut-udgaaende-samtale]"))
        .then((_) => Receptionist_Hangs_Up_Outbound_Call())
        .then((_) => step("Call-Flow-Control ->> FreeSWITCH [afslut telefon-N's udgaaende samtale]"))
        .then((_) => Callee_Receives_Hang_Up())
        .then((_) => Receptionist_Waits_For_Hang_Up())
        .then((_) => step("FreeSWITCH -> FreeSWITCH [forbind opkalder og telefon-N]"))
        .then((_) => step("=== loop ==="))
        .then((_) => step("Receptionist-N ->> Telefon-N [snak]"))
        .then((_) => step("Telefon-N ->> FreeSWITCH [SIP: lyd]"))
        .then((_) => step("FreeSWITCH ->> Opkalder [SIP: lyd]"))
        .then((_) => step("Opkalder ->> FreeSWITCH [SIP: lyd]"))
        .then((_) => step("FreeSWITCH ->> Telefon-N [SIP: lyd]"))
        .then((_) => step("Telefon-N ->> Receptionist-N [snak]"))
        .then((_) => step("=== end loop ==="))
        .catchError((error, stackTrace) => log.shout (error,stackTrace))
        .whenComplete(teardown);
  }

 /**
  *  https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Sende-opkald-videre#variant-1b-1
  */

  static Future forward_call_1_b() {
      return setup()
          .then((_) => Preconditions('12340003'))
          .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: ring-til-primaert-nummer]"))
          .then((_) => Receptionist_Places_Call (callee.extension))
          .then((_) => step ("Call-Flow-Control  ->> FreeSWITCH        [ring-op: telefon-N, nummer]"))
          .then((_) => Callee_Receives_Call ())
          .then((_) => step ("FreeSWITCH         ->> FreeSWITCH        [forbind opkald og telefon-N]"))
          .then((_) => Receptionist_Hears_Dialtone ())
          .then((_) => step ("Callee phone rings."))
          .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: opgiv-opkald]"))
          .then((_) => Receptionist_Hangs_Up (outboundCall))
          .then((_) => step ("Call-Flow-Control  ->> FreeSWITCH        [afslut telefon-N's udgaaende opkald]"))
          .then((_) => Callee_Receives_Hang_Up ())
          .then((_) => step ("FreeSWITCH         ->  FreeSWITCH        [forbind opkalder og telefon-N]"))
          .then((_) => step ("=== loop ==="))
          .then((_) => step ("Receptionist-N     ->> Telefon-N         [snak]"))
          .then((_) => step ("Telefon-N          ->> FreeSWITCH        [SIP: lyd]"))
          .then((_) => step ("FreeSWITCH         ->> Opkalder          [SIP: lyd]"))
          .then((_) => step ("Opkalder           ->> FreeSWITCH        [SIP: lyd]"))
          .then((_) => step ("FreeSWITCH         ->> Telefon-N         [SIP: lyd]"))
          .then((_) => step ("Telefon-N          ->> Receptionist-N    [snak]"))
          .then((_) => step ("=== end loop ==="))
          .catchError((error, stackTrace) => log.shout (error,stackTrace))
          .whenComplete(teardown);
  }


  /**
   *  https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Sende-opkald-videre#variant-2ai-1
   */
   static Future forward_call_2_a_I() {
       return setup()
           .then((_) => Preconditions('12340003'))
           .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: liste-med-sekundaere-numre]"))
           .then((_) => step ("Receptionist-N     ->> Klient-N          [pil op/ned - nogle gange]"))
           .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: ring-markeret-nummer-op]"))
           .then((_) => Receptionist_Places_Call (callee.extension))
           .then((_) => step ("Call-Flow-Control  ->> FreeSWITCH        [ring-op: nummer, telefon-N]"))
           .then((_) => Callee_Receives_Call ())
           .then((_) => step ("FreeSWITCH         ->  FreeSWITCH        [forbind opkald med telefon-N]"))
           .then((_) => Receptionist_Hears_Dialtone ())
           .then((_) => step ("Callee phone rings."))
           .then((_) => Callee_Accepts_Call ())
           .then((_) => step ("=== loop ==="))
           .then((_) => step ("Receptionist-N     ->> Telefon-N         [snak]"))
           .then((_) => step ("Telefon-N          ->> FreeSWITCH        [SIP: lyd]"))
           .then((_) => step ("FreeSWITCH         ->> Medarbejder       [SIP: lyd]"))
           .then((_) => step ("Medarbejder        ->> FreeSWITCH        [SIP: lyd]"))
           .then((_) => step ("FreeSWITCH         ->> Telefon-N         [SIP: lyd]"))
           .then((_) => step ("Telefon-N          ->> Receptionist-N    [snak]"))
           .then((_) => step ("=== end loop ==="))
           .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: stil-igennem]"))
           .then((_) => Receptionist_Forwards_Call (inboundCall, outboundCall))
           .then((_) => step ("Klient-N           ->> Klient-N          [ny tilstand: ledig]"))
           .then((_) => step ("Call-Flow-Control  ->> FreeSWITCH        [connect: incoming, outgoing]"))
           .then((_) => Receptionist_Waits_For_Hang_Up ())
           .then((_) => step ("FreeSWITCH         ->> Call-Flow-Control [free: telefon-N]"))
           .then((_) => step ("FreeSWITCH         ->> FreeSWITCH        [connect: incoming, outgoing]"))
           .catchError((error, stackTrace) => log.shout (error,stackTrace))
           .whenComplete(teardown);
   }
  /**
   *  https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Sende-opkald-videre#variant-2aii-1
   */
   static Future forward_call_2_a_II() {
       return setup()
           .then((_) => Preconditions('12340003'))
           .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: liste-med-sekundaere-numre]"))
           .then((_) => step ("Receptionist-N     ->> Klient-N          [pil op/ned - nogle gange]"))
           .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: ring-markeret-nummer-op]"))
           .then((_) => Receptionist_Places_Call (callee.extension))
           .then((_) => step ("Call-Flow-Control  ->> FreeSWITCH        [ring-op: nummer, telefon-N]"))
           .then((_) => Callee_Receives_Call ())
           .then((_) => step ("FreeSWITCH         ->  FreeSWITCH        [forbind opkald med telefon-N]"))
           .then((_) => Receptionist_Hears_Dialtone ())
           .then((_) => step ("Callee phone rings."))
           .then((_) => Callee_Accepts_Call ())
           .then((_) => step ("=== loop ==="))
           .then((_) => step ("Receptionist-N     ->> Telefon-N         [snak]"))
           .then((_) => step ("Telefon-N          ->> FreeSWITCH        [SIP: lyd]"))
           .then((_) => step ("FreeSWITCH         ->> Medarbejder       [SIP: lyd]"))
           .then((_) => step ("Medarbejder        ->> FreeSWITCH        [SIP: lyd]"))
           .then((_) => step ("FreeSWITCH         ->> Telefon-N         [SIP: lyd]"))
           .then((_) => step ("Telefon-N          ->> Receptionist-N    [snak]"))
           .then((_) => step ("=== end loop ==="))
           .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: afslut-udgaaende-samtale]"))
           .then((_) => Receptionist_Hangs_Up (outboundCall))
           .then((_) => step ("Call-Flow-Control  ->> FreeSWITCH        [afslut telefon-N's udgaaende samtale]"))
           .then((_) => Callee_Receives_Hang_Up())
           .then((_) => step ("FreeSWITCH         ->  FreeSWITCH        [forbind opkalder og telefon-N]"))
           .then((_) => step ("=== loop ==="))
           .then((_) => step ("Receptionist-N     ->> Telefon-N         [snak]"))
           .then((_) => step ("Telefon-N          ->> FreeSWITCH        [SIP: lyd]"))
           .then((_) => step ("FreeSWITCH         ->> Opkalder          [SIP: lyd]"))
           .then((_) => step ("Opkalder           ->> FreeSWITCH        [SIP: lyd]"))
           .then((_) => step ("FreeSWITCH         ->> Telefon-N         [SIP: lyd]"))
           .then((_) => step ("Telefon-N          ->> Receptionist-N    [snak]"))
           .then((_) => step ("=== end loop ==="))
           .catchError((error, stackTrace) => log.shout (error,stackTrace))
           .whenComplete(teardown);
   }



   /**
    *  https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Sende-opkald-videre#variant-2b-1
    */
    static Future forward_call_2_b() {
        return setup()
            .then((_) => Preconditions('12340003'))
            .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: liste-med-sekundaere-numre]"))
            .then((_) => step ("Receptionist-N     ->> Klient-N          [pil op/ned - nogle gange]"))
            .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: ring-markeret-nummer-op]"))
            .then((_) => Receptionist_Places_Call (callee.extension))
               .then((_) => step ("Call-Flow-Control  ->> FreeSWITCH        [ring-op: nummer, telefon-N]"))
               .then((_) => Callee_Receives_Call ())
               .then((_) => step ("FreeSWITCH         ->  FreeSWITCH        [forbind opkald med telefon-N]"))
               .then((_) => Receptionist_Hears_Dialtone ())
               .then((_) => step ("Callee phone rings."))
               .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: opgiv-opkald]"))
               .then((_) => Receptionist_Hangs_Up (outboundCall))
               .then((_) => step ("Call-Flow-Control  ->> FreeSWITCH        [afslut telefon-N's udgaaende opkald]"))
               .then((_) => Callee_Receives_Hang_Up ())
               .then((_) => step ("FreeSWITCH         ->  FreeSWITCH        [forbind opkalder og telefon-N]"))
               .then((_) => step ("=== loop ==="))
               .then((_) => step ("Receptionist-N     ->> Telefon-N         [snak]"))
               .then((_) => step ("Telefon-N          ->> FreeSWITCH        [SIP: lyd]"))
               .then((_) => step ("FreeSWITCH         ->> Opkalder          [SIP: lyd]"))
               .then((_) => step ("Opkalder           ->> FreeSWITCH        [SIP: lyd]"))
               .then((_) => step ("FreeSWITCH         ->> Telefon-N         [SIP: lyd]"))
               .then((_) => step ("Telefon-N          ->> Receptionist-N    [snak]"))
               .then((_) => step ("=== end loop ==="))
               .catchError((error, stackTrace) => log.shout (error,stackTrace))
             .whenComplete(teardown);
}

    /**
     *  https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Sende-opkald-videre#variant-3ai-1
     */
    static Future forward_call_3_a_I() {
        return setup()
            .then((_) => Preconditions('12340003'))
                .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: viderestil-til-nummer]"))
                .then((_) => step ("Klient-N           ->> Receptionist-N    [indtastningsfelt: telefonnummer]"))
                .then((_) => step ("Receptionist-N     ->> Klient-N          [indtaster/indkopierer nummer]"))
                .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: ring-op]"))
                    .then((_) => Receptionist_Places_Call (callee.extension))
                .then((_) => step ("Call-Flow-Control  ->> FreeSWITCH        [samtale: telefon-N, <nummer>]"))
                .then((_) => step ("FreeSWITCH         ->> Telefon-N         [SIP: opkald]"))
                .then((_) => step ("FreeSWITCH         ->> Medarbejder       [SIP: opkald]"))
                .then((_) => step ("FreeSWITCH         ->> FreeSWITCH        [Brokobler opkald.]"))
                .then((_) => Receptionist_Receives_Call ())
                .then((_) => Receptionist_Hears_Dialtone ())
                .then((_) => step ("Callee phone rings."))
                .then((_) => Callee_Receives_Call())
                .then((_) => Callee_Accepts_Call ())
                .then((_) => step ("=== loop ==="))
                .then((_) => step ("Receptionist-N     ->> Telefon-N         [snak]"))
                .then((_) => step ("Telefon-N          ->> FreeSWITCH        [SIP: lyd]"))
                .then((_) => step ("FreeSWITCH         ->> Medarbejder       [SIP: lyd]"))
                .then((_) => step ("Medarbejder        ->> FreeSWITCH        [SIP: lyd]"))
                .then((_) => step ("FreeSWITCH         ->> Telefon-N         [SIP: lyd]"))
                .then((_) => step ("Telefon-N          ->> Receptionist-N    [snak]"))
                .then((_) => step ("=== end loop ==="))
                .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: stil-igennem]"))
                .then((_) => Receptionist_Forwards_Call (inboundCall, outboundCall))
                .then((_) => step ("Klient-N           ->> Klient-N          [ny tilstand: ledig]"))
                .then((_) => step ("Call-Flow-Control  ->> FreeSWITCH        [connect: incoming, outgoing]"))
                .then((_) => Receptionist_Waits_For_Hang_Up ())
                .then((_) => step ("FreeSWITCH         ->> Call-Flow-Control [free: telefon-N]"))
                .then((_) => step ("FreeSWITCH         ->> FreeSWITCH        [connect: incoming, outgoing]"))
                .catchError((error, stackTrace) => log.shout (error,stackTrace))
              .whenComplete(teardown);
 }
    /**
     * https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Sende-opkald-videre#variant-3aii-1
     */
    static Future forward_call_3_a_II() {
        return setup()
            .then((_) => Preconditions('12340003'))
                        .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: viderestil-til-nummer]"))
                        .then((_) => step ("Klient-N           ->> Receptionist-N    [indtastningsfelt: telefonnummer]"))
                        .then((_) => step ("Receptionist-N     ->> Klient-N          [indtaster/indkopierer nummer]"))
                        .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: ring-op]"))
                            .then((_) => Receptionist_Places_Call (callee.extension))
                        .then((_) => step ("Call-Flow-Control  ->> FreeSWITCH        [samtale: telefon-N, <nummer>]"))
                        .then((_) => step ("FreeSWITCH         ->> Telefon-N         [SIP: opkald]"))
                        .then((_) => step ("FreeSWITCH         ->> Medarbejder       [SIP: opkald]"))
                        .then((_) => step ("FreeSWITCH         ->> FreeSWITCH        [Brokobler opkald.]"))
                        .then((_) => Receptionist_Receives_Call ())
                        .then((_) => Receptionist_Hears_Dialtone ())
                        .then((_) => step ("Callee phone rings."))
                        .then((_) => Callee_Receives_Call())
                        .then((_) => Callee_Accepts_Call ())
                        .then((_) => step ("=== loop ==="))
                        .then((_) => step ("Receptionist-N     ->> Telefon-N         [snak]"))
                        .then((_) => step ("Telefon-N          ->> FreeSWITCH        [SIP: lyd]"))
                        .then((_) => step ("FreeSWITCH         ->> Medarbejder       [SIP: lyd]"))
                        .then((_) => step ("Medarbejder        ->> FreeSWITCH        [SIP: lyd]"))
                        .then((_) => step ("FreeSWITCH         ->> Telefon-N         [SIP: lyd]"))
                        .then((_) => step ("Telefon-N          ->> Receptionist-N    [snak]"))
                        .then((_) => step ("=== end loop ==="))
                        .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: afslut-udgaaende-samtale]"))
                        .then((_) => Receptionist_Hangs_Up (outboundCall))
                        .then((_) => step ("Call-Flow-Control  ->> FreeSWITCH        [afslut telefon-N's udgaaende samtale]"))
                        .then((_) => Callee_Receives_Hang_Up())
                        .then((_) => step ("FreeSWITCH         ->  FreeSWITCH        [forbind opkalder og telefon-N]"))
                        .then((_) => step ("=== loop ==="))
                        .then((_) => step ("Receptionist-N     ->> Telefon-N         [snak]"))
                        .then((_) => step ("Telefon-N          ->> FreeSWITCH        [SIP: lyd]"))
                        .then((_) => step ("FreeSWITCH         ->> Opkalder          [SIP: lyd]"))
                        .then((_) => step ("Opkalder           ->> FreeSWITCH        [SIP: lyd]"))
                        .then((_) => step ("FreeSWITCH         ->> Telefon-N         [SIP: lyd]"))
                        .then((_) => step ("Telefon-N          ->> Receptionist-N    [snak]"))
                        .then((_) => step ("=== end loop ==="))
                        .catchError((error, stackTrace) => log.shout (error,stackTrace))
                      .whenComplete(teardown);
    }
    /**
     * https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Sende-opkald-videre#variant-3b-1
     */
    static Future forward_call_3_b() {
        return setup()
            .then((_) => Preconditions('12340003'))
                        .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: viderestil-til-nummer]"))
                        .then((_) => step ("Klient-N           ->> Receptionist-N    [indtastningsfelt: telefonnummer]"))
                        .then((_) => step ("Receptionist-N     ->> Klient-N          [indtaster/indkopierer nummer]"))
                        .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: ring-op]"))
                            .then((_) => Receptionist_Places_Call (callee.extension))
                        .then((_) => step ("Call-Flow-Control  ->> FreeSWITCH        [samtale: telefon-N, <nummer>]"))
                        .then((_) => step ("FreeSWITCH         ->> Telefon-N         [SIP: opkald]"))
                        .then((_) => step ("FreeSWITCH         ->> Medarbejder       [SIP: opkald]"))
                        .then((_) => step ("FreeSWITCH         ->> FreeSWITCH        [Brokobler opkald.]"))
                        .then((_) => Receptionist_Receives_Call ())
                        .then((_) => Receptionist_Hears_Dialtone ())
                        .then((_) => step ("Callee phone rings."))
                        .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: opgiv-opkald]"))
                        .then((_) => Receptionist_Hangs_Up (outboundCall))
                        .then((_) => step ("Call-Flow-Control  ->> FreeSWITCH        [afslut telefon-N's udgaaende opkald]"))
                        .then((_) => Callee_Receives_Hang_Up ())
                        .then((_) => step ("FreeSWITCH         ->  FreeSWITCH        [forbind opkalder og telefon-N]"))
                        .then((_) => step ("=== loop ==="))
                        .then((_) => step ("Receptionist-N     ->> Telefon-N         [snak]"))
                        .then((_) => step ("Telefon-N          ->> FreeSWITCH        [SIP: lyd]"))
                        .then((_) => step ("FreeSWITCH         ->> Opkalder          [SIP: lyd]"))
                        .then((_) => step ("Opkalder           ->> FreeSWITCH        [SIP: lyd]"))
                        .then((_) => step ("FreeSWITCH         ->> Telefon-N         [SIP: lyd]"))
                        .then((_) => step ("Telefon-N          ->> Receptionist-N    [snak]"))
                        .then((_) => step ("=== end loop ==="))

                        .catchError((error, stackTrace) => log.shout (error,stackTrace))
                      .whenComplete(teardown);
        }
}
