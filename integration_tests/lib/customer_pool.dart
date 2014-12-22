part of or_test_fw;

class CustomerPool extends Pool<Customer>{

  /// Singleton.
  static CustomerPool instance = null;

  CustomerPool(Iterable<Customer> elements) : super (elements);
}
