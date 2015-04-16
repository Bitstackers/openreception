part of view;

class ReceptionCommands extends ViewWidget {
  Controller.Place          _myPlace;
  Model.UIReceptionCommands _ui;

  ReceptionCommands(Model.UIModel this._ui, Controller.Place this._myPlace) {
    _ui.help = 'alt+h';

    registerEventListeners();
  }

  @override Controller.Place get myPlace => _myPlace;
  @override Model.UIModel    get ui      => _ui;

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
