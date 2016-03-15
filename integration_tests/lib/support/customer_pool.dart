part of openreception_tests.support;

class CustomerPool extends Pool<Customer> {
  /// Singleton.
  static CustomerPool instance = null;

  CustomerPool(Iterable<Customer> elements) : super(elements);
}

class PhonePool {
  const PhonePool.empty();

  Phonio.SIPPhone requestNext() {
    final phone = new Phonio.PJSUAProcess(
        Config.simpleClientBinaryPath, ConfigPool.requestPjsuaPort());

    return phone;
  }

  void cleanup() {
    ConfigPool.resetCounters();
  }
}
