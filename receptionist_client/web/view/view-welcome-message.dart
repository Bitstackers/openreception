part of view;

class WelcomeMessage {
  static final WelcomeMessage _singleton = new WelcomeMessage._internal();
  factory WelcomeMessage() => _singleton;

  /**
   *
   */
  WelcomeMessage._internal() {
    _greeting.text = 'Welcome!';

    _registerEventListeners();
  }

  static final DivElement _root = querySelector('#welcome-message');

  final SpanElement _greeting = _root.querySelector('.greeting');

  /**
   *
   */
  void _registerEventListeners() {
    // TODO (TL): Get me some data!
  }
}
