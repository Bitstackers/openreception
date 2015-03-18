part of view;

class Contexts {
  static final Contexts _singleton = new Contexts._internal();
  factory Contexts() => _singleton;

  final Map<String, HtmlElement> contextMap =
    {'context-home'    : querySelector('#context-home'),
     'context-homeplus': querySelector('#context-homeplus'),
     'context-messages': querySelector('#context-messages')};
  final ContextSwitcher contextSwitcher = new ContextSwitcher();

  Contexts._internal() {
    registerEventListeners();
  }

  void activateContext(Navigation to) {
    contextMap.forEach((id, element) {
      id == to.contextId ? setVisible(element) : setHidden(element);
    });
  }

  void registerEventListeners() {
    contextSwitcher.onClick.listen(activateContext);
  }

  void setHidden(HtmlElement element) {
    element.style.zIndex = '0';
  }

  void setVisible(HtmlElement element) {
    element.style.zIndex = '1';
  }
}
