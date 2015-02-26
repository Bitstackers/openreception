part of or_test_fw;

abstract class Message {

  static String className = 'Message';

  static DateTime startTime = null;
  static int nextStep = 1;

  static Logger log = new Logger(FindContact.className);

  @deprecated
  static void Preconditions() => setup();

  static void setup() {
    startTime = new DateTime.now();
    nextStep = 1;

    log.finest('Setting up preconditions...');
  }

  static void teardown() => log.finest("Cleaning up after test...");

  @deprecated
  static void Postprocessing() => teardown();

  static void step(String message) => log.finest('Step ${nextStep++}: $message');

  /**
   *  https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Finde-en-kontakt#variant-1-1
   **/

  static Future send_message_1_a() {
    return new Future(() {
      setup();

      step("Receptionist-N     ->> Klient-N          [genvej: for-kontaktliste]");
      step("Receptionist-N    <<-  Klient-N          [fokus: kontaktliste og soegefelt]");
      step("=== loop ===");
      step("Receptionist-N     ->> Klient-N          [arrow up/down]");
      step("Receptionist-N    <<-  Klient-N          [update contact view]");
      step("=== end loop ===");


    }).whenComplete(teardown);
  }
}
