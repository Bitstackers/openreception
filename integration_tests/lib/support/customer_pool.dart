part of openreception_tests.support;

class CustomerPool extends Pool<Customer> {
  /// Singleton.
  static CustomerPool instance = null;

  CustomerPool(Iterable<Customer> elements) : super(elements);
}
