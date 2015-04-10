part of view;

class ReceptionCalendar extends ViewWidget {
  Place               _myPlace;
  UIReceptionCalendar _ui;

  ReceptionCalendar(UIModel this._ui, Place this._myPlace) {
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

    _hotKeys.onAltA .listen(activateMe);
    _hotKeys.onCtrlE.listen((_) => _ui.active ? _navigate.goCalendarEdit(_myPlace) : null);
  }

  /**
   * Render the widget with .....
   */
  void render() {}
}
