part of view;

class ReceptionOpeningHours {
  static final ReceptionOpeningHours _singleton = new ReceptionOpeningHours._internal();
  factory ReceptionOpeningHours() => _singleton;

  final DivElement root = querySelector('#reception-opening-hours');

  ReceptionOpeningHours._internal() {
    registerEventListeners();
  }

  void registerEventListeners() {
    // TODO (TL): Stuff...
  }
}
