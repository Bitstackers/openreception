part of view;

class GlobalCallQueue {
  static final GlobalCallQueue _singleton = new GlobalCallQueue._internal();
  factory GlobalCallQueue() => _singleton;

  final DivElement root = querySelector('#global-call-queue');

  GlobalCallQueue._internal() {
    registerEventListeners();
  }

  void registerEventListeners() {
    // TODO (TL): Stuff...
  }
}
