part of view;

class WelcomeMessage {
  static final WelcomeMessage _singleton = new WelcomeMessage._internal();
  factory WelcomeMessage() => _singleton;

  final SpanElement greeting = querySelector('#welcome-message .greeting');
  final DivElement  root     = querySelector('#welcome-message');

  WelcomeMessage._internal() {
    greeting.text = 'Welcome!';

    registerEventListeners();
  }

  void registerEventListeners() {
    // TODO (TL): Get me some data!
  }
}
