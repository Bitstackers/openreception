part of view;

class ReceptionProduct {
  static final ReceptionProduct _singleton = new ReceptionProduct._internal();
  factory ReceptionProduct() => _singleton;

  /**
   * Construct.
   */
  ReceptionProduct._internal() {
    _observers();
  }

  static final DivElement _root = querySelector('#reception-product');

  /**
   * Observers.
   */
  void _observers() {
    // TODO (TL): Stuff...
  }
}
