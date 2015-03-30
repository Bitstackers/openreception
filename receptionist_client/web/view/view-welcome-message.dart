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

  set greetingText(String text) => this._greeting.text = text;

  /**
   *
   */
  void _registerEventListeners() {
    Model.Reception.onReceptionChange.listen(this._render);
  }

  void _render(Model.Reception reception) {
    if (Model.Call.currentCall != Model.nullCall &&
        Model.Call.currentCall.greetingPlayed) {
      this.greetingText = reception.shortGreeting;
    }
    else {
      this.greetingText = reception.greeting;
    }
  }
}
