part of view;

class GlobalCallQueue {
  static final GlobalCallQueue _singleton = new GlobalCallQueue._internal();
  factory GlobalCallQueue() => _singleton;

  /**
   *
   */
  GlobalCallQueue._internal() {
    _registerEventListeners();
  }

  static final DivElement _root = querySelector('#global-call-queue');

  /**
   *
   */
  void _registerEventListeners() {
    // TODO (TL): Stuff...
  }
}
