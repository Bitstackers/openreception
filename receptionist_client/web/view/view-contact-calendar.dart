part of view;

class ContactCalendar extends Widget {
  Place              _myPlace;
  UIContactCalendar _ui;

  ContactCalendar(UIModel this._ui, Place this._myPlace) {
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

  void registerEventListeners() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onClick.listen(activateMe);

    _hotKeys.onAltK .listen(activateMe);
    _hotKeys.onCtrlE.listen((_) => _ui.active ? _navigate.goCalendarEdit() : null);
  }
}
