part of view;

class MessageCompose {
  static final MessageCompose _singleton = new MessageCompose._internal();
  factory MessageCompose() => _singleton;

  /**
   *
   */
  MessageCompose._internal() {
    _registerEventListeners();
  }

  static final DivElement _root = querySelector('#message-compose');

  /**
   *
   */
  void _registerEventListeners() {
    // TODO (TL): Stuff...
  }
}
