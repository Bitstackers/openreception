part of view;

class Contexts {
  Map<String, HtmlElement> _contextMap;
  DomContexts              _dom;

  /**
   *
   */
  Contexts(DomContexts this._dom) {
    _contextMap = {'context-calendar-edit': _dom.contextCalendarEdit,
                   'context-home'         : _dom.contextHome,
                   'context-homeplus'     : _dom.contextHomeplus,
                   'context-messages'     : _dom.contextMessages};

    _registerEventListeners();
  }

<<<<<<< Updated upstream
  final Map<String, HtmlElement> _contextMap =
    {'context-home'    : querySelector('#context-home'),
     'context-homeplus': querySelector('#context-homeplus'),
     'context-messages': querySelector('#context-messages')};
  final Navigate _navigate = new Navigate();

=======
>>>>>>> Stashed changes
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
