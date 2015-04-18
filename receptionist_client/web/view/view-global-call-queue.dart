part of view;

class GlobalCallQueue {
  static final GlobalCallQueue _singleton = new GlobalCallQueue._internal();
  factory GlobalCallQueue() => _singleton;

  /**
   * Constructor.
   */
  GlobalCallQueue._internal() {
    _observers();
  }

  static final DivElement _root = querySelector('#global-call-queue');

  /**
   * Observers.
   */
  void _observers() {
    // TODO (TL): Stuff...
  }
}
