part of view;

class ReceptionCommands extends ViewWidget {
  Place               _myPlace;
  UIReceptionCommands _ui;

  ReceptionCommands(UIModel this._ui, Place this._myPlace) {
    registerEventListeners();
  }

  @override Place   get myPlace => _myPlace;
  @override UIModel get ui      => _ui;

  /**
   * Simply navigate to my [Place]. Matters not if this widget is already
   * focused.
   */
  void activateMe(_) {
    navigateToMyPlace();
  }

  @override void onBlur(_){}
  @override void onFocus(_){}

  void registerEventListeners() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onClick.listen(activateMe);

    _hotKeys.onAltH .listen(activateMe);
  }

  /**
   * Render the widget with .....
   */
  void render() {}
}
