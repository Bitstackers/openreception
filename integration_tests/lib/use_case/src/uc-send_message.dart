part of or_test_fw;

abstract class SendMessage {

  static DateTime startTime = null;
  static int nextStep = 1;
  static Customer caller = null;
  static Receptionist receptionist = null;
  static Storage.Message messageStore = null;
  static Storage.Contact contactStore = null;

  static Logger log = new Logger('$libraryName.UseCase.SendMessage');

  static Future Preconditions() => new Future.value (null);

  static Future setup() {
    startTime = new DateTime.now();
    nextStep = 1;

    log.finest('Setting up preconditions...');

    log.finest ('Setting up a MessageStore...');
    messageStore = new Service.RESTMessageStore(
        Config.messageStoreUri,
        receptionist.authToken,
        new Transport.Client());

    log.finest ('Setting up a ReceptionStore...');
    contactStore= new Service.RESTContactStore(
        Config.contactStoreUri,
        receptionist.authToken,
        new Transport.Client());

    log.finest ("Send message test case: Preconditions set up.");

    return new Future.value (null);
  }

  static void teardown() {
    log.finest("Cleaning up after test...");
  }

  static Future Receptionist_Send_Message () {
    step ("Receptionist sends a message...");
    Model.Message message = new Model.Message.stub(Model.Message.noID);
    return contactStore.getByReception(4, 1).then((Model.Contact contact) {
      message.recipients = contact.distributionList;
      message.body = 'Sent from test framework.';
      message.sender = receptionist.user;
   }).then((_) {
      return messageStore.enqueue(message);
   }).then((_) {
      step ("Receptionist has sent message.");
   });
  }

  static Future Callee_Checks_For_Message () {
    step ("Callee checks for message...");
    log.severe('Assuming the message is delivered, as we do not have built '
        'access to IMAP stores yet');
    return new Future.value(null);
  }

  @deprecated
  static void Postprocessing() => teardown();

  static void step(String message) => log.finest('Step ${nextStep++}: $message');

  /**
   * https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Sende-en-besked#variant-1a-1
   */

  static Future send_message_1_a() {
    return setup()
      .then((_) => Preconditions())
      .then((_) => step("Receptionist-N     ->> Klient-N          [taster: navn]"))
      .then((_) => step("Receptionist-N     ->> Klient-N          [genvej: fokus-besked-tekst]"))
      .then((_) => step("Receptionist-N     ->> Klient-N          [taster: besked]"))
      .then((_) => step("=== Use-case: Find en kontakt ==="))
      .then((_) => step("=== Use-case: Send opkald videre ==="))
      .then((_) => step("Klient-N           ->> Klient-N          [ryd alle 'send besked'-felter]"))
      .then((_) => step("Receptionist-N    <<-  Klient-N          [ryddet 'send besked'-dialog]"))
      .whenComplete(teardown);
  }


  /**
   * https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Sende-en-besked#variant-1bi-1
   */
  static Future send_message_1_b_I() {
    return setup()
        .then((_) => Preconditions())
        .then((_) => step ("Receptionist-N     ->> Klient-N          [taster: navn]"))
        .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: fokus-besked-tekst]"))
        .then((_) => step ("Receptionist-N     ->> Klient-N          [taster: besked]"))
        .then((_) => step ("=== Use-case: Find en kontakt ==="))
        .then((_) => step ("=== Use-case: Send opkald videre ==="))
        .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: fokus-besked-tekst]"))
        .then((_) => step ("Receptionist-N    <<-  Klient-N          [viser fokus: besked-tekst]"))
        .then((_) => step ("Receptionist-N     ->> Klient-N          [retter beskeden]"))
        .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: fokus-modtagerliste] (måske)"))
        .then((_) => step ("Receptionist-N     ->> Klient-N          [retter modtagerlisten]"))
        .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: send-besked]"))
        .then((_) => Receptionist_Send_Message ())
        .then((_) => step ("Call-Flow-Control  ->> Message-Spool     [send <besked> til <modtagerliste>]"))
        .then((_) => Callee_Checks_For_Message ())
        .then((_) => step ("Receptionist-N    <<-  Klient-N          [ryddet 'send besked'-dialog]"))
        .whenComplete(teardown);
  }

  /**
   * https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Sende-en-besked#variant-1bii-1
   */
  static Future send_message_1_b_II() {
    return setup()
      .then((_) => Preconditions())
      .then((_) => step ("Receptionist-N     ->> Klient-N          [taster: navn]"))
      .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: fokus-besked-tekst]"))
      .then((_) => step ("Receptionist-N     ->> Klient-N          [taster: besked]"))
      .then((_) => step ("=== Use-case: Find en kontakt ==="))
      .then((_) => step ("=== Use-case: Send opkald videre ==="))
      .then((_) => step ("=== ... ==="))
      .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: fortryd-besked]"))
      .then((_) => step ("Receptionist-N    <<-  Klient-N          [ryddet 'send besked'-dialog]"))
      .whenComplete(teardown);
  }


  /**
   * https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Sende-en-besked#variant-2i-1
   */
  static Future send_message_2_b_I() {
    return setup()
    .then((_) => Preconditions())
    .then((_) => step ("Receptionist-N     ->> Klient-N          [taster: navn]"))
    .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: fokus-besked-tekst]"))
    .then((_) => step ("Receptionist-N     ->> Klient-N          [taster: besked]"))
    .then((_) => step ("=== Use-case: Find en kontakt ==="))
    .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: fokus-besked-tekst]"))
    .then((_) => step ("Receptionist-N    <<-  Klient-N          [viser fokus: besked-tekst]"))
    .then((_) => step ("Receptionist-N     ->> Klient-N          [retter beskeden]"))
    .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: fokus-modtagerliste] (måske)"))
    .then((_) => step ("Receptionist-N     ->> Klient-N          [retter modtagerlisten]"))
    .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: send-besked]"))
    .then((_) => Receptionist_Send_Message ())
    .then((_) => step ("Call-Flow-Control  ->> Message-Spool     [send <besked> til <modtagerliste>]"))
    .then((_) => Callee_Checks_For_Message ())
    .then((_) => step ("Receptionist-N    <<-  Klient-N          [ryddet 'send besked'-dialog]"))
    .whenComplete(teardown);
  }

  /**
   * https://github.com/AdaHeads/Hosted-Telephone-Reception-System/wiki/Use-case%3A-Sende-en-besked#variant-2ii-1
   */
  static Future send_message_2_b_II() {
    return setup()
        .then((_) => Preconditions())
        .then((_) => step ("Receptionist-N     ->> Klient-N          [taster: navn]"))
        .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: fokus-besked-tekst]"))
        .then((_) => step ("Receptionist-N     ->> Klient-N          [taster: besked]"))
        .then((_) => step ("=== Use-case: Find en kontakt ==="))
        .then((_) => step ("=== ... ==="))
        .then((_) => step ("Receptionist-N     ->> Klient-N          [genvej: fortryd-besked]"))
        .then((_) => step ("Receptionist-N    <<-  Klient-N          [ryddet 'send besked'-dialog]"))
        .whenComplete(teardown);
  }
}