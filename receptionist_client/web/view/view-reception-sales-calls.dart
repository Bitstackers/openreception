part of view;

class ReceptionSalesCalls {
  static final ReceptionSalesCalls _singleton = new ReceptionSalesCalls._internal();
  factory ReceptionSalesCalls() => _singleton;

  /**
   *
   */
  ReceptionSalesCalls._internal() {
    _registerEventListeners();
  }

  static final DivElement _root = querySelector('#reception-sales-calls');

  /**
   *
   */
  void _registerEventListeners() {
    // TODO (TL): Stuff...
  }
}
