part of view;

class ContextSwitcher {
  static final ContextSwitcher _singleton = new ContextSwitcher._internal();
  factory ContextSwitcher() => _singleton;

  /**
   *
   */
  ContextSwitcher._internal() {
    _registerEventListeners();
  }

  static final DivElement _root = querySelector('#context-switcher');

  final Map<String, ButtonElement> _buttonMap =
    {'context-home'    : _root.querySelector('.home'),
     'context-homeplus': _root.querySelector('.homeplus'),
     'context-messages': _root.querySelector('.messages')};
  final HotKeys  _hotKeys  = new HotKeys();
  final Navigate _navigate = new Navigate();

  /**
   *
   */
  void _onNavigate(Place place) {
    if(!_buttonMap[place.contextId].classes.contains('active')) {
      _buttonMap[place.contextId].classes.toggle('active', true);

      _buttonMap.forEach((String contextId, ButtonElement button) {
        if(contextId != place.contextId) {
          button.classes.toggle('active', false);
          button.blur();
        }
      });
    }
  }

  /**
   *
   */
  void _registerEventListeners() {
    _navigate.onGo.listen(_onNavigate);

    _buttonMap['context-home']    .onClick.listen((_) => _navigate.goHome());
    _buttonMap['context-homeplus'].onClick.listen((_) => _navigate.goHomeplus());
    _buttonMap['context-messages'].onClick.listen((_) => _navigate.goMessages());

    _hotKeys.onAltQ.listen((_) => _buttonMap['context-home']    .click());
    _hotKeys.onAltW.listen((_) => _buttonMap['context-homeplus'].click());
    _hotKeys.onAltE.listen((_) => _buttonMap['context-messages'].click());
  }
}
