part of view;

class ReceptionSelector {
  static final ReceptionSelector _singleton = new ReceptionSelector._internal();
  factory ReceptionSelector() => _singleton;

  final DivElement root = querySelector('#reception-selector');

  ReceptionSelector._internal() {
    registerEventListeners();
  }

  void registerEventListeners() {
    // TODO (TL): Do stuff....
  }
}
