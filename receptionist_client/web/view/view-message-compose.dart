part of view;

class MessageCompose {
  static final MessageCompose _singleton = new MessageCompose._internal();
  factory MessageCompose() => _singleton;

  final DivElement root = querySelector('#message-compose');

  MessageCompose._internal() {
    registerEventListeners();
  }

  void registerEventListeners() {
    // TODO (TL): Stuff...
  }
}
