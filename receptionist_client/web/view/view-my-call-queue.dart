part of view;

class MyCallQueue {
  static final MyCallQueue _singleton = new MyCallQueue._internal();
  factory MyCallQueue() => _singleton;

  /**
   * Constructor.
   */
  MyCallQueue._internal() {
    _observers();
  }

  static final DivElement _root = querySelector('#my-call-queue');

  /**
   * Observers.
   */
  void _observers() {
    // TODO (TL): Stuff...
  }
}
