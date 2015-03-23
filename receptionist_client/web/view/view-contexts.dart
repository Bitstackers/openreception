part of view;

class Contexts {
  static final Contexts _singleton = new Contexts._internal();
  factory Contexts() => _singleton;

  /**
   *
   */
  Contexts._internal() {
    _registerEventListeners();
  }

  final Map<String, HtmlElement> _contextMap =
    {'context-home'    : querySelector('#context-home'),
     'context-homeplus': querySelector('#context-homeplus'),
     'context-messages': querySelector('#context-messages')};
  final Navigate _navigate = new Navigate();

  /**
   *
   */
  void onNavigation(Place place) {
    _contextMap.forEach((id, element) {
      id == place.contextId ? _setVisible(element) : _setHidden(element);
    });
  }

  /**
   *
   */
  void _registerEventListeners() {
    _navigate.onGo.listen(onNavigation);
  }

  /**
   *
   */
  void _setHidden(HtmlElement element) {
    element.style.zIndex = '0';
  }

  /**
   *
   */
  void _setVisible(HtmlElement element) {
    element.style.zIndex = '1';
  }
}
