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

  static Future<Model.Call> Preconditions(String receptionNumber) {

    nextStep = 0;
    Caller_Places_Call(receptionNumber);

    nextStep = 0;
    Model.Call call = Call_Announced();

    nextStep = 0;
    call = Offer_To_Pick_Up_Call(receptionist, call);
    log.finest("Forward call test case: Preconditions set up.");
    log.finest("Forward call test case: Returning ID of incoming call...");
    return call;
  }

  static Future setup() {
    startTime = new DateTime.now();
    nextStep = 1;

    log.finest("Forward call test case: Setting up preconditions...");
    log.finest("Requesting a customer (caller)...");
    caller = CustomerPool.instance.aquire();

    log.finest("Requesting a receptionist...");
    receptionist = ReceptionistPool.instance.aquire();

    log.finest("Requesting a customer (callee)...");
    callee = CustomerPool.instance.aquire();

    log.finest("Put caller agent on manual answer...");

    return caller.autoAnswer(false).then((_) {
      caller.answerLatency = new Duration(seconds: -1);
    })

    .then((_) {
      log.finest("Put receptionist agent on auto-answer...");
      return receptionist.autoAnswer(true);
    }).then((_) {
      receptionist.answerLatency = new Duration(seconds: 0);
    })

    .then ((_) {
      log.finest("Put callee agent on manual answer...");
      return callee.autoAnswer(false);
    }).then((_) {
      callee.answerLatency = new Duration(seconds: -1);
    }).then((_) {
      log.finest("Select a reception database connection...");
      receptionStore = new Service.RESTReceptionStore(
          Config.receptionStoreURI,
          receptionist.authToken,
          new Transport.Client());

      log.finest('Done setting up...');
    });
  }

  static Future<Phonio.Call> Caller_Places_Call (String extension) {
    log.finest('Caller places call.');
    return caller.dial(extension);
  }

  static void teardown() => log.finest("Cleaning up after test...");

  @deprecated
  static void Postprocessing() => teardown();

  static void step(String message) =>
      log.finest('Step ${nextStep++}: $message');

  static Future<Model.Call> requestCall() =>
      new Future.error(new UnimplementedError());

  static Future Callee_Receives_Call() {
    step("Callee receives call...");
    log.finest("Callee agent waits for incoming call...");
    callee.wait_for_call();
    log.finest("Callee agent got an incoming call.");
  }

  /**
   *  https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Sende-opkald-videre#variant-1aii-1
   **/

  static Future forward_call_1_a_II() {
    return new Future(() {
      setup();
      return Preconditions('12340003').then((Model.Call incomingCall) {
        step("Receptionist-N ->> Klient-N [genvej: ring-til-primaert-nummer]");

            //Outgoing_Call_ID = self.Receptionist_Places_Call (Number = self.Callee.extension)
        step("Call-Flow-Control ->> FreeSWITCH [ring-op: telefon-N, nummer]");
        Callee_Receives_Call();
        step("FreeSWITCH ->> FreeSWITCH [forbind opkald og telefon-N]");
        Receptionist_Hears_Dialtone();
        step("Callee phone rings.");
        Callee_Accepts_Call();
        step("=== loop ===");
        step("Receptionist-N ->> Telefon-N [snak]");
        step("Telefon-N ->> FreeSWITCH [SIP: lyd]");
        step("FreeSWITCH ->> Medarbejder [SIP: lyd]");
        step("Medarbejder ->> FreeSWITCH [SIP: lyd]");
        step("FreeSWITCH ->> Telefon-N [SIP: lyd]");
        step("Telefon-N ->> Receptionist-N [snak]");
        step("=== end loop ===");
        step("Receptionist-N ->> Klient-N [genvej: afslut-udgaaende-samtale]");
        Receptionist_Hangs_Up(Call_ID = Outgoing_Call_ID);
        step(
            "Call-Flow-Control ->> FreeSWITCH [afslut telefon-N's udgaaende samtale]");
        Callee_Receives_Hang_Up();
        Receptionist_Waits_For_Hang_Up();
        step("FreeSWITCH -> FreeSWITCH [forbind opkalder og telefon-N]");
        step("=== loop ===");
        step("Receptionist-N ->> Telefon-N [snak]");
        step("Telefon-N ->> FreeSWITCH [SIP: lyd]");
        step("FreeSWITCH ->> Opkalder [SIP: lyd]");
        step("Opkalder ->> FreeSWITCH [SIP: lyd]");
        step("FreeSWITCH ->> Telefon-N [SIP: lyd]");
        step("Telefon-N ->> Receptionist-N [snak]");
        step("=== end loop ===");
      });
    }).whenComplete(teardown);
  }
}
