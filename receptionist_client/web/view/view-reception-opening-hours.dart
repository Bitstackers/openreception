part of view;

class ReceptionOpeningHours {
  static final ReceptionOpeningHours _singleton = new ReceptionOpeningHours._internal();
  factory ReceptionOpeningHours() => _singleton;

  /**
   * Constructor.
   */
  ReceptionOpeningHours._internal() {
    _observers();
  }

  static final DivElement _root = querySelector('#reception-opening-hours');

  /**
   * Observers.
   */
  void _observers() {
    // TODO (TL): Stuff...
  }
}
