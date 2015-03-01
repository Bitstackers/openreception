part of or_test_fw;

abstract class SendMessage {

  static String className = 'FindContact';

  static DateTime startTime = null;
  static int nextStep = 1;
  static Customer caller = null;
  static Receptionist receptionist = null;
  static Storage.Message messageStore = null;

  static Logger log = new Logger(FindContact.className);

  @deprecated
  static void Preconditions() => setup();

  static void setup() {
    startTime = new DateTime.now();
    nextStep = 1;

    log.finest('Setting up preconditions...');

    log.finest ('Requesting a receptionist...');
    receptionist = ReceptionistPool.instance.aquire();

    log.finest("Requesting a customer (caller)...");
    caller = CustomerPool.instance.aquire();

    log.finest ('Setting up a MessageStore...');
    messageStore = new Service.RESTMessageStore(
        Config.messageServerUri,
        Config.authToken,
        new Transport.Client());

    log.finest ("Send message test case: Preconditions set up.");
  }

  static void teardown() {
    log.finest("Cleaning up after test...");

    log.finest ('Releasing receptionist...');
    receptionist != null ? ReceptionistPool.instance.release(receptionist) : null;

    log.finest("Releasing customer (caller)...");
    caller != null ? CustomerPool.instance.release(caller) : null;
  }

  @deprecated
  static void Postprocessing() => teardown();

  static void step(String message) => log.finest('Step ${nextStep++}: $message');

  /**
   *  https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Sende-en-besked#variant-1a-1
   **/

  static Future send_message_1_a() {
    return new Future(() {
      setup();

      step("Receptionist-N     ->> Klient-N          [taster: navn]");
      step("Receptionist-N     ->> Klient-N          [genvej: fokus-besked-tekst]");
      step("Receptionist-N     ->> Klient-N          [taster: besked]");
      step("=== Use-case: Find en kontakt ===");
      step("=== Use-case: Send opkald videre ===");
      step("Klient-N           ->> Klient-N          [ryd alle 'send besked'-felter]");
      step("Receptionist-N    <<-  Klient-N          [ryddet 'send besked'-dialog]");


    }).whenComplete(teardown);
  }
}