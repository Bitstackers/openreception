part of view;

class MyCallQueue {
  static final MyCallQueue _singleton = new MyCallQueue._internal();
  factory MyCallQueue() => _singleton;

  /**
   *
   */
  MyCallQueue._internal() {
    _registerEventListeners();
  }

  static final DivElement _root = querySelector('#my-call-queue');

  /**
   *
   */
  void _registerEventListeners() {
    // TODO (TL): Stuff...
  }
}
