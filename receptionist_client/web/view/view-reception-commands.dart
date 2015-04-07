part of view;

class ReceptionCommands extends ViewWidget {
  Place                _myPlace;
  UIReceptionCommands _dom;

  /**
   *
   */
  ReceptionCommands(UIReceptionCommands this._dom, Place this._myPlace) {
    _registerEventListeners();
  }

  @override HtmlElement get root => _dom.root;
  @override HtmlElement get focusElement => _dom.commandList;
  @override Place get myPlace => _myPlace;

  void _activateMe(_) {
    _navigateToMyPlace();
  }

  void _registerEventListeners() {
    _navigate.onGo.listen(_setWidgetState);

    _dom.root.onClick.listen(_activateMe);

    _hotKeys.onAltH .listen(_activateMe);
  }
}
