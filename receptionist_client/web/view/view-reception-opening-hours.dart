part of view;

class ReceptionOpeningHours {
  static final ReceptionOpeningHours _singleton = new ReceptionOpeningHours._internal();
  factory ReceptionOpeningHours() => _singleton;

  /**
   *
   */
  ReceptionOpeningHours._internal() {
    _registerEventListeners();
  }

  static final DivElement _root = querySelector('#reception-opening-hours');

  /**
   *
   */
  void _registerEventListeners() {
    // TODO (TL): Stuff...
  }
}
