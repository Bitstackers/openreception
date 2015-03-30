part of view;

class ReceptionSelector {
  static final ReceptionSelector _singleton = new ReceptionSelector._internal();
  factory ReceptionSelector() => _singleton;

  /**
   *
   */
  ReceptionSelector._internal() {
    _registerEventListeners();
  }

  static final DivElement _root = querySelector('#reception-selector');

  /**
   *
   */
  void _registerEventListeners() {
    // TODO (TL): Do stuff....
  }
}
