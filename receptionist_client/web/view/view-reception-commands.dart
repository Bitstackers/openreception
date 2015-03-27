part of view;

class ReceptionCommands extends Widget {
  Place               _myPlace;
  UIReceptionCommands _ui;

  /**
   *
   */
  ReceptionCommands(UIReceptionCommands this._ui, Place this._myPlace) {
    _registerEventListeners();
  }

  void _activateMe(_) {
    _navigateToMyPlace();
  }

  HtmlElement get focusElement => _ui.commandList;

  Place get myPlace => _myPlace;

  void _registerEventListeners() {
    _navigate.onGo.listen(_setWidgetState);

    _ui.root.onClick.listen(_activateMe);

    _hotKeys.onAltH .listen(_activateMe);
  }

  HtmlElement get root => _ui.root;
}
