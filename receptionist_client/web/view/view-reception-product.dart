part of view;

class ReceptionProduct {
  static final ReceptionProduct _singleton = new ReceptionProduct._internal();
  factory ReceptionProduct() => _singleton;

  final DivElement root = querySelector('#reception-product');

  ReceptionProduct._internal() {
    registerEventListeners();
  }

  void registerEventListeners() {
    // TODO (TL): Stuff...
  }
}
