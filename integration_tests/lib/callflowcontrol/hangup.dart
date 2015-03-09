part of or_test_fw;

abstract class Hangup {

  static Logger log = new Logger('Test.Hangup');

  /**
   * Test for the presence of hangup events and call interface.
   */
  static Future eventPresence() {
    Receptionist receptionist = ReceptionistPool.instance.aquire();
    Customer     customer     = CustomerPool.instance.aquire();

    String       reception = "12340003";

    log.finest ("Customer " + customer.name + " dials " + reception);

    return customer.dial (reception)
      .then((_) => receptionist.waitForCall())
      .then((_) => customer.hangupAll())
      .then((_) => receptionist.waitFor(eventType:"call_hangup"))
    .whenComplete(() {
      ReceptionistPool.instance.release(receptionist);
      CustomerPool.instance.release(customer);
    });

  }
}
