part of view;

class Contexts {
  Map<String, HtmlElement> _contextMap;
  Model.UIContexts         _ui;

  Contexts(Model.UIModel this._ui) {
    /// TODO (TL): Perhaps take this map in as a constructor parameter?
    _contextMap = {'context-calendar-edit': _ui.contextCalendarEdit,
                   'context-home'         : _ui.contextHome,
                   'context-homeplus'     : _ui.contextHomeplus,
                   'context-messages'     : _ui.contextMessages};

    _registerEventListeners();
  }

  void onNavigation(Place place) {
    _contextMap.forEach((id, element) {
      id == place.contextId ? _setVisible(element) : _setHidden(element);
    });
  }

  void _registerEventListeners() {
    _navigate.onGo.listen(onNavigation);

    _hotKeys.onAltQ.listen((_) => _navigate.goHome());
    _hotKeys.onAltW.listen((_) => _navigate.goHomeplus());
    _hotKeys.onAltE.listen((_) => _navigate.goMessages());
  }

  void _setHidden(HtmlElement element) {
    element.style.zIndex = '0';
  }

  void _setVisible(HtmlElement element) {
    element.style.zIndex = '1';
  }
}
