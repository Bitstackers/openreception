part of view;

class ReceptionSalesCalls {
  static final ReceptionSalesCalls _singleton = new ReceptionSalesCalls._internal();
  factory ReceptionSalesCalls() => _singleton;

  /**
   * Constructor.
   */
  ReceptionSalesCalls._internal() {
    _observers();
  }

  static final DivElement _root = querySelector('#reception-sales-calls');

  /**
   * Observers.
   */
  void _observers() {
    // TODO (TL): Stuff...
  }
}
