part of view;

class ReceptionProduct {
  static final ReceptionProduct _singleton = new ReceptionProduct._internal();
  factory ReceptionProduct() => _singleton;

  /**
   *
   */
  ReceptionProduct._internal() {
    _registerEventListeners();
  }

  static final DivElement _root = querySelector('#reception-product');

  /**
   *
   */
  void _registerEventListeners() {
    // TODO (TL): Stuff...
  }
}
