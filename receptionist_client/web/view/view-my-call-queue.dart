part of view;

class MyCallQueue {
  static final MyCallQueue _singleton = new MyCallQueue._internal();
  factory MyCallQueue() => _singleton;

  final DivElement root = querySelector('#my-call-queue');

  MyCallQueue._internal() {
    registerEventListeners();
  }

  void registerEventListeners() {
    // TODO (TL): Stuff...
  }
}
