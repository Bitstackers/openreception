part of view;

class WelcomeMessage {
  static final WelcomeMessage _singleton = new WelcomeMessage._internal();
  factory WelcomeMessage() => _singleton;

  /**
   * Constructor.
   */
  WelcomeMessage._internal() {
    _greeting.text = 'Welcome!';

    _observers();
  }

  static final DivElement _root = querySelector('#welcome-message');

  final SpanElement _greeting = _root.querySelector('.greeting');

  /**
   * Observers.
   */
  void _observers() {
    // TODO (TL): Get me some data!
  }
}
