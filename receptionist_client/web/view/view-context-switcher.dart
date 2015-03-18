part of view;

class ContextSwitcher {
  static final ContextSwitcher _singleton = new ContextSwitcher._internal();
  factory ContextSwitcher() => _singleton;

  Bus<Navigation> bus = new Bus<Navigation>();
  final Map<String, ButtonElement> buttonMap =
    {'context-home'    : querySelector('#context-switcher .home'),
     'context-homeplus': querySelector('#context-switcher .homeplus'),
     'context-messages': querySelector('#context-switcher .messages')};

  ContextSwitcher._internal() {
    registerEventListeners();
  }

  Stream<Navigation> get onClick => bus.stream;

  void navigate(Navigation to) {
    bus.fire(to);
    buttonMap.forEach((String id, ButtonElement button) {
      button.classes.toggle('active', id == to.contextId);
    });
  }

  void registerEventListeners() {
    buttonMap['context-home']    .onClick.listen((_) => navigate(home));
    buttonMap['context-homeplus'].onClick.listen((_) => navigate(homeplus));
    buttonMap['context-messages'].onClick.listen((_) => navigate(messages));
  }
}
