part of view;

class ReceptionSalesCalls {
  static final ReceptionSalesCalls _singleton = new ReceptionSalesCalls._internal();
  factory ReceptionSalesCalls() => _singleton;

  final DivElement root = querySelector('#reception-sales-calls');

  ReceptionSalesCalls._internal() {
    registerEventListeners();
  }

  void registerEventListeners() {
    // TODO (TL): Stuff...
  }
}
